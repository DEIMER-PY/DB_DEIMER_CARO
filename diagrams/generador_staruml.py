# -*- coding: utf-8 -*-
"""Genera el modelo lógico nativo de StarUML (.mdj) a partir de los mismos datos del modelo ER.

Uso (desde la raíz del proyecto):
    python diagrams/generador_staruml.py diagrams/oftalmologia_model.mdj

Toma tablas, columnas y llaves foráneas de diagrams/generador_modelo_er.py (T, FKS, MODS, DER_LAYOUT),
que reflejan sql/01_ddl_schema.sql. Produce:
  - un ERDDataModel con 29 ERDEntity (25 relacionales + 4 de respaldo) y sus ERDColumn
    (tipo, longitud, PK, FK con referenceTo, UNIQUE, NULL y documentación),
  - 25 ERDRelationship con cardinalidad 1 : 0..* o 1 : 0..1,
  - un diagrama completo y un diagrama por módulo.
"""
import importlib.util, json, os, re, sys

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('modelo', os.path.join(here, 'generador_modelo_er.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
T, FKS, MODS, DER_LAYOUT = m.T, m.FKS, m.MODS, m.DER_LAYOUT

_n = [0]
def nid():
    _n[0] += 1
    return 'AAAAAAGer' + format(_n[0], '012d') + '='
ref = lambda x: {'$ref': x}

def split_type(t):
    """'VARCHAR(100)' -> ('VARCHAR', '100'); 'DECIMAL(5,2)' -> ('DECIMAL', '5,2'); 'BIGINT AUTO_INCREMENT' -> ('BIGINT', '')."""
    t = t.replace(' AUTO_INCREMENT', '')
    mt = re.match(r"^(\w+)\((.*)\)$", t)
    return (mt.group(1), mt.group(2)) if mt else (t, '')

# ----------------------------------------------------------------------------- modelo
project = {'_type': 'Project', '_id': nid(), 'name': 'TALLERDB_DEIMER_CARO', 'ownedElements': []}
dm = {'_type': 'ERDDataModel', '_id': nid(), '_parent': ref(project['_id']), 'name': 'oftalmologia_glaucoma_db',
      'documentation': 'Modelo lógico de la base de datos MySQL 8.0 oftalmologia_glaucoma_db (4FN). '
                       'Generado desde sql/01_ddl_schema.sql con diagrams/generador_staruml.py.',
      'ownedElements': []}
project['ownedElements'].append(dm)

ent, col = {}, {}
for name, t in T.items():
    e = {'_type': 'ERDEntity', '_id': nid(), '_parent': ref(dm['_id']), 'name': name,
         'documentation': t['desc'] + ('\n\nRestricciones:\n- ' + '\n- '.join(t['cons']) if t['cons'] else ''),
         'columns': []}
    for c in t['cols']:
        typ, length = split_type(c['type'])
        keys = c['key'].split()
        doc = c['desc']
        if 'AUTO_INCREMENT' in c['type']: doc += ' · AUTO_INCREMENT'
        if c['default']: doc += ' · DEFAULT ' + c['default']
        cj = {'_type': 'ERDColumn', '_id': nid(), '_parent': ref(None), 'name': c['name'], 'documentation': doc, 'type': typ}
        cj['_parent'] = ref(e['_id'])
        if length: cj['length'] = length
        if 'PK' in keys: cj['primaryKey'] = True
        if 'FK' in keys: cj['foreignKey'] = True
        if 'UK' in keys: cj['unique'] = True
        if c['null']: cj['nullable'] = True
        e['columns'].append(cj); col[(name, c['name'])] = cj
    ent[name] = e; dm['ownedElements'].append(e)

# referencias FK -> PK
for ch, c, p, verb, od in FKS:
    col[(ch, c)]['referenceTo'] = ref(col[(p, 'id')]['_id'])

rels = []
for ch, c, p, verb, od in FKS:
    uniq = m.is_unique_fk(ch, c)
    r = {'_type': 'ERDRelationship', '_id': nid(), '_parent': ref(ent[ch]['_id']), 'name': verb, 'identifying': False,
         'documentation': f'FOREIGN KEY {ch}.{c} REFERENCES {p}(id) ON UPDATE CASCADE ON DELETE {od}'}
    r['end1'] = {'_type': 'ERDRelationshipEnd', '_id': nid(), '_parent': ref(r['_id']), 'reference': ref(ent[p]['_id']), 'cardinality': '1'}
    r['end2'] = {'_type': 'ERDRelationshipEnd', '_id': nid(), '_parent': ref(r['_id']), 'reference': ref(ent[ch]['_id']),
                 'cardinality': '0..1' if uniq else '0..*'}
    ent[ch].setdefault('ownedElements', []).append(r)
    rels.append((ch, p, r))

# ----------------------------------------------------------------------------- vistas
CH = 8.8   # ancho de un carácter Arial 13 (con margen: StarUML nunca reduce una caja por debajo de su contenido)
def size_of(name):
    cols = T[name]['cols']
    def tstr(c):
        typ, length = split_type(c['type']); return typ + (f'({length})' if length else '')
    keyw = max(len(('PK' if 'PK' in c['key'] else '') + (',FK' if 'FK' in c['key'] else '')) for c in cols) + 4
    namew = max(len(c['name']) for c in cols); typew = max(len(tstr(c)) for c in cols)
    w = max(len(name) * 8.5 + 20, (keyw + namew + typew) * CH + 40)
    h = 5 + 13 + 5 + 5 + len(cols) * 15 + 10
    return int(w), int(h)

def entity_view(dg, name, left, top):
    e = ent[name]; w, h = size_of(name)
    vid, lid, cid = nid(), nid(), nid()
    colviews = [{'_type': 'ERDColumnView', '_id': nid(), '_parent': ref(cid), 'model': ref(c['_id']), 'font': 'Arial;13;0',
                 'left': left + 5, 'top': top + 28 + i * 15, 'width': w - 10, 'height': 13} for i, c in enumerate(e['columns'])]
    v = {'_type': 'ERDEntityView', '_id': vid, '_parent': ref(dg['_id']), 'model': ref(e['_id']),
         'subViews': [
             {'_type': 'LabelView', '_id': lid, '_parent': ref(vid), 'font': 'Arial;13;1', 'left': left, 'top': top + 5,
              'width': w, 'height': 13, 'text': name},
             {'_type': 'ERDColumnCompartmentView', '_id': cid, '_parent': ref(vid), 'model': ref(e['_id']), 'subViews': colviews,
              'font': 'Arial;13;0', 'left': left, 'top': top + 23, 'width': w, 'height': h - 23}],
         'font': 'Arial;13;0', 'fillColor': FILL[T[name]['mod']], 'left': left, 'top': top, 'width': w, 'height': h,
         'nameLabel': ref(lid), 'columnCompartment': ref(cid)}
    dg['ownedViews'].append(v)
    return v

def rel_view(dg, r, tail_v, head_v, line_style=0):
    vid = nid()
    def lbl(pos, alpha, dist, visible=True):
        return {'_type': 'EdgeLabelView', '_id': nid(), '_parent': ref(vid), 'model': ref(r['_id']), 'visible': visible,
                'font': 'Arial;13;0', 'left': 0, 'top': 0, 'height': 13, 'alpha': alpha, 'distance': dist,
                'hostEdge': ref(vid), 'edgePosition': pos}
    n, tl, hl = lbl(1, 1.5707963267948966, 15), lbl(2, 0.5235987755982988, 30, False), lbl(0, -0.5235987755982988, 30, False)
    tx, ty = tail_v['left'] + tail_v['width'] // 2, tail_v['top'] + tail_v['height'] // 2
    hx, hy = head_v['left'] + head_v['width'] // 2, head_v['top'] + head_v['height'] // 2
    v = {'_type': 'ERDRelationshipView', '_id': vid, '_parent': ref(dg['_id']), 'model': ref(r['_id']),
         'subViews': [n, tl, hl], 'font': 'Arial;13;0', 'head': ref(head_v['_id']), 'tail': ref(tail_v['_id']),
         'lineStyle': line_style, 'points': f'{tx}:{ty};{hx}:{hy}',
         'nameLabel': ref(n['_id']), 'tailNameLabel': ref(tl['_id']), 'headNameLabel': ref(hl['_id'])}
    dg['ownedViews'].append(v)

# colores suaves por módulo (relleno de entidades)
FILL = {'m1': '#E3ECF5', 'm2': '#EEE6F3', 'm3': '#F6EEDD', 'm4': '#DFF0EC', 'm5': '#F6E3E1', 'm6': '#E1EDF6', 'm7': '#ECEEF0'}

def diagram(name, columns=None, default=False, doc='', centers=None, line_style=0):
    """columns: lista de columnas de tablas (diagramas de módulo); centers: {tabla: (x, y)} centro de cada caja."""
    dg = {'_type': 'ERDDiagram', '_id': nid(), '_parent': ref(dm['_id']), 'name': name, 'documentation': doc, 'ownedViews': []}
    if default: dg['defaultDiagram'] = True
    views = {}
    if centers:
        for t, (cx, cy) in centers.items():
            w, h = size_of(t); views[t] = entity_view(dg, t, int(cx - w / 2), int(cy - h / 2))
    else:
        x = 40
        for column in columns:
            y, wmax = 40, 0
            for t in column:
                views[t] = entity_view(dg, t, x, y)
                w, h = size_of(t); y += h + 50; wmax = max(wmax, w)
            x += wmax + 110
    for ch, p, r in rels:
        if ch in views and p in views:
            rel_view(dg, r, views[p], views[ch], line_style)
    dm['ownedElements'].append(dg)
    return dg

# Diagrama completo: dos ejes. Arriba patients con sus catálogos, 4FN, historia y ficha de glaucoma;
# abajo medical_visits con sus 8 tablas hijas en una fila. Líneas rectas (oblicuas) para que ninguna cruce una caja.
DX = 800
FULL = {t: (x + DX, y) for t, (x, y) in {
    'patient_antecedents': (1600, 100), 'patient_allergies': (2450, 230), 'patient_family_histories': (2450, 470),
    'departments': (400, 470), 'cities': (900, 470), 'patients': (1600, 470),
    'document_types': (350, 830), 'clinical_documents': (900, 830), 'clinical_histories': (1600, 830), 'glaucoma_records': (2600, 830),
    'specialties': (350, 1250), 'healthcare_professionals': (900, 1250), 'medical_visits': (1600, 1250), 'glaucoma_controls': (2600, 1250),
}.items()}
FULL['audit_logs'] = (500, 160)
x = 100
for t in ['visit_diagnoses', 'intraocular_pressures', 'pachymetry_exams', 'gonioscopy_exams', 'oct_exams',
          'visual_field_exams', 'treatments', 'procedures']:
    w, _ = size_of(t); FULL[t] = (x + w / 2, 2000); x += w + 130
FULL['diagnoses'] = (FULL['visit_diagnoses'][0], 2440)
FULL['medications'] = (FULL['treatments'][0], 2440)
assert sorted(FULL) == sorted(t for t in T if T[t]['tag'] != 'respaldo')
diagram('0. Modelo lógico completo', centers=FULL, line_style=1, default=True,
        doc='Las 25 tablas relacionales y sus 25 llaves foráneas. Cardinalidad: 1 : 0..* (FK simple) y 1 : 0..1 (FK con UNIQUE).')
# StarUML traza las líneas en ángulo recto entre centros: se evita que una relación atraviese otra tabla
STARUML_LAYOUT = dict(DER_LAYOUT, m3=[['patients'], ['clinical_histories', 'clinical_documents'],
                                      ['medical_visits', 'healthcare_professionals'], ['visit_diagnoses'], ['diagnoses']])
for mk, (mname, _) in MODS.items():
    diagram(f'{mk[1]}. {mname}', STARUML_LAYOUT[mk], doc=f'Módulo {mk[1]}: {mname}. Las tablas de otros módulos se incluyen para mostrar sus relaciones.')

# ----------------------------------------------------------------------------- validación
ids = {}
def walk(o):
    if isinstance(o, dict):
        if '_id' in o:
            assert o['_id'] not in ids, 'id duplicado ' + o['_id']; ids[o['_id']] = o
        for v in o.values(): walk(v)
    elif isinstance(o, list):
        for v in o: walk(v)
walk(project)
def check_refs(o):
    if isinstance(o, dict):
        if set(o) == {'$ref'}: assert o['$ref'] in ids, 'referencia rota ' + str(o['$ref'])
        for v in o.values(): check_refs(v)
    elif isinstance(o, list):
        for v in o: check_refs(v)
check_refs(project)

out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, 'oftalmologia_model.mdj')
open(out, 'w', encoding='utf-8', newline='\n').write(json.dumps(project, ensure_ascii=False, indent='\t'))
cnt = lambda t: sum(1 for o in ids.values() if o.get('_type') == t)
print(f"entidades {cnt('ERDEntity')} · columnas {cnt('ERDColumn')} · relaciones {cnt('ERDRelationship')} · "
      f"diagramas {cnt('ERDDiagram')} · vistas de relación {cnt('ERDRelationshipView')} · ids {len(ids)}")
