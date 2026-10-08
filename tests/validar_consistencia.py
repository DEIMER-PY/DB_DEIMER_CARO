# -*- coding: utf-8 -*-
"""Valida que TODOS los modelos, diagramas, documentos y scripts SQL del repositorio coincidan con la
base de datos real (information_schema), que es la fuente de verdad.

Uso (desde la raíz del proyecto, con la base desplegada por tests/run_all.*):
    python tests/validar_consistencia.py            # informe completo
    python tests/validar_consistencia.py --resumen  # solo el resumen por artefacto

Conexión: mismas variables que run_all (MYSQL_MODE=auto|local|docker, MYSQL_CONTAINER, MYSQL_HOST,
MYSQL_PORT, MYSQL_USER, MYSQL_PASS, MYSQL_DB).

Artefactos revisados:
  sql/01_ddl_schema.sql               tablas, columnas, tipos, NULL, DEFAULT, PK, UNIQUE, FK, CHECK
  tallerexamenbd.md                   copia del DDL incrustada (debe ser idéntica a sql/01)
  sql/02..08                          columnas usadas en INSERT/UPDATE, NEW./OLD. y alias.columna
  docs/03_diccionario_de_datos.md     tablas, columnas, tipos, NULL, claves y DEFAULT
  docs/02, docs/04, README, AGENTS    nombres de tabla citados y rangos CHECK descritos
  diagrams/physical_erd.mmd           entidades, atributos, tipos, claves y relaciones
  diagrams/logical_model.mmd          entidades y relaciones con cardinalidad
  README.md (bloque mermaid)          entidades y relaciones con cardinalidad
  diagrams/conceptual_model.mmd       conceptos y cardinalidades
  diagrams/modelo_conceptual.drawio   conceptos y cardinalidades
  diagrams/exportaciones_staruml/*.svg  exportaciones de StarUML: entidades, columnas, tipos, claves y relaciones
  diagrams/generador_modelo_er.py     datos del modelo ER HTML (modelo_entidad_relacion.html)
  diagrams/oftalmologia_model.mdj     (lo revisa tests/validar_modelo_staruml.py; aquí se ejecuta)
"""
import collections, json, os, re, shutil, subprocess, sys, html as htmlmod

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
RESUMEN = '--resumen' in sys.argv
rd = lambda p: open(os.path.join(ROOT, p), encoding='utf-8').read().replace('\r\n', '\n')

# ============================================================================ base de datos real
ENV = lambda k, d: os.environ.get(k) or d
USER, PASS, DB = ENV('MYSQL_USER', 'root'), ENV('MYSQL_PASS', 'root2026'), ENV('MYSQL_DB', 'oftalmologia_glaucoma_db')
MODE = ENV('MYSQL_MODE', 'auto')
if MODE == 'auto': MODE = 'local' if shutil.which('mysql') else 'docker'

def q(sql):
    base = ['mysql', '--default-character-set=utf8mb4', '-u', USER, '-N', '-B', '-r', 'information_schema', '-e', sql]
    env = dict(os.environ, MYSQL_PWD=PASS, MSYS_NO_PATHCONV='1')
    cmd = (['docker', 'exec', '-e', 'MYSQL_PWD=' + PASS, ENV('MYSQL_CONTAINER', 'mysql_db')] + base) if MODE == 'docker' \
        else (base[:1] + ['-h', ENV('MYSQL_HOST', '127.0.0.1'), '-P', ENV('MYSQL_PORT', '3307')] + base[1:])
    out = subprocess.run(cmd, capture_output=True, env=env, check=True).stdout.decode('utf-8')
    return [l.split('\t') for l in out.splitlines() if l]

W = f"TABLE_SCHEMA='{DB}'"
TABLES = [r[0] for r in q(f"SELECT TABLE_NAME FROM TABLES WHERE {W} AND TABLE_TYPE='BASE TABLE' ORDER BY 1")]
VIEWS = [r[0] for r in q(f"SELECT TABLE_NAME FROM TABLES WHERE {W} AND TABLE_TYPE='VIEW' ORDER BY 1")]
COLS = collections.OrderedDict((t, collections.OrderedDict()) for t in TABLES)
VIEWCOLS = collections.defaultdict(set)
for t, c, ctype, nul, key, dflt, extra in q(
        f"SELECT TABLE_NAME,COLUMN_NAME,COLUMN_TYPE,IS_NULLABLE,COLUMN_KEY,IFNULL(COLUMN_DEFAULT,'\\\\N'),EXTRA "
        f"FROM COLUMNS WHERE {W} ORDER BY TABLE_NAME,ORDINAL_POSITION"):
    if t in COLS:
        COLS[t][c] = dict(type=ctype, null=nul == 'YES', key=key, default=None if dflt == '\\N' else dflt, extra=extra.lower())
    else:
        VIEWCOLS[t].add(c)
UNIQ = set()
for t, cols in q(f"SELECT TABLE_NAME,GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) FROM STATISTICS WHERE {W} "
                 f"AND NON_UNIQUE=0 AND INDEX_NAME<>'PRIMARY' GROUP BY TABLE_NAME,INDEX_NAME"):
    if ',' not in cols: UNIQ.add((t, cols))
FKS = {(t, c): (rt, rc, dr) for t, c, rt, rc, dr in q(
    f"SELECT k.TABLE_NAME,k.COLUMN_NAME,k.REFERENCED_TABLE_NAME,k.REFERENCED_COLUMN_NAME,r.DELETE_RULE FROM KEY_COLUMN_USAGE k "
    f"JOIN REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND r.CONSTRAINT_NAME=k.CONSTRAINT_NAME "
    f"WHERE k.{W} AND k.REFERENCED_TABLE_NAME IS NOT NULL")}
