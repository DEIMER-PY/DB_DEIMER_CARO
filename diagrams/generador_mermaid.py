# -*- coding: utf-8 -*-
"""Genera diagrams/physical_erd.mmd (DER físico en Mermaid) con los mismos datos del modelo ER.

Uso (desde la raíz del proyecto):
    python diagrams/generador_mermaid.py diagrams/physical_erd.mmd

Toma tablas, columnas y llaves foráneas de diagrams/generador_modelo_er.py (T, FKS), que reflejan
sql/01_ddl_schema.sql. Cada atributo lleva su tipo base, sus claves (PK, FK, UK) y, como comentario,
el tipo MySQL completo y si admite NULL.
"""
import importlib.util, os, sys

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('modelo', os.path.join(here, 'generador_modelo_er.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

out = ['erDiagram',
       '    %% DER físico de oftalmologia_glaucoma_db (MySQL 8.0, 4FN).',
       '    %% Generado con diagrams/generador_mermaid.py desde sql/01_ddl_schema.sql. No editar a mano.']
for name, t in m.T.items():
    out.append(f'    {name.upper()} {{')
    for c in t['cols']:
        typ = c['type'].replace(' AUTO_INCREMENT', '')
        base = typ.split('(')[0].lower()
        keys = ', '.join(k for k in ('PK', 'FK', 'UK') if k in c['key'].split())
        full = typ.replace('"', "'") + (' NULL' if c['null'] else ' NOT NULL')
        if 'AUTO_INCREMENT' in c['type']: full += ' AUTO_INCREMENT'
        out.append(f'        {base} {c["name"]}' + (f' {keys}' if keys else '') + f' "{full}"')
    out.append('    }')
out.append('')
for ch, col, p, verb, od in m.FKS:
    uniq = m.is_unique_fk(ch, col)
    card = ('1:1' if ch == 'clinical_histories' else '1:0..1') if uniq else '1:N'
    arrow = '||--o|' if uniq else '||--o{'
    out.append(f'    {p.upper()} {arrow} {ch.upper()} : "{verb} ({card})"')
path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, 'physical_erd.mmd')
open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
print(f'{len(m.T)} entidades · {sum(len(t["cols"]) for t in m.T.values())} atributos · {len(m.FKS)} relaciones')
