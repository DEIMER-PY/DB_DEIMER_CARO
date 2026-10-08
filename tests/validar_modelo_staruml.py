# -*- coding: utf-8 -*-
"""Valida diagrams/oftalmologia_model.mdj contra el esquema real de MySQL (el mismo que muestra phpMyAdmin).

Uso (desde la raíz del proyecto, con la base ya desplegada por tests/run_all.*):
    python tests/validar_modelo_staruml.py [ruta.mdj]

Conexión: igual que run_all (variables MYSQL_MODE=auto|local|docker, MYSQL_CONTAINER, MYSQL_HOST,
MYSQL_PORT, MYSQL_USER, MYSQL_PASS, MYSQL_DB). En modo auto usa el cliente mysql local si existe y,
si no, ejecuta el cliente dentro del contenedor con docker exec.

Comprueba:
  1. Entidades: mismas tablas que la base (sin faltantes ni sobrantes).
  2. Atributos: mismo nombre y orden, tipo y longitud, NULL, PK, UNIQUE de una columna y FK.
  3. Llaves foráneas: cada FK tiene referenceTo hacia la PK correcta y una ERDRelationship cuyos
     extremos son la tabla padre (cardinalidad 1) y la hija (0..1 si la FK es UNIQUE, si no 0..*).
  4. Diagramas: cada relación dibujada une las vistas de sus dos entidades dentro del mismo diagrama;
     el diagrama completo dibuja las 25 relaciones y cada diagrama de módulo dibuja las suyas.
Sale con código 1 si encuentra algún error.
"""
import json, os, shutil, subprocess, sys, collections

sys.stdout.reconfigure(encoding='utf-8', errors='replace')   # la consola de Windows usa cp1252

MDJ = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', 'diagrams', 'oftalmologia_model.mdj')
ENV = lambda k, d: os.environ.get(k) or d
USER, PASS, DB = ENV('MYSQL_USER', 'root'), ENV('MYSQL_PASS', 'root2026'), ENV('MYSQL_DB', 'oftalmologia_glaucoma_db')
MODE = ENV('MYSQL_MODE', 'auto')
if MODE == 'auto':
    MODE = 'local' if shutil.which('mysql') else 'docker'

def q(sql):
    base = ['mysql', '--default-character-set=utf8mb4', '-u', USER, '-N', '-B', 'information_schema', '-e', sql]
    env = dict(os.environ, MYSQL_PWD=PASS, MSYS_NO_PATHCONV='1')
    if MODE == 'docker':
        cmd = ['docker', 'exec', '-e', 'MYSQL_PWD=' + PASS, ENV('MYSQL_CONTAINER', 'mysql_db')] + base
    else:
        cmd = base[:1] + ['-h', ENV('MYSQL_HOST', '127.0.0.1'), '-P', ENV('MYSQL_PORT', '3307')] + base[1:]
    out = subprocess.run(cmd, capture_output=True, env=env, check=True).stdout.decode('utf-8')
    return [line.split('\t') for line in out.splitlines() if line]

errors = []
def err(msg): errors.append(msg)

# ----------------------------------------------------------------------------- esquema real
W = f"TABLE_SCHEMA='{DB}'"
tables = [r[0] for r in q(f"SELECT TABLE_NAME FROM TABLES WHERE {W} AND TABLE_TYPE='BASE TABLE' ORDER BY 1")]
dbcols = collections.defaultdict(list)
for t, c, ctype, nul, key in q(f"SELECT c.TABLE_NAME,c.COLUMN_NAME,c.COLUMN_TYPE,c.IS_NULLABLE,c.COLUMN_KEY FROM COLUMNS c "
                               f"JOIN TABLES t ON t.TABLE_SCHEMA=c.TABLE_SCHEMA AND t.TABLE_NAME=c.TABLE_NAME "
                               f"WHERE c.{W} AND t.TABLE_TYPE='BASE TABLE' ORDER BY c.TABLE_NAME,c.ORDINAL_POSITION"):
    dbcols[t].append(dict(name=c, type=ctype.upper(), null=nul == 'YES', pk=key == 'PRI'))
uniq = set()   # (tabla, columna) con índice UNIQUE de una sola columna
for t, cols in q(f"SELECT TABLE_NAME,GROUP_CONCAT(COLUMN_NAME) FROM STATISTICS WHERE {W} AND NON_UNIQUE=0 "
                 f"AND INDEX_NAME<>'PRIMARY' GROUP BY TABLE_NAME,INDEX_NAME"):
    if ',' not in cols: uniq.add((t, cols))
fks = {(t, c): (rt, rc, dr) for t, c, rt, rc, dr in q(
    f"SELECT k.TABLE_NAME,k.COLUMN_NAME,k.REFERENCED_TABLE_NAME,k.REFERENCED_COLUMN_NAME,r.DELETE_RULE FROM KEY_COLUMN_USAGE k "
    f"JOIN REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND r.CONSTRAINT_NAME=k.CONSTRAINT_NAME "
    f"WHERE k.{W} AND k.REFERENCED_TABLE_NAME IS NOT NULL")}

# ----------------------------------------------------------------------------- modelo StarUML
P = json.load(open(MDJ, encoding='utf-8'))
byid = {}
def index(o):
    if isinstance(o, dict):
        if '_id' in o: byid[o['_id']] = o
        for v in o.values(): index(v)
    elif isinstance(o, list):
        for v in o: index(v)