CHECKS = collections.defaultdict(list)
for t, name, clause in q(f"SELECT tc.TABLE_NAME,tc.CONSTRAINT_NAME,cc.CHECK_CLAUSE FROM TABLE_CONSTRAINTS tc JOIN CHECK_CONSTRAINTS cc "
                         f"ON cc.CONSTRAINT_SCHEMA=tc.CONSTRAINT_SCHEMA AND cc.CONSTRAINT_NAME=tc.CONSTRAINT_NAME "
                         f"WHERE tc.{W} AND tc.CONSTRAINT_TYPE='CHECK'"):
    CHECKS[t].append((name, clause))
ALLCOLS = {c for t in COLS for c in COLS[t]} | {c for v in VIEWCOLS.values() for c in v}
REL = {}   # (hija, padre) -> '1:1' | '1:0..1' | '1:N'
for (t, c), (rt, rc, dr) in FKS.items():
    REL[(t, rt)] = ('1:1' if t == 'clinical_histories' else '1:0..1') if (t, c) in UNIQ else '1:N'

# ============================================================================ utilidades
def canon(t):
    """Tipo canónico comparable: mayúsculas, sin espacios, BOOLEAN=TINYINT(1), sin AUTO_INCREMENT."""
    t = t.upper().replace('AUTO_INCREMENT', '').strip()
    t = re.sub(r'\s+', '', t)
    return 'BOOLEAN' if t in ('TINYINT(1)', 'BOOL') else t
def base(t): return canon(t).split('(')[0]
def canon_default(d, typ=''):
    if d is None: return None
    d = d.strip().strip('"')
    if d.upper() in ('NULL', '-', ''): return None
    u = d.upper().replace('()', '')
    if u.startswith('CURRENT_TIMESTAMP'): return 'CURRENT_TIMESTAMP'
    if base(typ) == 'BOOLEAN': return {'TRUE': '1', 'FALSE': '0'}.get(u, u)
    return d.strip("'")

class Report:
    def __init__(s): s.items = collections.OrderedDict()
    def section(s, name, desc): s.items[name] = dict(desc=desc, err=[], warn=[], ok=[])
    def e(s, name, msg): s.items[name]['err'].append(msg)
    def w(s, name, msg): s.items[name]['warn'].append(msg)
    def ok(s, name, msg): s.items[name]['ok'].append(msg)
R = Report()

# ============================================================================ 1. DDL
def parse_ddl(text):
    text = re.sub(r'--[^\n]*', '', text)
    out = collections.OrderedDict()
    for name, body in re.findall(r'CREATE TABLE\s+(\w+)\s*\((.*?)\)\s*ENGINE', text, re.S):
        cols = collections.OrderedDict(); uniq = set(); fks = {}; checks = []
        parts, depth, cur = [], 0, ''
        for ch in body:                       # separar por comas de primer nivel
            depth += ch == '('; depth -= ch == ')'
            if ch == ',' and depth == 0: parts.append(cur); cur = ''
            else: cur += ch
        parts.append(cur)
        for p in (x.strip() for x in parts):
            m = re.match(r'CONSTRAINT\s+\w+\s+(UNIQUE|FOREIGN KEY|CHECK)\s*(.*)', p, re.S | re.I)
            if m:
                kind, rest = m.group(1).upper(), m.group(2)
                if kind == 'UNIQUE':
                    cs = [x.strip() for x in re.match(r'\((.*?)\)', rest).group(1).split(',')]
                    if len(cs) == 1: uniq.add(cs[0])
                elif kind == 'FOREIGN KEY':
                    fm = re.match(r'\((\w+)\)\s*REFERENCES\s+(\w+)\((\w+)\)(.*)', rest, re.S)
                    dr = re.search(r'ON DELETE\s+(CASCADE|RESTRICT|SET NULL|NO ACTION)', fm.group(4))
                    fks[fm.group(1)] = (fm.group(2), fm.group(3), dr.group(1) if dr else 'RESTRICT')
                else:
                    checks.append(' '.join(rest.split()))
                continue
            m = re.match(r"(\w+)\s+((?:ENUM|SET)\s*\([^)]*\)|\w+(?:\s*\([^)]*\))?)(.*)", p, re.S | re.I)
            if not m: continue
            cname, typ, rest = m.group(1), m.group(2), ' '.join(m.group(3).split())
            dm = re.search(r"DEFAULT\s+('[^']*'|\S+)", rest, re.I)
            cols[cname] = dict(type=typ, null=not ('NOT NULL' in rest.upper() or 'PRIMARY KEY' in rest.upper()),  # una PK nunca admite NULL
                               pk='PRIMARY KEY' in rest.upper(),
                               default=dm.group(1) if dm else None, auto='AUTO_INCREMENT' in rest.upper())
        out[name] = dict(cols=cols, uniq=uniq, fks=fks, checks=checks)
    likes = re.findall(r'CREATE TABLE\s+(\w+)\s+LIKE\s+(\w+)', text)
    return out, likes

