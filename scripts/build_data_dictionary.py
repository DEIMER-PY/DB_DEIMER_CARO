# -*- coding: utf-8 -*-
"""Genera docs/03_diccionario_de_datos.md a partir de diagrams/generador_modelo_er.py (T, FKS, BACKUPS).

Uso:
    python3 scripts/build_data_dictionary.py
"""
import os, sys, importlib.util

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = importlib.util.spec_from_file_location('modelo', os.path.join(root, 'diagrams', 'generador_modelo_er.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

modules = {
    'm1': '3.1. Tablas Geográficas, Identificación y Pacientes (4FN)',
    'm2': '3.2. Especialidades, Profesionales de Salud y Citas',
    'm3': '3.3. Historia Clínica y Atención Médica',
    'm4': '3.4. Exámenes Oftalmológicos y Paraclínicos',
    'm5': '3.5. Farmacología, Tratamientos y Procedimientos',
    'm6': '3.6. Ficha y Monitoreo Continuo de Glaucoma',
    'm7': '3.7. Documentos y Auditoría de Seguridad'
}

lines = [
    '# 3. Diccionario de Datos del Sistema',
    '',
    'El siguiente catálogo detalla la estructura física de las 37 tablas (32 base + 5 de respaldo), tipos de datos, restricciones de nulidad, llaves y descripciones de cada atributo para la base de datos `oftalmologia_glaucoma_db`.',
    '',
    '---',
    ''
]

cur_mod = None
idx = 1

for tname, tinfo in m.T.items():
    if tname.endswith('_backup'):
        continue
    mod = tinfo['mod']
    if mod != cur_mod and mod in modules:
        cur_mod = mod
        lines.append(f'## {modules[mod]}')
        lines.append('')
    
    desc = tinfo['desc']
    lines.append(f'### {idx}. `{tname}`')
    lines.append(f'{desc}')
    lines.append('| Campo | Tipo | Nulo | Clave | Default | Descripción |')
    lines.append('|---|---|---|---|---|---|')
    idx += 1
    
    for c in tinfo['cols']:
        cname = c['name']
        typ = c['type']
        nul = 'SI' if c['null'] else 'NO'
        ks = c['key'].split()
        if 'PK' in ks:
            key = 'PK'
        elif 'FK' in ks and 'UK' in ks:
            key = 'FK UNIQUE'
        elif 'FK' in ks:
            key = 'FK'
        elif 'UK' in ks:
            key = 'UNIQUE'
        else:
            key = '-'
            
        dflt = c['default'].replace(' ON UPDATE', '') if c['default'] else '-'
        if dflt == '':
            dflt = '-'
        cdesc = c['desc'] or '-'
        lines.append(f'| `{cname}` | {typ} | {nul} | {key} | {dflt} | {cdesc} |')
    lines.append('')

lines.append('---')
lines.append('')
lines.append('## 3.8. Tablas de Respaldo')
lines.append('')
lines.append('Las cinco tablas de respaldo se crean con `CREATE TABLE … LIKE`, por lo que tienen **exactamente las mismas columnas, tipos, `NULL`, `DEFAULT`, `PRIMARY KEY`, índices `UNIQUE` y `CHECK`** que su tabla de origen. `LIKE` **no copia las llaves foráneas**, así que no tienen relaciones. Las llenan triggers `BEFORE DELETE` con la fila que se va a borrar.')
lines.append('')
lines.append('| # | Tabla | Copia de | Trigger que la llena |')
lines.append('|---|---|---|---|')
b_idx = 33
for bname, src, trg in m.BACKUPS:
    ncols = len(m.T[src]['cols'])
    lines.append(f'| {b_idx} | `{bname}` | `{src}` ({ncols} columnas) | `{trg}` |')
    b_idx += 1
lines.append('')

target = os.path.join(root, 'docs', '03_diccionario_de_datos.md')
with open(target, 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines))

print(f'Diccionario de datos generado en {target}: {idx-1} tablas base + {len(m.BACKUPS)} tablas de respaldo.')
