import os
import re

def parse_sql_part(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.splitlines(keepends=True)
    header_indices = []
    expected = 1
    for idx, line in enumerate(lines):
        m = re.match(r'^--\s*(\d+)\.\s+(.*)$', line)
        if m and int(m.group(1)) == expected:
            header_indices.append((expected, idx, m.group(2).strip()))
            expected += 1
            if expected > 50:
                break
                
    assert len(header_indices) == 50, f'{filepath}: expected 50, got {len(header_indices)}'
    
    results = {}
    for i in range(50):
        num, line_idx, title = header_indices[i]
        next_line_idx = header_indices[i+1][1] if i + 1 < 50 else len(lines)
        curr_idx = line_idx + 1
        desc_lines = [title]
        while curr_idx < next_line_idx:
            l_str = lines[curr_idx].strip()
            if l_str.startswith('-- ') and not (l_str.startswith('-- 1.') or l_str.startswith('-- 2.')):
                if not any(l_str.lower().startswith(kw) for kw in ['-- paso', '-- nota', '-- auditoria', '-- calculo', '-- validar']):
                    desc_lines.append(l_str.lstrip('- ').strip())
                    curr_idx += 1
                    continue
            break
            
        full_title = ' '.join(desc_lines)
        chunk_lines = [l for l in lines[curr_idx:next_line_idx]]
        while chunk_lines:
            st = chunk_lines[-1].strip()
            if (st.startswith('-- ---') or st.startswith('-- NIVEL ') or 
                st.startswith('-- PROCEDIMIENTOS ') or st.startswith('-- FUNCIONES ') or 
                st.startswith('-- BEFORE ') or st.startswith('-- AFTER ') or 
                st.startswith('-- DELETE ') or st.startswith('-- SUBCONSULTAS ') or st == ''):
                chunk_lines.pop()
            else:
                break
        code = ''.join(chunk_lines).strip()
        results[num] = code
    return results

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.dirname(base_dir)

    sql_00_path = os.path.join(root_dir, 'sql', '00_init_database.sql')
    sql_01_path = os.path.join(root_dir, 'sql', '01_ddl_schema.sql')
    sql_02_path = os.path.join(root_dir, 'sql', '02_dml_seed_data.sql')
    sql_03_path = os.path.join(root_dir, 'sql', '03_part1_queries.sql')
    sql_04_path = os.path.join(root_dir, 'sql', '04_part2_subqueries.sql')
    sql_05_path = os.path.join(root_dir, 'sql', '05_part3_procedures.sql')
    sql_06_path = os.path.join(root_dir, 'sql', '06_part4_triggers.sql')
    sql_07_path = os.path.join(root_dir, 'sql', '07_part5_functions.sql')
    sql_08_path = os.path.join(root_dir, 'sql', '08_views_and_events.sql')
    md_path = os.path.join(root_dir, 'tallerexamenbd.md')

    with open(sql_00_path, 'r', encoding='utf-8') as f:
        sql_00 = f.read().strip()
    with open(sql_01_path, 'r', encoding='utf-8') as f:
        sql_01 = f.read().strip()
    with open(sql_02_path, 'r', encoding='utf-8') as f:
        sql_02 = f.read().strip()
    with open(sql_08_path, 'r', encoding='utf-8') as f:
        sql_08 = f.read().strip()

    p1 = parse_sql_part(sql_03_path)
    p2 = parse_sql_part(sql_04_path)
    p3 = parse_sql_part(sql_05_path)
    p4 = parse_sql_part(sql_06_path)
    p5 = parse_sql_part(sql_07_path)

    with open(md_path, 'r', encoding='utf-8') as f:
        md_text = f.read()

    # Split documentation part and 250 exercises part
    parts_bank = md_text.split('# Banco de 250 ejercicios MySQL\n')
    doc_part = parts_bank[0]
    bank_part = '# Banco de 250 ejercicios MySQL\n' + parts_bank[1]

    # --- 1. ENRICH DOCUMENTATION ---
    # Section 21
    sec21_anchor = '# 21. Implementación física en MySQL'
    sec22_anchor = '# 22. Restricciones'
    pos21 = doc_part.find(sec21_anchor)
    pos22 = doc_part.find(sec22_anchor)
    assert pos21 != -1 and pos22 != -1

    sec21_original = doc_part[pos21:pos22].rstrip()
    sec21_enriched = sec21_original + f"""

### 21.1 Inicialización de la Base de Datos (`00_init_database.sql`)

Crea la base de datos `oftalmologia_glaucoma_db` con codificación `utf8mb4` y `COLLATE utf8mb4_unicode_ci`, activando el programador de eventos de MySQL (`event_scheduler = ON`):

```sql
{sql_00}
```

### 21.2 Esquema Físico Relacional en 4FN (`01_ddl_schema.sql`)

Crea las 25 tablas relacionales normalizadas en Cuarta Forma Normal (4FN), 4 tablas de respaldo para auditoría histórica, índices de rendimiento y restricciones de integridad:

```sql
{sql_01}
```

"""
    doc_part = doc_part[:pos21] + sec21_enriched + doc_part[pos22:]

    # Section 24
    sec24_anchor = '# 24. Datos de prueba'
    sec25_anchor = '# 25. Consultas básicas'
    pos24 = doc_part.find(sec24_anchor)
    pos25 = doc_part.find(sec25_anchor)
    assert pos24 != -1 and pos25 != -1

    sec24_original = doc_part[pos24:pos25].rstrip()
    sec24_enriched = sec24_original + f"""

### 24.1 Dataset Clínico Semilla (`02_dml_seed_data.sql`)

Carga el dataset clínico completo de prueba con departamentos, ciudades, tipos de documentos, especialidades, profesionales de salud, pacientes, antecedentes personales y familiares, alergias, historias clínicas, consultas médicas, diagnósticos CIE-11, mediciones de presión intraocular (PIO), paquimetría, gonioscopía, tomografías de coherencia óptica (OCT), campimetrías computarizadas (campos visuales), catálogo farmacológico, tratamientos médicos, procedimientos quirúrgicos, registros y controles de progresión de glaucoma y bitácora de auditoría:

```sql
{sql_02}
```

"""
    doc_part = doc_part[:pos24] + sec24_enriched + doc_part[pos25:]

    # Section 36 (Events)
    sec36_anchor = '# 36. Eventos'
    sec37_anchor = '# 37. Vistas'
    pos36 = doc_part.find(sec36_anchor)
    pos37 = doc_part.find(sec37_anchor)
    assert pos36 != -1 and pos37 != -1

    events_sql = '-- ==============================================================================\n-- EVENTOS PROGRAMADOS' + sql_08.split('-- ==============================================================================\n-- EVENTOS PROGRAMADOS')[1].strip()

    sec36_original = doc_part[pos36:pos37].rstrip()
    sec36_enriched = sec36_original + f"""

### 36.1 Implementación de Eventos Programados (`08_views_and_events.sql`)

Eventos programados en el motor MySQL (`event_scheduler = ON`) para el mantenimiento preventivo semanal de la bitácora de auditoría y la verificación diaria automática del estado de tratamientos caducados:

```sql
{events_sql}
```

"""
    doc_part = doc_part[:pos36] + sec36_enriched + doc_part[pos37:]

    # Section 37 (Views)
    sec38_anchor = '# 38. Posibles consultas requeridas'
    pos37 = doc_part.find(sec37_anchor)
    pos38 = doc_part.find(sec38_anchor)
    assert pos37 != -1 and pos38 != -1

    views_sql = sql_08.split('-- ==============================================================================\n-- EVENTOS PROGRAMADOS')[0].strip()

    sec37_original = doc_part[pos37:pos38].rstrip()
    sec37_enriched = sec37_original + f"""

### 37.1 Implementación de Vistas Clínicas y Analíticas (`08_views_and_events.sql`)

Ocho vistas analíticas especializadas para resumen integral de historias clínicas, última consulta asistida, tratamientos farmacológicos activos, monitoreo continuo de glaucoma, PIO bilateral comparativa, consolidado de exámenes paraclínicos (OCT, campo visual, paquimetría), productividad y carga laboral de especialistas médicos y bitácora de alertas de auditoría:

```sql
{views_sql}
```

"""
    doc_part = doc_part[:pos37] + sec37_enriched + doc_part[pos38:]

    # Section 40 (Expected product & scripts)
    sec40_anchor = '# 40. Producto final esperado'
    sec42_anchor = '# 42. Pregunta orientadora final'
    pos40 = doc_part.find(sec40_anchor)
    pos42 = doc_part.find(sec42_anchor)
    assert pos40 != -1 and pos42 != -1

    sec40_original = doc_part[pos40:pos42].rstrip()
    sec40_enriched = sec40_original + f"""

### 40.1 Arquitectura Maestra de Scripts del Repositorio

La solución integral implementada y verificada en MySQL 8.0 se estructura en la siguiente suite de scripts ordenados:

1. **`00_init_database.sql`**: Crea la base de datos `oftalmologia_glaucoma_db` con codificación `utf8mb4` y activa el programador de eventos (`event_scheduler = ON`).
2. **`01_ddl_schema.sql`**: Crea las 25 tablas relacionales normalizadas en Cuarta Forma Normal (4FN), 4 tablas de backup, llaves primarias, llaves foráneas con integridad referencial, índices y restricciones CHECK/UNIQUE.
3. **`02_dml_seed_data.sql`**: Carga el dataset clínico completo de prueba con pacientes, antecedentes, visitas, exámenes paraclínicos, tratamientos y controles de glaucoma.
4. **`03_part1_queries.sql`**: Ejecuta las 50 consultas SQL (básicas, intermedias y avanzadas).
5. **`04_part2_subqueries.sql`**: Ejecuta las 50 subconsultas SQL (escalares, IN, NOT EXISTS, correlacionadas y avanzadas).
6. **`05_part3_procedures.sql`**: Compila los 50 Procedimientos Almacenados (CRUD, reglas de negocio, validaciones con SIGNAL SQLSTATE y transacciones ACID con START TRANSACTION, COMMIT y ROLLBACK).
7. **`06_part4_triggers.sql`**: Compila los 50 Triggers (BEFORE/AFTER INSERT/UPDATE/DELETE con auditoría inmutable en JSON).
8. **`07_part5_functions.sql`**: Compila las 50 Funciones Almacenadas clínicas, diagnósticas, estadísticas y de cálculo cardiovascular/ocular.
9. **`08_views_and_events.sql`**: Compila las 8 Vistas analíticas y los 2 Eventos programados de mantenimiento en el motor.

"""
    doc_part = doc_part[:pos40] + sec40_enriched + doc_part[pos42:]

    # --- 2. ENRICH 250 EXERCISES IN BANK ---
    bank_parts = bank_part.split('# PARTE ')
    header_bank = bank_parts[0] # The intro before Part I
    
    parts_data = [
        (1, bank_parts[1], p1, False), # Queries: no delimiter
        (2, bank_parts[2], p2, False), # Subqueries: no delimiter
        (3, bank_parts[3], p3, True),  # Procedures: with delimiter
        (4, bank_parts[4], p4, True),  # Triggers: with delimiter
        (5, bank_parts[5], p5, True)   # Functions: with delimiter
    ]

    new_parts = [header_bank]

    for part_num, p_text, sql_dict, need_delimiter in parts_data:
        tokens = re.split(r'(###\s*\d+\.\s*\n)', p_text)
        part_header = tokens[0]
        enriched_tokens = [part_header]

        for idx in range(1, len(tokens), 2):
            ex_header = tokens[idx] # e.g. '### 1.\n'
            ex_num = int(re.search(r'\d+', ex_header).group())
            body = tokens[idx + 1]

            m_trailing = re.search(r'\n+(##+ .*)', body, flags=re.DOTALL)
            if m_trailing:
                prompt = body[:m_trailing.start()].strip()
                trailing = '\n\n' + m_trailing.group(1).strip() + '\n\n'
            else:
                prompt = body.strip()
                trailing = '\n\n'

            sql_code = sql_dict[ex_num]

            if need_delimiter:
                code_block = f"```sql\nDELIMITER $$\n{sql_code}\nDELIMITER ;\n```"
            else:
                code_block = f"```sql\n{sql_code}\n```"

            exercise_text = f"{ex_header}\n{prompt}\n\n{code_block}{trailing}"
            enriched_tokens.append(exercise_text)

        new_parts.append('# PARTE ' + ''.join(enriched_tokens))

    final_bank = ''.join(new_parts)
    final_full_md = doc_part.rstrip() + '\n\n' + final_bank.lstrip()

    # Write to tallerexamenbd.md
    with open(md_path, 'w', encoding='utf-8') as f:
        f.write(final_full_md)

    print('Successfully generated full tallerexamenbd.md!')
    print(f'Total length of tallerexamenbd.md: {len(final_full_md)} characters, {len(final_full_md.splitlines())} lines.')

if __name__ == '__main__':
    main()