def check_ddl(sec, text):
    ddl, likes = parse_ddl(text)
    expected = set(ddl) | {a for a, b in likes}
    for t in sorted(set(TABLES) - expected): R.e(sec, f'falta la tabla {t}')
    for t in sorted(expected - set(TABLES)): R.e(sec, f'tabla {t} no existe en la base')
    ncol = 0
    for t, d in ddl.items():
        if t not in COLS: continue
        if list(d['cols']) != list(COLS[t]):
            R.e(sec, f'{t}: columnas {list(d["cols"])} ≠ base {list(COLS[t])}'); continue
        for c, x in d['cols'].items():
            db = COLS[t][c]; ncol += 1
            if canon(x['type']) != canon(db['type']): R.e(sec, f'{t}.{c}: tipo {x["type"]} ≠ {db["type"]}')
            if x['null'] != db['null']: R.e(sec, f'{t}.{c}: NULL {x["null"]} ≠ {db["null"]}')
            if x['pk'] != (db['key'] == 'PRI'): R.e(sec, f'{t}.{c}: PK distinta')
            if canon_default(x['default'], x['type']) != canon_default(db['default'], db['type']):
                R.e(sec, f'{t}.{c}: DEFAULT {x["default"]} ≠ {db["default"]}')
            if (c in d['uniq']) != ((t, c) in UNIQ): R.e(sec, f'{t}.{c}: UNIQUE distinto')
        for c, (rt, rc, dr) in d['fks'].items():
            if FKS.get((t, c)) != (rt, rc, dr): R.e(sec, f'{t}.{c}: FK {rt}.{rc} ON DELETE {dr} ≠ base {FKS.get((t, c))}')
        for (tt, c) in FKS:
            if tt == t and c not in d['fks']: R.e(sec, f'{t}.{c}: falta la FOREIGN KEY')
        if len(d['checks']) != len(CHECKS[t]): R.e(sec, f'{t}: {len(d["checks"])} CHECK en el script, {len(CHECKS[t])} en la base')
    for a, b in likes:
        if a in COLS and b in COLS and list(COLS[a]) != list(COLS[b]): R.e(sec, f'{a} no tiene la misma estructura que {b}')
    R.ok(sec, f'{len(ddl)} CREATE TABLE + {len(likes)} LIKE · {ncol} columnas · {sum(len(d["fks"]) for d in ddl.values())} FK')
    return ddl

R.section('sql/01_ddl_schema.sql', 'DDL del esquema')
DDL = check_ddl('sql/01_ddl_schema.sql', rd('sql/01_ddl_schema.sql'))

R.section('tallerexamenbd.md (DDL incrustado)', 'copia del DDL en el documento de entrega')
tm = rd('tallerexamenbd.md')
blk = re.search(r'```(?:sql)?\n((?:(?!```).)*CREATE TABLE departments.*?)```', tm, re.S)
if not blk: R.e('tallerexamenbd.md (DDL incrustado)', 'no se encontró el bloque del DDL')
else:
    check_ddl('tallerexamenbd.md (DDL incrustado)', blk.group(1))
    norm = lambda s: re.sub(r'\s+', ' ', re.sub(r'--[^\n]*', '', s)).strip()
    a = norm(blk.group(1)); b = norm(rd('sql/01_ddl_schema.sql'))
    if a not in b and b not in a: R.w('tallerexamenbd.md (DDL incrustado)', 'el texto del bloque no es idéntico a sql/01_ddl_schema.sql (la estructura sí se comparó arriba)')

# ============================================================================ 2. scripts SQL 02..08
def strip_sql(s):
    s = re.sub(r'--[^\n]*', '', s); s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    return re.sub(r"'(?:[^'\\]|\\.|'')*'", "''", s)
for f in ['sql/02_dml_seed_data.sql', 'sql/03_part1_queries.sql', 'sql/04_part2_subqueries.sql', 'sql/05_part3_procedures.sql',
          'sql/06_part4_triggers.sql', 'sql/07_part5_functions.sql', 'sql/08_views_and_events.sql', 'tests/verify_solutions.sql']:
    sec = f; R.section(sec, 'referencias a tablas y columnas')
    s = strip_sql(rd(f)); n = 0
    # INSERT INTO tabla (col, ...)
    for t, cl in re.findall(r'INSERT\s+INTO\s+(\w+)\s*\(([^)]*)\)', s, re.I):
        if t in COLS:
            for c in (x.strip() for x in cl.split(',')):
                n += 1
                if c not in COLS[t]: R.e(sec, f'INSERT INTO {t}: la columna {c} no existe')
        elif t not in VIEWS and not t.startswith('tmp'): R.e(sec, f'INSERT INTO {t}: la tabla no existe')
    # UPDATE tabla [alias] SET col = ...
    for t, sets in re.findall(r'UPDATE\s+(\w+)(?:\s+\w+)?\s+SET\s+(.*?)(?:\bWHERE\b|;|\bEND\b)', s, re.I | re.S):
        if t not in COLS: continue
        for c in re.findall(r'(?:^|,)\s*(?:\w+\.)?(\w+)\s*=', sets):
            n += 1
            if c not in COLS[t]: R.e(sec, f'UPDATE {t} SET {c}: la columna no existe')
    # triggers: NEW./OLD. contra la tabla del trigger
    for body_t, body in re.findall(r'CREATE\s+TRIGGER\s+\w+\s+\w+\s+\w+\s+ON\s+(\w+)(.*?)END\s*\$\$', s, re.I | re.S):
        for c in set(re.findall(r'\b(?:NEW|OLD)\.(\w+)', body, re.I)):
            n += 1
            if body_t in COLS and c not in COLS[body_t]: R.e(sec, f'trigger ON {body_t}: NEW/OLD.{c} no existe')
    # alias.columna dentro de cada sentencia (alias definidos por FROM/JOIN tabla alias)
    for stmt in re.split(r';|\$\$', s):
        aliases = {}
        for t, a in re.findall(r'\b(?:FROM|JOIN|UPDATE|INTO)\s+(\w+)\s+(?:AS\s+)?(\w+)', stmt, re.I):
            if t in COLS and a.upper() not in ('ON', 'WHERE', 'SET', 'JOIN', 'LEFT', 'INNER', 'GROUP', 'ORDER', 'VALUES', 'SELECT', 'LIMIT', 'USING', 'RIGHT', 'CROSS', 'HAVING', 'UNION', 'AND', 'AS'):
                aliases[a] = t
        for t in re.findall(r'\b(?:FROM|JOIN)\s+(\w+)', stmt, re.I):
            if t in COLS: aliases.setdefault(t, t)
        for a, c in re.findall(r'\b(\w+)\.(\w+)\b', stmt):
            if a in aliases and a.upper() not in ('NEW', 'OLD'):
                n += 1
                if c not in COLS[aliases[a]]: R.e(sec, f'{a}.{c}: la columna {c} no existe en {aliases[a]}')
    R.ok(sec, f'{n} referencias a columnas comprobadas')