index(P)
R = lambda r: byid.get(r['$ref']) if isinstance(r, dict) and '$ref' in r else None
for o in list(byid.values()):   # referencias rotas
    for k, v in o.items():
        if isinstance(v, dict) and set(v) == {'$ref'} and v['$ref'] not in byid:
            err(f"referencia rota: {o.get('_type')} {o.get('name', o['_id'])}.{k}")
of = lambda t: [o for o in byid.values() if o.get('_type') == t]
ents = {e['name']: e for e in of('ERDEntity')}

# 1. entidades
for t in sorted(set(tables) - set(ents)): err(f'falta la entidad {t}')
for t in sorted(set(ents) - set(tables)): err(f'entidad sobrante (no existe en la base): {t}')

# 2. atributos
def mdj_type(c):
    t = c.get('type', '').upper()
    return f"{t}({c['length']})" if c.get('length') else t
def norm_db(t):
    t = t.replace('TINYINT(1)', 'BOOLEAN')
    return t.replace("','", "','")
ncols = 0
for t in tables:
    if t not in ents: continue
    mc = ents[t]['columns']; dc = dbcols[t]
    if [c['name'] for c in mc] != [c['name'] for c in dc]:
        err(f'{t}: columnas distintas\n    base:   {[c["name"] for c in dc]}\n    modelo: {[c["name"] for c in mc]}'); continue
    for a, b in zip(mc, dc):
        ncols += 1
        where = f'{t}.{b["name"]}'
        if mdj_type(a).replace(' ', '') != norm_db(b['type']).replace(' ', ''): err(f'{where}: tipo {mdj_type(a)} ≠ {b["type"]} en la base')
        if bool(a.get('nullable')) != b['null']: err(f'{where}: NULL {bool(a.get("nullable"))} ≠ {b["null"]} en la base')
        if bool(a.get('primaryKey')) != b['pk']: err(f'{where}: PK {bool(a.get("primaryKey"))} ≠ {b["pk"]} en la base')
        if bool(a.get('unique')) != ((t, b['name']) in uniq): err(f'{where}: UNIQUE {bool(a.get("unique"))} ≠ {(t, b["name"]) in uniq} en la base')
        isfk = (t, b['name']) in fks
        if bool(a.get('foreignKey')) != isfk: err(f'{where}: FK {bool(a.get("foreignKey"))} ≠ {isfk} en la base')
        if isfk:
            rt, rc, _ = fks[(t, b['name'])]
            tgt = R(a.get('referenceTo') or {})
            if not tgt or tgt['name'] != rc or R(tgt['_parent'])['name'] != rt:
                err(f'{where}: referenceTo no apunta a {rt}.{rc}')

# 3. relaciones
rels = of('ERDRelationship')
pairs = collections.Counter()
for r in rels:
    p, c = R(r['end1']['reference']), R(r['end2']['reference'])
    if not p or not c: err(f'relación {r.get("name")} con un extremo sin entidad'); continue
    pairs[(c['name'], p['name'])] += 1
    if r['end1'].get('cardinality') != '1': err(f'{p["name"]}→{c["name"]}: el extremo padre debe ser 1')
fk_pairs = collections.Counter((t, rt) for (t, c), (rt, rc, dr) in fks.items())
for k in sorted(set(fk_pairs) | set(pairs)):
    if fk_pairs[k] != pairs[k]: err(f'FK {k[0]} → {k[1]}: {fk_pairs[k]} en la base, {pairs[k]} relaciones en el modelo')
for (t, col), (rt, rc, dr) in fks.items():
    want = '0..1' if (t, col) in uniq else '0..*'
    got = [r['end2'].get('cardinality') for r in rels if R(r['end2']['reference'])['name'] == t and R(r['end1']['reference'])['name'] == rt]
    if want not in got: err(f'{t}.{col} → {rt}: cardinalidad esperada 1 : {want}, modelo {got}')

# 4. diagramas
for d in of('ERDDiagram'):
    views = d.get('ownedViews', [])
    ev = {v['_id']: R(v['model'])['name'] for v in views if v['_type'] == 'ERDEntityView'}
    drawn = set()
    for v in views:
        if v['_type'] != 'ERDRelationshipView': continue
        r = R(v['model']); h, tl = v.get('head', {}).get('$ref'), v.get('tail', {}).get('$ref')
        if not r: err(f'{d["name"]}: hay una línea que no corresponde a ninguna relación del modelo'); continue
        p, c = R(r['end1']['reference'])['name'], R(r['end2']['reference'])['name']
        if h not in ev or tl not in ev: err(f'{d["name"]}: la línea {p}→{c} no está unida a dos entidades del diagrama'); continue
        if ev[tl] != p or ev[h] != c: err(f'{d["name"]}: la línea {r["name"]} une {ev[tl]}→{ev[h]} pero la relación es {p}→{c}')
        drawn.add(r['_id'])
    # toda relación cuyas dos entidades están en el diagrama debe estar dibujada
    names = set(ev.values())
    for r in rels:
        p, c = R(r['end1']['reference'])['name'], R(r['end2']['reference'])['name']
        if p in names and c in names and r['_id'] not in drawn:
            err(f'{d["name"]}: falta dibujar la relación {p} → {c}')

print(f"Base {DB} ({MODE}): {len(tables)} tablas · {sum(len(v) for v in dbcols.values())} columnas · {len(fks)} FK")
print(f"Modelo {os.path.basename(MDJ)}: {len(ents)} entidades · {ncols} columnas comparadas · {len(rels)} relaciones · {len(of('ERDDiagram'))} diagramas")
if errors:
    print(f'\n{len(errors)} errores:'); [print(' -', e) for e in errors]; sys.exit(1)
print('OK: entidades, atributos, claves, relaciones y diagramas coinciden con la base de datos.')
