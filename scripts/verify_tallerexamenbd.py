import re

with open('tallerexamenbd.md', 'r', encoding='utf-8') as f:
    text = f.read()

# Check sections 21.1, 21.2, 24.1, 36.1, 37.1, 40.1
check_headers = [
    '21.1 Inicialización de la Base de Datos (`00_init_database.sql`)',
    '21.2 Esquema Físico Relacional en 4FN (`01_ddl_schema.sql`)',
    '24.1 Dataset Clínico Semilla (`02_dml_seed_data.sql`)',
    '36.1 Implementación de Eventos Programados (`08_views_and_events.sql`)',
    '37.1 Implementación de Vistas Clínicas y Analíticas (`08_views_and_events.sql`)',
    '40.1 Arquitectura Maestra de Scripts del Repositorio'
]

for ch in check_headers:
    assert ch in text, f'Missing header: {ch}'
    print(f'[OK] Found: {ch}')

# Check 5 parts
parts = text.split('# PARTE ')
assert len(parts) == 6, f'Expected 6 parts (0=intro, 1..5=parts), got {len(parts)}'

total_exercises = 0
for p_idx in range(1, 6):
    p_text = parts[p_idx]
    matches = list(re.finditer(r'###\s*(\d+)\.\s*\n+(.*?)\n+```sql\n(.*?)\n```', p_text, flags=re.DOTALL))
    print(f'Part {p_idx}: found {len(matches)} exercises with sql code block')
    assert len(matches) == 50, f'Part {p_idx}: expected 50 exercises with sql, got {len(matches)}'
    total_exercises += len(matches)

print(f'Total exercises verified: {total_exercises}')
assert total_exercises == 250, 'Total exercises must be exactly 250!'
print('ALL CHECKS PASSED PERFECTLY!')