# ============================================================================ 3. diccionario de datos
sec = 'docs/03_diccionario_de_datos.md'; R.section(sec, 'tablas, columnas, tipos, NULL, claves y DEFAULT')
dic = rd('docs/03_diccionario_de_datos.md'); seen = []
for t, body in re.findall(r'^###\s+\d+\.\s+`(\w+)`[^\n]*\n(.*?)(?=^###|\Z)', dic, re.S | re.M):
    seen.append(t)
    if t not in COLS: R.e(sec, f'la tabla {t} no existe en la base'); continue
    rows = [[c.strip() for c in l.strip().strip('|').split('|')] for l in body.splitlines() if l.startswith('| `')]
    dcols = [r[0].strip('`') for r in rows]
    if dcols != list(COLS[t]):
        falt = [c for c in COLS[t] if c not in dcols]; sobr = [c for c in dcols if c not in COLS[t]]
        R.e(sec, f'{t}: columnas distintas' + (f' · faltan {falt}' if falt else '') + (f' · sobran {sobr}' if sobr else '') +
            ('' if falt or sobr else ' · orden distinto'))
    for r in rows:
        c = r[0].strip('`')
        if c not in COLS[t] or len(r) < 5: continue
        db = COLS[t][c]; typ, nul, key, dflt = r[1], r[2].upper(), r[3].upper(), r[4]
        if canon(typ) != canon(db['type']): R.e(sec, f'{t}.{c}: tipo {typ} ≠ {db["type"]}')
        if (nul in ('SI', 'SÍ', 'YES')) != db['null']: R.e(sec, f'{t}.{c}: Nulo={r[2]} pero en la base NULL={db["null"]}')
        if ('PK' in key) != (db['key'] == 'PRI'): R.e(sec, f'{t}.{c}: clave PK distinta')
        if ('FK' in key) != ((t, c) in FKS): R.e(sec, f'{t}.{c}: clave FK distinta')
        if ('UNIQUE' in key or 'UK' in key) != ((t, c) in UNIQ): R.e(sec, f'{t}.{c}: clave UNIQUE distinta')
        if dflt.upper() != 'CURRENT_USER' and canon_default(dflt, typ) != canon_default(db['default'], db['type']):
            R.e(sec, f'{t}.{c}: Default {dflt} ≠ {db["default"]}')
        elif dflt.upper() == 'CURRENT_USER':
            R.e(sec, f'{t}.{c}: Default CURRENT_USER ≠ {db["default"]}')
for t in TABLES:
    if t not in seen and not t.endswith('_backup'): R.e(sec, f'falta documentar la tabla {t}')
for t in TABLES:
    if t.endswith('_backup') and f'`{t}`' not in dic: R.e(sec, f'falta documentar la tabla de respaldo {t}')
R.ok(sec, f'{len(seen)} tablas documentadas')

# ============================================================================ 4. diagramas mermaid
MM_REL = re.compile(r'^\s*(\w+)\s+([|}o][|o])--([|o][|{o])\s+(\w+)\s*:\s*"?([^"\n]*)"?', re.M)
def mm_card(left, right):
    l = {'||': '1', '|o': '0..1', 'o|': '0..1', '}|': 'N', '}o': 'N'}.get(left, '?')
    r = {'||': '1', 'o|': '0..1', '|o': '0..1', '|{': 'N', 'o{': 'N'}.get(right, '?')
    return l, r
def check_mermaid_rels(sec, text, label_check=True):
    rels = MM_REL.findall(text); found = set()
    for a, l, r, b, lab in rels:
        a, b = a.lower(), b.lower()
        if a not in COLS: R.e(sec, f'entidad {a.upper()} no existe en la base'); continue
        if b not in COLS: R.e(sec, f'entidad {b.upper()} no existe en la base'); continue
        if (b, a) not in REL: R.e(sec, f'{a} → {b}: no existe esa llave foránea en la base'); continue
        found.add((b, a)); real = REL[(b, a)]
        cl, cr = mm_card(l, r)
        drawn = '1:N' if cr == 'N' else ('1:0..1' if cr == '0..1' else '1:1')
        if drawn != real and not (real == '1:1' and drawn == '1:0..1'):
            R.e(sec, f'{a} → {b}: dibujada como {drawn}, en la base es {real}')
        m = re.search(r'(\d|N)\s*:\s*(0\.\.1|\d|N)', lab)
        if label_check and m and m.group(0).replace(' ', '') not in (real, real.replace('0..1', '1')):
            R.e(sec, f'{a} → {b}: la etiqueta dice "{lab}", en la base es {real}')
    falt = sorted(set(REL) - found)
    if falt: R.e(sec, f'faltan {len(falt)} de {len(REL)} relaciones: ' + ', '.join(f'{p}→{c}' for c, p in falt))
    return found

sec = 'diagrams/physical_erd.mmd'; R.section(sec, 'DER físico: entidades, atributos, tipos, claves y relaciones')
pm = rd('diagrams/physical_erd.mmd'); ents = re.findall(r'^\s*(\w+)\s*\{(.*?)\}', pm, re.S | re.M)
for name, body in ents:
    t = name.lower()
    if t not in COLS: R.e(sec, f'entidad {name} no existe en la base'); continue
    attrs = [l.split() for l in body.strip().splitlines() if l.strip()]
    if not attrs: R.e(sec, f'{t}: la entidad está vacía (sin atributos)'); continue
    names = [a[1] for a in attrs]
    falt = [c for c in COLS[t] if c not in names]; sobr = [c for c in names if c not in COLS[t]]
    if falt: R.e(sec, f'{t}: faltan atributos {falt}')
    if sobr: R.e(sec, f'{t}: atributos que no existen {sobr}')
    for a in attrs:
        if a[1] not in COLS[t]: continue
        db = COLS[t][a[1]]
        rest = re.sub(r'"[^"]*"', '', ' '.join(a[2:])); keys = set(re.findall(r'\b(PK|FK|UK)\b', rest))
        if base(a[0]) != base(db['type']): R.e(sec, f'{t}.{a[1]}: tipo {a[0]} ≠ {db["type"]}')
        if ('PK' in keys) != (db['key'] == 'PRI'): R.e(sec, f'{t}.{a[1]}: PK distinta')
        if ('FK' in keys) != ((t, a[1]) in FKS): R.e(sec, f'{t}.{a[1]}: FK distinta')
        if ('UK' in keys) != ((t, a[1]) in UNIQ): R.e(sec, f'{t}.{a[1]}: UK distinta')
falt = [t for t in TABLES if t.upper() not in [n for n, _ in ents]]
if falt: R.e(sec, f'faltan {len(falt)} entidades: {", ".join(falt)}')
check_mermaid_rels(sec, pm)

sec = 'diagrams/logical_model.mmd'; R.section(sec, 'modelo lógico: entidades y relaciones')
check_mermaid_rels(sec, rd('diagrams/logical_model.mmd'), label_check=False)
lm_ents = {e.lower() for e in re.findall(r'^\s*(\w+)\s+[|}o]', rd('diagrams/logical_model.mmd'), re.M)} | \
          {e.lower() for e in re.findall(r'--\S+\s+(\w+)', rd('diagrams/logical_model.mmd'))}
falt = [t for t in TABLES if t not in lm_ents and not t.endswith('_backup') and t != 'audit_logs']
if falt: R.e(sec, f'faltan entidades: {falt}')

sec = 'README.md (diagrama mermaid)'; R.section(sec, 'DER del README: relaciones y cardinalidad')
rm = re.search(r'```mermaid\n(.*?)```', rd('README.md'), re.S)
if rm:
    check_mermaid_rels(sec, rm.group(1))
    for name, body in re.findall(r'^\s*(\w+)\s*\{(.*?)\}', rm.group(1), re.S | re.M):
        t = name.lower()
        for a in (l.split() for l in body.strip().splitlines() if l.strip()):
            if t in COLS and a[1] in COLS[t] and base(a[0]) != base(COLS[t][a[1]]['type']):
                R.e(sec, f'{t}.{a[1]}: tipo {a[0]} ≠ {COLS[t][a[1]]["type"]}')

# ============================================================================ 5. modelos conceptuales
CONCEPT = {  # palabra clave del concepto -> tabla
    'ESPECIALIDAD': 'specialties', 'PROFESIONAL': 'healthcare_professionals', 'UBICACI': 'cities', 'TIPO DE DOCUMENTO': 'document_types',
    'PACIENTE': 'patients', 'HISTORIA': 'clinical_histories', 'ANTECEDENTES': 'patient_antecedents', 'ARCHIVOS': 'clinical_documents',
    'CONSULTA': 'medical_visits', 'DIAGN': 'diagnoses', 'TRATAMIENTO': 'treatments', 'MEDICAMENTO': 'medications',
    'PROCEDIMIENTO': 'procedures', 'PRESI': 'intraocular_pressures', 'PIO': 'intraocular_pressures', 'PAQUIMETR': 'pachymetry_exams',
    'GONIOSCOP': 'gonioscopy_exams', 'OCT': 'oct_exams', 'CAMPO': 'visual_field_exams', 'REGISTRO': 'glaucoma_records',
    'CONTROL': 'glaucoma_controls', 'BIT': 'audit_logs', 'EXAMEN': None}
def concept_of(label):
    u = re.split(r'\n|\\n|\(', label)[0].upper()   # solo el título del concepto, no su descripción
    for k in ['CONTROL', 'REGISTRO', 'TIPO DE DOCUMENTO', 'MEDICAMENTO', 'TRATAMIENTO', 'PROCEDIMIENTO', 'PAQUIMETR', 'GONIOSCOP',
              'CAMPO', 'OCT', 'PIO', 'PRESI', 'EXAMEN', 'ESPECIALIDAD', 'PROFESIONAL', 'UBICACI', 'ANTECEDENTES', 'ARCHIVOS',
              'HISTORIA', 'CONSULTA', 'DIAGN', 'PACIENTE', 'BIT']:
        if k in u: return k, CONCEPT[k]
    return None, None
def check_concept_rel(sec, a_lab, b_lab, card):
    ka, ta = concept_of(a_lab); kb, tb = concept_of(b_lab)
    if not ta or not tb: return
    real = REL.get((tb, ta)) or REL.get((ta, tb))
    if ta == 'medical_visits' and tb == 'diagnoses':
        if card and card.replace(' ', '') != 'N:M': R.e(sec, f'{ka} – {kb}: dice {card}, es N:M (se resuelve con visit_diagnoses)')
        return
    if not real:
        if {ta, tb} & {'patient_antecedents'}: return
        R.w(sec, f'{ka} – {kb}: no hay llave foránea directa entre {ta} y {tb}'); return
    if card:
        c = card.replace(' ', '')
        if c != real and not (real == '1:0..1' and c == '1:1') and not (real == '1:1' and c == '1:1'):
            R.e(sec, f'{ka} – {kb}: dice {card}, en la base es {real}')

sec = 'diagrams/conceptual_model.mmd'; R.section(sec, 'modelo conceptual (flowchart): cardinalidades')
cm = rd('diagrams/conceptual_model.mmd'); labels = dict(re.findall(r'^\s*(\w+)\["([^"]*)"\]', cm, re.M))
for a, card, b in re.findall(r'^\s*(\w+)\s*-->\s*(?:\|"([^"]*)"\|)?\s*(\w+)', cm, re.M):
    m = re.search(r'(\d|N)\s*:\s*(0\.\.1|\d|N|M)', card or '')
    check_concept_rel(sec, labels.get(a, a), labels.get(b, b), m.group(0) if m else '')

sec = 'diagrams/modelo_conceptual.drawio'; R.section(sec, 'modelo conceptual (draw.io): cardinalidades')
dw = rd('diagrams/modelo_conceptual.drawio')
cells = {i: htmlmod.unescape(v) for i, v in re.findall(r'<mxCell id="([^"]+)" value="([^"]*)"', dw)}
for m in re.finditer(r'<mxCell id="[^"]+" value="([^"]*)"[^>]*source="([^"]+)" target="([^"]+)"', dw):
    lab, s_, t_ = htmlmod.unescape(m.group(1)), m.group(2), m.group(3)
    mm = re.search(r'(\d|N)\s*:\s*(0\.\.1|\d|N|M)', lab)
    check_concept_rel(sec, cells.get(s_, ''), cells.get(t_, ''), mm.group(0) if mm else '')

# ============================================================================ 6. exportaciones SVG de StarUML
# Cada SVG se compara con su diagrama del .mdj (mismo nombre) y con la base: entidades que debe mostrar,
# cada columna en orden con su tipo exacto y sus marcas (PK, FK, U = UNIQUE, N = admite NULL) y los verbos de las relaciones.
import unicodedata
slugify = lambda n: re.sub(r'[^a-z0-9]+', '_', unicodedata.normalize('NFD', n).encode('ascii', 'ignore').decode().lower()).strip('_')
MDJ = json.load(open(os.path.join(ROOT, 'diagrams', 'oftalmologia_model.mdj'), encoding='utf-8'))
MBYID = {}
def _ix(o):
    if isinstance(o, dict):
        if '_id' in o: MBYID[o['_id']] = o
        for v in o.values(): _ix(v)
    elif isinstance(o, list):
        for v in o: _ix(v)
_ix(MDJ)
MDIAG = {slugify(d['name']): d for d in MBYID.values() if d.get('_type') == 'ERDDiagram'}
KEYTOK = re.compile(r'^(PK|FK|N|U)(,(PK|FK|N|U))*$')
EXPDIR = os.path.join(ROOT, 'diagrams', 'exportaciones_staruml')
exp_files = os.listdir(EXPDIR) if os.path.isdir(EXPDIR) else []
svgs = sorted(['diagrams/' + x for x in os.listdir(os.path.join(ROOT, 'diagrams')) if x.endswith('.svg')] +
              ['diagrams/exportaciones_staruml/' + x for x in exp_files if x.endswith('.svg')])
pngs = [x for x in exp_files if x.endswith('.png')]
for f in svgs:
    sec = f; R.section(sec, 'exportación SVG de StarUML: entidades, atributos, tipos, claves y relaciones')
    stem = os.path.splitext(os.path.basename(f))[0]
    d = MDIAG.get(stem)
    if not d: R.e(sec, f'no corresponde a ningún diagrama del .mdj (nombres: {sorted(MDIAG)})'); continue
    expected = [MBYID[v['model']['$ref']]['name'] for v in d['ownedViews'] if v['_type'] == 'ERDEntityView']
    verbs = collections.Counter(MBYID[v['model']['$ref']]['name'] for v in d['ownedViews'] if v['_type'] == 'ERDRelationshipView')
    txt = [htmlmod.unescape(x).strip() for x in re.findall(r'>([^<>]+)</text>', rd(f))]
    txt = [x for x in txt if x and x != 'UNREGISTERED']
    found = {}
    i = 0
    while i < len(txt):
        x = txt[i]
        if x in COLS and x in expected and x not in found:
            cols = []; i += 1
            while i < len(txt):
                key = ''
                if KEYTOK.match(txt[i]) and i + 1 < len(txt) and txt[i + 1] in COLS[x]: key = txt[i]; i += 1
                if txt[i] in COLS[x] and i + 1 < len(txt) and txt[i] not in [c for c, _, _ in cols]:
                    cols.append((txt[i], txt[i + 1], key)); i += 2
                else:
                    break
            found[x] = cols
        else:
            i += 1
    for t in expected:
        if t not in found: R.e(sec, f'falta la entidad {t}'); continue
        cols = found[t]
        if [c for c, _, _ in cols] != list(COLS[t]):
            R.e(sec, f'{t}: columnas {[c for c, _, _ in cols]} ≠ base {list(COLS[t])}'); continue
        for c, typ, key in cols:
            db = COLS[t][c]; ks = set(key.split(',')) if key else set()
            if canon(typ) != canon(db['type']): R.e(sec, f'{t}.{c}: tipo {typ} ≠ {db["type"]}')
            if ('PK' in ks) != (db['key'] == 'PRI'): R.e(sec, f'{t}.{c}: marca PK distinta ({key or "sin marca"})')
            if ('FK' in ks) != ((t, c) in FKS): R.e(sec, f'{t}.{c}: marca FK distinta ({key or "sin marca"})')
            if db['key'] != 'PRI' and ('N' in ks) != db['null']: R.e(sec, f'{t}.{c}: marca N (NULL) distinta ({key or "sin marca"})')
            if db['key'] != 'PRI' and ('U' in ks) != ((t, c) in UNIQ): R.e(sec, f'{t}.{c}: marca U (UNIQUE) distinta ({key or "sin marca"})')
    shown = collections.Counter(x for x in txt if x in verbs)
    for v, n in verbs.items():
        if shown[v] < n: R.e(sec, f'la relación «{v}» aparece {shown[v]} de {n} veces')
    R.ok(sec, f'{len(found)} entidades · {sum(len(c) for c in found.values())} columnas · {sum(verbs.values())} relaciones')
    if stem + '.png' not in pngs and 'exportaciones_staruml' in f: R.w(sec, f'no hay PNG {stem}.png que acompañe al SVG')
for d in MDIAG:
    if os.path.isdir(os.path.join(ROOT, 'diagrams', 'exportaciones_staruml')) and not any(os.path.basename(x).startswith(d + '.') for x in svgs):
        R.section(f'diagrams/exportaciones_staruml/{d}.svg', 'exportación SVG de StarUML'); R.e(f'diagrams/exportaciones_staruml/{d}.svg', 'falta exportar este diagrama')

# ============================================================================ 7. datos del modelo ER HTML
sec = 'diagrams/generador_modelo_er.py → modelo_entidad_relacion.html'; R.section(sec, 'datos del modelo ER interactivo')
import importlib.util
spec = importlib.util.spec_from_file_location('m', os.path.join(ROOT, 'diagrams', 'generador_modelo_er.py'))
gm = importlib.util.module_from_spec(spec); spec.loader.exec_module(gm)
for t in TABLES:
    if t not in gm.T: R.e(sec, f'falta la tabla {t}'); continue
    mc = gm.T[t]['cols']
    if [c['name'] for c in mc] != list(COLS[t]): R.e(sec, f'{t}: columnas distintas'); continue
    for c in mc:
        db = COLS[t][c['name']]; keys = c['key'].split()
        if canon(c['type']) != canon(db['type']): R.e(sec, f'{t}.{c["name"]}: tipo {c["type"]} ≠ {db["type"]}')
        if c['null'] != db['null']: R.e(sec, f'{t}.{c["name"]}: NULL distinto')
        if ('PK' in keys) != (db['key'] == 'PRI') or ('FK' in keys) != ((t, c['name']) in FKS) or ('UK' in keys) != ((t, c['name']) in UNIQ):
            R.e(sec, f'{t}.{c["name"]}: claves {keys} distintas a la base')
        dflt = c['default'].replace(' ON UPDATE', '')
        if canon_default(dflt, c['type']) != canon_default(db['default'], db['type']): R.e(sec, f'{t}.{c["name"]}: DEFAULT {c["default"]} ≠ {db["default"]}')
gfk = {(ch, c): (p, 'id', od) for ch, c, p, v, od in gm.FKS}
if gfk != FKS: R.e(sec, f'llaves foráneas distintas: {set(gfk.items()) ^ set(FKS.items())}')
R.ok(sec, f'{len(gm.T)} tablas · {sum(len(x["cols"]) for x in gm.T.values())} columnas · {len(gm.FKS)} FK')

# ---------------------------------------------------------------------------- 7b. contenido del HTML generado
def check_er_html(sec, page):
    """Revisa lo que realmente muestra la página: explorador (JSON), modelo lógico, DER, Chen y tabla de relaciones."""
    m = re.search(r'<script id="xp-data" type="application/json">(.*?)</script>', page, re.S)
    if not m: R.e(sec, 'no se encontraron los datos del explorador'); return
    data = json.loads(m.group(1).replace('<\\/', '</'))
    xt = {t['name']: t for t in data['tables']}
    for t in TABLES:
        if t not in xt: R.e(sec, f'explorador: falta la tabla {t}'); continue
        cols = xt[t]['cols']
        if [c['name'] for c in cols] != list(COLS[t]): R.e(sec, f'explorador: {t} tiene columnas distintas'); continue
        for c in cols:
            db = COLS[t][c['name']]
            if canon(c['type']) != canon(db['type']): R.e(sec, f'explorador: {t}.{c["name"]} tipo {c["type"]} ≠ {db["type"]}')
            if c['null'] != db['null']: R.e(sec, f'explorador: {t}.{c["name"]} NULL distinto')
            if ('FK' in c['keys']) != ((t, c['name']) in FKS) or ('PK' in c['keys']) != (db['key'] == 'PRI') or ('UK' in c['keys']) != ((t, c['name']) in UNIQ):
                R.e(sec, f'explorador: {t}.{c["name"]} claves {c["keys"]} distintas')
        refs = {(t, r['col'], r['to']) for r in xt[t]['refs']}
        want = {(t, c, rt) for (tt, c), (rt, rc, dr) in FKS.items() if tt == t}
        if refs != want: R.e(sec, f'explorador: {t} referencias {sorted(refs ^ want)} distintas')
    for t in set(xt) - set(TABLES): R.e(sec, f'explorador: tabla {t} no existe en la base')
    # modelo lógico: una ficha por tabla con fila (atributo, tipo, nulo)
    for t in TABLES:
        a = re.search(rf'<article class="tcard" id="t-{t}">(.*?)</article>', page, re.S)
        if not a: R.e(sec, f'modelo lógico: falta la ficha de {t}'); continue
        rows = re.findall(r'<tr><td class="mono">(\w+)</td><td class="mono t">([^<]*)</td><td>(Sí|No)</td>', a.group(1))
        if [r[0] for r in rows] != list(COLS[t]): R.e(sec, f'modelo lógico: {t} columnas distintas'); continue
        for c, typ, nul in rows:
            typ = htmlmod.unescape(typ)
            if canon(typ) != canon(COLS[t][c]['type']): R.e(sec, f'modelo lógico: {t}.{c} tipo {typ} ≠ {COLS[t][c]["type"]}')
            if (nul == 'Sí') != COLS[t][c]['null']: R.e(sec, f'modelo lógico: {t}.{c} NULL distinto')
    # DER y Chen: cada tabla aparece como entidad en su módulo, y el DER lista todas sus columnas
    der = ''.join(re.findall(r'<section class="pane" data-kind="der".*?</section>', page, re.S))
    chen = ''.join(re.findall(r'<section class="pane" data-kind="chen".*?</section>', page, re.S))
    for t in TABLES:
        if f"data-t='{t}'" not in der: R.e(sec, f'DER: falta la tabla {t}')
        if f"data-t='{t}'" not in chen: R.e(sec, f'modelo conceptual: falta la entidad {t}')
        pane = re.search(rf'<section class="pane" data-kind="der" data-mod="{xt[t]["mod"]}".*?</section>', page, re.S) if t in xt else None
        if pane:
            missing = [c for c in COLS[t] if f'>{c}<' not in pane.group(0) and f'>{c}<tspan' not in pane.group(0)]
            if missing: R.e(sec, f'DER: a {t} le faltan las columnas {missing}')
    # tabla de las 25 relaciones del mapa general
    fk_rows = re.findall(r'data-t="(\w+)">\w+</button></td><td>[^<]*</td><td class="mono"><button type="button" class="xlink" data-t="(\w+)">\w+</button>\.<span class="fkc">(\w+)</span>', page)
    got = {(ch, c, p) for p, ch, c in fk_rows}; want = {(t, c, rt) for (t, c), (rt, rc, dr) in FKS.items()}
    if got != want: R.e(sec, f'mapa general: relaciones distintas {sorted(got ^ want)}')
    R.ok(sec, f'{len(xt)} tablas en el explorador · {len(fk_rows)} relaciones en el mapa')

sec = 'diagrams/modelo_entidad_relacion.html'; R.section(sec, 'página ER: explorador, modelo lógico, DER, Chen y relaciones')
check_er_html(sec, rd('diagrams/modelo_entidad_relacion.html'))
for extra in sys.argv[1:]:
    if extra.endswith('.html') and os.path.exists(extra):   # p. ej. la copia descargada del artefacto publicado
        sec = f'artefacto publicado ({os.path.basename(extra)})'; R.section(sec, 'página publicada en claude.ai')
        check_er_html(sec, open(extra, encoding='utf-8').read().replace('\r\n', '\n'))

# ============================================================================ 8. textos: nombres de tabla y rangos CHECK
KNOWN = set(TABLES) | set(VIEWS) | ALLCOLS
for f in ['docs/02_proceso_normalizacion_4fn.md', 'docs/04_guia_ejecucion_pruebas.md', 'README.md', 'AGENTS.md', 'docs/01_planteamiento_problema.md']:
    sec = f + ' (texto)'; R.section(sec, 'tablas citadas y rangos de CHECK descritos')
    s = rd(f)
    for name in sorted(set(re.findall(r'`([a-z][a-z0-9]*(?:_[a-z0-9]+)+)`', s))):
        if name in KNOWN or name.startswith(('sp_', 'fn_', 'trg_', 'vw_', 'v_', 'ev_', 'idx_', 'uq_', 'fk_', 'chk_')) or '.' in name: continue
        if re.search(r'(antecedents|histories|allergies|records|controls|exams|visits|patients|documents|logs|types|diagnoses|_id)$', name):
            R.e(sec, f'menciona `{name}`, que no existe como tabla ni columna')
    for m in re.finditer(r'PIO entre ([\d.]+) y ([\d.]+)', s):
        R.e(sec, f'dice "PIO entre {m.group(1)} y {m.group(2)} mmHg"; el CHECK real es pressure > 0 AND pressure <= 80')
    for m in re.finditer(r'espesor corneal entre (\d+) y (\d+)', s):
        R.e(sec, f'dice "espesor corneal entre {m.group(1)} y {m.group(2)}"; el CHECK real es corneal_thickness > 0 AND <= 1000')
    for m in re.finditer(r"performed_by VARCHAR\(100\) DEFAULT '(\w+)'", s):
        if m.group(1) != (COLS['audit_logs']['performed_by']['default'] or ''): R.e(sec, f'DEFAULT de performed_by {m.group(1)} ≠ base')

# ============================================================================ 9. modelo StarUML
sec = 'diagrams/oftalmologia_model.mdj'; R.section(sec, 'modelo lógico StarUML (tests/validar_modelo_staruml.py)')
r = subprocess.run([sys.executable, os.path.join(ROOT, 'tests', 'validar_modelo_staruml.py')], capture_output=True)
out = r.stdout.decode('utf-8', 'replace')
if r.returncode == 0: R.ok(sec, out.strip().splitlines()[-1])
else: [R.e(sec, l.strip(' -')) for l in out.splitlines() if l.startswith(' -')]

# ============================================================================ informe
print(f'Fuente de verdad: base {DB} ({MODE}) · {len(TABLES)} tablas · {sum(len(c) for c in COLS.values())} columnas · {len(FKS)} FK · '
      f'{sum(len(c) for c in CHECKS.values())} CHECK · {len(VIEWS)} vistas\n')
tot_e = 0
for name, it in R.items.items():
    st = 'OK   ' if not it['err'] else 'ERROR'
    tot_e += len(it['err'])
    print(f'[{st}] {name:58s} {len(it["err"]):3d} errores' + (f' · {len(it["warn"])} avisos' if it['warn'] else ''))
    if not RESUMEN:
        for x in it['err']: print('        ✗', x)
        for x in it['warn']: print('        !', x)
print(f'\nTotal: {tot_e} errores en {sum(1 for it in R.items.values() if it["err"])} de {len(R.items)} artefactos.')
sys.exit(1 if tot_e else 0)
