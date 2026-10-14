# 7. Guía de Cláusulas y Funciones SQL (MySQL 8)

Guía de consulta rápida con **todas las cláusulas y funciones** usadas en el taller, cada una con un ejemplo sobre la base `oftalmologia_glaucoma_db`.

> **Los resultados son reales:** cada ejemplo se ejecutó en la base desplegada por `tests/run_all` y su salida se pegó debajo (las tablas largas se recortan a 8 filas). Los ejemplos de `INSERT`, `UPDATE` y `DELETE` van dentro de una transacción con `ROLLBACK`, así que puede ejecutarlos sin cambiar los datos.

## Orden en que se escriben y orden en que se ejecutan

| Se escribe en este orden | MySQL lo ejecuta en este orden |
|---|---|
| 1. `SELECT` (columnas, `DISTINCT`) | 1. `FROM` y `JOIN` |
| 2. `FROM` | 2. `WHERE` |
| 3. `JOIN … ON` | 3. `GROUP BY` |
| 4. `WHERE` | 4. `HAVING` |
| 5. `GROUP BY` | 5. `SELECT` (y funciones de ventana) |
| 6. `HAVING` | 6. `DISTINCT` |
| 7. `ORDER BY` | 7. `ORDER BY` |
| 8. `LIMIT` / `OFFSET` | 8. `LIMIT` / `OFFSET` |

Por eso un alias del `SELECT` **no** se puede usar en el `WHERE` (todavía no existe), pero sí en el `ORDER BY`. En el `HAVING` MySQL lo permite como extensión.

## Contenido

- 1. SELECT básico
- 2. WHERE: filtros y operadores
- 3. Funciones de agregación
- 4. GROUP BY y HAVING
- 5. JOIN: combinar tablas
- 6. Subconsultas
- 7. UNION y UNION ALL
- 8. Condicionales y valores nulos
- 9. Funciones de texto
- 10. Funciones numéricas
- 11. Funciones de fecha
- 12. Conversión de tipos
- 13. Funciones de ventana (MySQL 8)
- 14. CTE: consultas con WITH
- 15. Modificar datos: INSERT, UPDATE, DELETE
- 16. JSON
- 17. Objetos de la base (resumen de sintaxis)

---

## 1. SELECT básico

Elegir columnas, renombrarlas, quitar duplicados, ordenar y limitar.

### SELECT y alias (AS)

Se eligen columnas y se renombran con `AS` para que el resultado sea legible.

```sql
SELECT id, first_name AS nombre, last_name AS apellido, birth_date AS nacimiento
FROM patients
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----+-----------------+-------------------+------------+
| id | nombre          | apellido          | nacimiento |
+----+-----------------+-------------------+------------+
|  1 | Juan Carlos     | Gómez Pérez       | 1958-03-15 |
|  2 | María Fernanda  | Rodríguez López   | 1964-07-22 |
|  3 | Carlos Alberto  | Gómez Mendoza     | 1952-11-05 |
|  4 | Ana Milena      | Martínez Silva    | 1975-01-30 |
|  5 | Esperanza       | Gómez Castro      | 1948-09-18 |
+----+-----------------+-------------------+------------+
```
</details>

### DISTINCT

Elimina filas repetidas: cada método de tonometría aparece una sola vez.

```sql
SELECT DISTINCT method AS metodo
FROM intraocular_pressures;
```

<details><summary>Resultado</summary>

```text
+----------+
| metodo   |
+----------+
| GOLDMANN |
+----------+
```
</details>

### ORDER BY ASC / DESC

Ordena por una o varias columnas. `ASC` (por defecto) de menor a mayor, `DESC` al revés.

```sql
SELECT first_name, last_name, birth_date
FROM patients
ORDER BY birth_date ASC, last_name DESC
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----------------+------------------+------------+
| first_name     | last_name        | birth_date |
+----------------+------------------+------------+
| Rosa María     | Villamizar León  | 1945-12-15 |
| Esperanza      | Gómez Castro     | 1948-09-18 |
| Héctor Fabio   | Ramírez Ortiz    | 1950-04-25 |
| Carlos Alberto | Gómez Mendoza    | 1952-11-05 |
| Juan Carlos    | Gómez Pérez      | 1958-03-15 |
+----------------+------------------+------------+
```
</details>

### LIMIT y OFFSET

`LIMIT n` devuelve n filas; `OFFSET m` se salta las m primeras (útil para paginar).

```sql
SELECT id, first_name, last_name
FROM patients
ORDER BY id
LIMIT 3 OFFSET 3;      -- filas 4, 5 y 6
```

<details><summary>Resultado</summary>

```text
+----+-------------+-----------------+
| id | first_name  | last_name       |
+----+-------------+-----------------+
|  4 | Ana Milena  | Martínez Silva  |
|  5 | Esperanza   | Gómez Castro    |
|  6 | Pedro José  | Sánchez Rueda   |
+----+-------------+-----------------+
```
</details>


## 2. WHERE: filtros y operadores

`WHERE` filtra filas **antes** de agrupar.

### Comparación (=, <>, >, <, >=, <=)

Mediciones de PIO mayores o iguales a 22 mmHg en el ojo derecho.

```sql
SELECT id, visit_id, eye, pressure
FROM intraocular_pressures
WHERE eye = 'OD' AND pressure >= 22;
```

<details><summary>Resultado</summary>

```text
+----+----------+-----+----------+
| id | visit_id | eye | pressure |
+----+----------+-----+----------+
|  5 |        3 | OD  |    23.00 |
|  1 |        1 | OD  |    24.50 |
| 15 |        9 | OD  |    25.50 |
| 13 |        8 | OD  |    26.00 |
|  9 |        5 | OD  |    48.00 |
+----+----------+-----+----------+
```
</details>

### AND, OR, NOT y paréntesis

Los paréntesis definen qué se evalúa primero. `NOT` niega la condición.

```sql
SELECT id, eye, pressure, method
FROM intraocular_pressures
WHERE (pressure > 24 OR pressure < 14)
  AND NOT method = 'AIRE';
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+----------+
| id | eye | pressure | method   |
+----+-----+----------+----------+
|  1 | OD  |    24.50 | GOLDMANN |
|  4 | OI  |    13.50 | GOLDMANN |
|  9 | OD  |    48.00 | GOLDMANN |
| 13 | OD  |    26.00 | GOLDMANN |
| 14 | OI  |    25.00 | GOLDMANN |
| 15 | OD  |    25.50 | GOLDMANN |
+----+-----+----------+----------+
```
</details>

### BETWEEN

Rango **inclusivo** en ambos extremos. Sirve con números y con fechas.

```sql
SELECT id, DATE(visit_date) AS fecha
FROM medical_visits
WHERE visit_date BETWEEN '2026-02-01' AND '2026-02-28 23:59:59';
```

<details><summary>Resultado</summary>

```text
+----+------------+
| id | fecha      |
+----+------------+
|  5 | 2026-02-05 |
|  6 | 2026-02-06 |
| 10 | 2026-02-10 |
| 17 | 2026-02-15 |
|  4 | 2026-02-18 |
|  7 | 2026-02-20 |
| 14 | 2026-02-28 |
+----+------------+
```
</details>

### IN y NOT IN

Compara contra una lista de valores.

```sql
SELECT code, name
FROM diagnoses
WHERE code IN ('H40.1', 'H40.2', 'H40.0');
```

<details><summary>Resultado</summary>

```text
+-------+---------------------------------------------+
| code  | name                                        |
+-------+---------------------------------------------+
| H40.0 | Sospecha de glaucoma e Hipertensión Ocular  |
| H40.1 | Glaucoma primario de ángulo abierto         |
| H40.2 | Glaucoma primario de ángulo cerrado         |
+-------+---------------------------------------------+
```
</details>

### LIKE con % (cualquier cantidad de caracteres)

`'Mar%'` = empieza por Mar · `'%ez'` = termina en ez · `'%ía%'` = contiene ía.

```sql
SELECT first_name, last_name
FROM patients
WHERE last_name LIKE '%ez%';
```

<details><summary>Resultado</summary>

```text
+-----------------+-------------------+
| first_name      | last_name         |
+-----------------+-------------------+
| Fernando        | Álvarez Niño      |
| Esperanza       | Gómez Castro      |
| Carlos Alberto  | Gómez Mendoza     |
| Juan Carlos     | Gómez Pérez       |
| Ana Milena      | Martínez Silva    |
| Héctor Fabio    | Ramírez Ortiz     |
| María Fernanda  | Rodríguez López   |
| Pedro José      | Sánchez Rueda     |
… (9 filas en total)
+-----------------+-------------------+
```
</details>

### LIKE con _ (exactamente un carácter)

`'H40._'` encuentra H40.0, H40.1, H40.2… (un solo carácter después del punto).

```sql
SELECT code, name
FROM diagnoses
WHERE code LIKE 'H40._';
```

<details><summary>Resultado</summary>

```text
+-------+-------------------------------------------------+
| code  | name                                            |
+-------+-------------------------------------------------+
| H40.0 | Sospecha de glaucoma e Hipertensión Ocular      |
| H40.1 | Glaucoma primario de ángulo abierto             |
| H40.2 | Glaucoma primario de ángulo cerrado             |
| H40.5 | Glaucoma secundario a otros trastornos oculares |
+-------+-------------------------------------------------+
```
</details>

### NOT LIKE

Lo contrario de `LIKE`: correos que **no** son de gmail.

```sql
SELECT first_name, email
FROM patients
WHERE email NOT LIKE '%@gmail.com'
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----------------+------------------------------+
| first_name     | email                        |
+----------------+------------------------------+
| Carlos Alberto | carlos.gomez@hotmail.com     |
| Pedro José     | pedro.sanchez@yahoo.com      |
| Fernando       | fernando.alvarez@outlook.com |
| John David     | john.smith@expat.com         |
+----------------+------------------------------+
```
</details>

### REGEXP (expresiones regulares)

Patrones más potentes que `LIKE`: códigos CIE-10 de glaucoma (H40) o de catarata (H25).

```sql
SELECT code, name
FROM diagnoses
WHERE code REGEXP '^H(40|25)';
```

<details><summary>Resultado</summary>

```text
+-------+-------------------------------------------------+
| code  | name                                            |
+-------+-------------------------------------------------+
| H40.1 | Glaucoma primario de ángulo abierto             |
| H40.2 | Glaucoma primario de ángulo cerrado             |
| H40.0 | Sospecha de glaucoma e Hipertensión Ocular      |
| H40.5 | Glaucoma secundario a otros trastornos oculares |
| H25.0 | Catarata senil incipiente                       |
+-------+-------------------------------------------------+
```
</details>

### IS NULL / IS NOT NULL

Para buscar valores vacíos **nunca** use `= NULL`: siempre `IS NULL`.

```sql
SELECT id, first_name, last_name, email
FROM patients
WHERE email IS NULL;
```

<details><summary>Resultado</summary>

```text
+----+---------------+------------------+-------+
| id | first_name    | last_name        | email |
+----+---------------+------------------+-------+
|  5 | Esperanza     | Gómez Castro     | NULL  |
|  8 | Héctor Fabio  | Ramírez Ortiz    | NULL  |
| 13 | Rosa María    | Villamizar León  | NULL  |
+----+---------------+------------------+-------+
```
</details>


## 3. Funciones de agregación

Resumen muchas filas en un solo valor. Ignoran los `NULL` (excepto `COUNT(*)`).

### COUNT(*), COUNT(columna), COUNT(DISTINCT)

`COUNT(*)` cuenta filas; `COUNT(col)` cuenta los no nulos; `COUNT(DISTINCT col)` cuenta valores distintos.

```sql
SELECT COUNT(*)                  AS total_tratamientos,
       COUNT(end_date)           AS con_fecha_fin,
       COUNT(DISTINCT medication_id) AS medicamentos_distintos
FROM treatments;
```

<details><summary>Resultado</summary>

```text
+--------------------+---------------+------------------------+
| total_tratamientos | con_fecha_fin | medicamentos_distintos |
+--------------------+---------------+------------------------+
|                 13 |            13 |                      8 |
+--------------------+---------------+------------------------+
```
</details>

### SUM

Suma de valores: total de consultas cerradas (`is_closed` vale 1 o 0).

```sql
SELECT SUM(is_closed)            AS consultas_cerradas,
       SUM(1 - is_closed)        AS consultas_abiertas
FROM medical_visits;
```

<details><summary>Resultado</summary>

```text
+--------------------+--------------------+
| consultas_cerradas | consultas_abiertas |
+--------------------+--------------------+
|                 17 |                  2 |
+--------------------+--------------------+
```
</details>

### AVG

Promedio. Combínelo con `ROUND` para fijar decimales.

```sql
SELECT ROUND(AVG(pressure), 2) AS pio_promedio
FROM intraocular_pressures;
```

<details><summary>Resultado</summary>

```text
+--------------+
| pio_promedio |
+--------------+
|        20.73 |
+--------------+
```
</details>

### MIN y MAX

Valor mínimo y máximo; también sirven con fechas y texto.

```sql
SELECT MIN(pressure) AS pio_minima, MAX(pressure) AS pio_maxima,
       MIN(DATE(visit_date)) AS primera_consulta, MAX(DATE(visit_date)) AS ultima_consulta
FROM intraocular_pressures iop
JOIN medical_visits mv ON mv.id = iop.visit_id;
```

<details><summary>Resultado</summary>

```text
+------------+------------+------------------+-----------------+
| pio_minima | pio_maxima | primera_consulta | ultima_consulta |
+------------+------------+------------------+-----------------+
|      13.50 |      48.00 | 2026-01-10       | 2026-03-25      |
+------------+------------+------------------+-----------------+
```
</details>

### GROUP_CONCAT

Une en un solo texto los valores de un grupo.

```sql
SELECT eye, GROUP_CONCAT(pressure ORDER BY pressure SEPARATOR ', ') AS presiones
FROM intraocular_pressures
GROUP BY eye;
```

<details><summary>Resultado</summary>

```text
+-----+------------------------------------------------------------------------------------+
| eye | presiones                                                                          |
+-----+------------------------------------------------------------------------------------+
| OD  | 14.00, 15.00, 16.00, 16.50, 19.00, 21.00, 21.50, 23.00, 24.50, 25.50, 26.00, 48.00 |
| OI  | 13.50, 14.50, 15.00, 15.50, 18.00, 18.50, 20.00, 20.00, 22.00, 22.50, 23.00, 25.00 |
+-----+------------------------------------------------------------------------------------+
```
</details>


## 4. GROUP BY y HAVING

`GROUP BY` forma grupos; `HAVING` filtra los grupos **después** de agrupar. La base usa `ONLY_FULL_GROUP_BY`: toda columna no agregada del `SELECT` debe estar en el `GROUP BY`.

### GROUP BY

Número de mediciones y promedio de PIO por ojo.

```sql
SELECT eye AS ojo, COUNT(*) AS mediciones, ROUND(AVG(pressure), 2) AS promedio
FROM intraocular_pressures
GROUP BY eye;
```

<details><summary>Resultado</summary>

```text
+-----+------------+----------+
| ojo | mediciones | promedio |
+-----+------------+----------+
| OD  |         12 |    22.50 |
| OI  |         12 |    18.96 |
+-----+------------+----------+
```
</details>

### GROUP BY con varias columnas

Mediciones por ojo y por método.

```sql
SELECT eye, method, COUNT(*) AS mediciones
FROM intraocular_pressures
GROUP BY eye, method
ORDER BY eye, mediciones DESC;
```

<details><summary>Resultado</summary>

```text
+-----+----------+------------+
| eye | method   | mediciones |
+-----+----------+------------+
| OD  | GOLDMANN |         12 |
| OI  | GOLDMANN |         12 |
+-----+----------+------------+
```
</details>

### HAVING

Solo las consultas con PIO promedio mayor a 22 mmHg.

```sql
SELECT visit_id, ROUND(AVG(pressure), 2) AS promedio
FROM intraocular_pressures
GROUP BY visit_id
HAVING AVG(pressure) > 22
ORDER BY promedio DESC;
```

<details><summary>Resultado</summary>

```text
+----------+----------+
| visit_id | promedio |
+----------+----------+
|        5 |    33.00 |
|        8 |    25.50 |
|        9 |    24.25 |
|        1 |    23.25 |
|        3 |    22.75 |
+----------+----------+
```
</details>

### WHERE + GROUP BY + HAVING juntos

`WHERE` quita filas antes de agrupar (solo Goldmann); `HAVING` quita grupos después (al menos 2 mediciones).

```sql
SELECT eye, COUNT(*) AS mediciones, ROUND(AVG(pressure), 2) AS promedio
FROM intraocular_pressures
WHERE method = 'GOLDMANN'
GROUP BY eye
HAVING COUNT(*) >= 2;
```

<details><summary>Resultado</summary>

```text
+-----+------------+----------+
| eye | mediciones | promedio |
+-----+------------+----------+
| OD  |         12 |    22.50 |
| OI  |         12 |    18.96 |
+-----+------------+----------+
```
</details>

### WITH ROLLUP

Agrega una fila de subtotal (`NULL` en la columna agrupada) con el total general.

```sql
SELECT eye, COUNT(*) AS mediciones
FROM intraocular_pressures
GROUP BY eye WITH ROLLUP;
```

<details><summary>Resultado</summary>

```text
+------+------------+
| eye  | mediciones |
+------+------------+
| OD   |         12 |
| OI   |         12 |
| NULL |         24 |
+------+------------+
```
</details>


## 5. JOIN: combinar tablas

Une filas de varias tablas por una condición, normalmente FK = PK.

### INNER JOIN

Solo las filas que tienen pareja en ambas tablas: pacientes con su ciudad y departamento.

```sql
SELECT p.first_name, p.last_name, c.name AS ciudad, d.name AS departamento
FROM patients p
INNER JOIN cities c      ON c.id = p.city_id
INNER JOIN departments d ON d.id = c.department_id
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+---------------+------------------+--------------+--------------+
| first_name    | last_name        | ciudad       | departamento |
+---------------+------------------+--------------+--------------+
| Patricia      | Herrera Díaz     | Envigado     | Antioquia    |
| Lucía Andrea  | Navarro Plata    | Medellín     | Antioquia    |
| Rosa María    | Villamizar León  | Bogotá D.C.  | Cundinamarca |
| John David    | Smith Miller     | Bogotá D.C.  | Cundinamarca |
| Juan Carlos   | Gómez Pérez      | Bucaramanga  | Santander    |
+---------------+------------------+--------------+--------------+
```
</details>

### LEFT JOIN

Todas las filas de la izquierda aunque no tengan pareja: todos los pacientes, tengan o no ficha de glaucoma (`NULL` si no la tienen).

```sql
SELECT p.id, p.first_name, gr.clinical_stage
FROM patients p
LEFT JOIN glaucoma_records gr ON gr.patient_id = p.id
ORDER BY p.id
LIMIT 6;
```

<details><summary>Resultado</summary>

```text
+----+-----------------+----------------+
| id | first_name      | clinical_stage |
+----+-----------------+----------------+
|  1 | Juan Carlos     | MODERADO       |
|  2 | María Fernanda  | SOSPECHA       |
|  3 | Carlos Alberto  | MODERADO       |
|  4 | Ana Milena      | NULL           |
|  5 | Esperanza       | TERMINAL       |
|  6 | Pedro José      | NULL           |
+----+-----------------+----------------+
```
</details>

### LEFT JOIN ... IS NULL (anti-join)

Encuentra lo que **no** tiene pareja: pacientes sin ficha de glaucoma.

```sql
SELECT p.id, p.first_name, p.last_name
FROM patients p
LEFT JOIN glaucoma_records gr ON gr.patient_id = p.id
WHERE gr.id IS NULL;
```

<details><summary>Resultado</summary>

```text
+----+----------------+------------------+
| id | first_name     | last_name        |
+----+----------------+------------------+
| 14 | Andrés Felipe  | García Jaimes    |
| 12 | Patricia       | Herrera Díaz     |
|  4 | Ana Milena     | Martínez Silva   |
|  9 | Lucía Andrea   | Navarro Plata    |
|  6 | Pedro José     | Sánchez Rueda    |
| 15 | John David     | Smith Miller     |
|  7 | Diana Marcela  | Torres Vargas    |
| 11 | Camilo Andrés  | Vargas Gómez     |
… (9 filas en total)
+----+----------------+------------------+
```
</details>

### RIGHT JOIN

Igual que `LEFT JOIN` pero conserva todas las filas de la tabla derecha: todas las especialidades, tengan o no profesionales.

```sql
SELECT s.name AS especialidad, hp.first_name AS profesional
FROM healthcare_professionals hp
RIGHT JOIN specialties s ON s.id = hp.specialty_id;
```

<details><summary>Resultado</summary>

```text
+-----------------------------+-------------+
| especialidad                | profesional |
+-----------------------------+-------------+
| Córnea y Segmento Anterior  | Carlos      |
| Glaucoma                    | Deimer      |
| Glaucoma                    | Elena       |
| Neuroftalmología            | NULL        |
| Oftalmología                | Roberto     |
| Oftalmología                | Sofía       |
| Optometría                  | NULL        |
| Retina y Vítreo             | Javier      |
+-----------------------------+-------------+
```
</details>

### JOIN de varias tablas (el camino del paciente)

paciente → historia → consulta → medición.

```sql
SELECT CONCAT(p.first_name, ' ', p.last_name) AS paciente, DATE(mv.visit_date) AS fecha, iop.eye, iop.pressure
FROM patients p
JOIN clinical_histories ch     ON ch.patient_id = p.id
JOIN medical_visits mv         ON mv.clinical_history_id = ch.id
JOIN intraocular_pressures iop ON iop.visit_id = mv.id
WHERE p.id = 1;
```

<details><summary>Resultado</summary>

```text
+---------------------------+------------+-----+----------+
| paciente                  | fecha      | eye | pressure |
+---------------------------+------------+-----+----------+
| Juan Carlos Gómez Pérez   | 2026-01-10 | OD  |    24.50 |
| Juan Carlos Gómez Pérez   | 2026-01-10 | OI  |    22.00 |
| Juan Carlos Gómez Pérez   | 2026-03-12 | OD  |    14.00 |
| Juan Carlos Gómez Pérez   | 2026-03-12 | OI  |    13.50 |
+---------------------------+------------+-----+----------+
```
</details>

### SELF JOIN (tabla consigo misma)

Compara cada PIO del OD con la del OI de la misma consulta.

```sql
SELECT od.visit_id, od.pressure AS pio_od, oi.pressure AS pio_oi,
       ABS(od.pressure - oi.pressure) AS diferencia
FROM intraocular_pressures od
JOIN intraocular_pressures oi ON oi.visit_id = od.visit_id AND oi.eye = 'OI'
WHERE od.eye = 'OD'
ORDER BY diferencia DESC
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----------+--------+--------+------------+
| visit_id | pio_od | pio_oi | diferencia |
+----------+--------+--------+------------+
|        5 |  48.00 |  18.00 |      30.00 |
|        9 |  25.50 |  23.00 |       2.50 |
|        1 |  24.50 |  22.00 |       2.50 |
|       19 |  21.50 |  20.00 |       1.50 |
|        6 |  16.00 |  15.00 |       1.00 |
+----------+--------+--------+------------+
```
</details>

### CROSS JOIN (producto cartesiano)

Todas las combinaciones posibles: cada ojo con cada método. Úselo con cuidado.

```sql
SELECT e.ojo, m.metodo
FROM (SELECT 'OD' AS ojo UNION SELECT 'OI') e
CROSS JOIN (SELECT DISTINCT method AS metodo FROM intraocular_pressures) m;
```

<details><summary>Resultado</summary>

```text
+-----+----------+
| ojo | metodo   |
+-----+----------+
| OI  | GOLDMANN |
| OD  | GOLDMANN |
+-----+----------+
```
</details>


## 6. Subconsultas

Una consulta dentro de otra.

### Escalar (devuelve un solo valor)

Mediciones por encima del promedio general.

```sql
SELECT id, eye, pressure
FROM intraocular_pressures
WHERE pressure > (SELECT AVG(pressure) FROM intraocular_pressures)
ORDER BY pressure DESC;
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+
| id | eye | pressure |
+----+-----+----------+
|  9 | OD  |    48.00 |
| 13 | OD  |    26.00 |
| 15 | OD  |    25.50 |
| 14 | OI  |    25.00 |
|  1 | OD  |    24.50 |
|  5 | OD  |    23.00 |
| 16 | OI  |    23.00 |
|  6 | OI  |    22.50 |
… (11 filas en total)
+----+-----+----------+
```
</details>

### Con IN

Pacientes que tienen ficha de glaucoma.

```sql
SELECT id, first_name, last_name
FROM patients
WHERE id IN (SELECT patient_id FROM glaucoma_records);
```

<details><summary>Resultado</summary>

```text
+----+-----------------+-------------------+
| id | first_name      | last_name         |
+----+-----------------+-------------------+
|  1 | Juan Carlos     | Gómez Pérez       |
|  2 | María Fernanda  | Rodríguez López   |
|  3 | Carlos Alberto  | Gómez Mendoza     |
|  5 | Esperanza       | Gómez Castro      |
|  8 | Héctor Fabio    | Ramírez Ortiz     |
| 10 | Fernando        | Álvarez Niño      |
+----+-----------------+-------------------+
```
</details>

### Con NOT IN

Medicamentos que nunca se han prescrito. Cuidado: si la subconsulta devuelve un `NULL`, `NOT IN` no devuelve nada.

```sql
SELECT name
FROM medications
WHERE id NOT IN (SELECT medication_id FROM treatments);
```

<details><summary>Resultado</summary>

```text
+----------+
| name     |
+----------+
| Lumigan  |
| Travatan |
+----------+
```
</details>

### Con EXISTS

Pacientes que tienen al menos un OCT. `EXISTS` solo pregunta si hay filas.

```sql
SELECT p.id, p.first_name
FROM patients p
WHERE EXISTS (SELECT 1
              FROM clinical_histories ch
              JOIN medical_visits mv ON mv.clinical_history_id = ch.id
              JOIN oct_exams o       ON o.visit_id = mv.id
              WHERE ch.patient_id = p.id);
```

<details><summary>Resultado</summary>

```text
+----+-----------------+
| id | first_name      |
+----+-----------------+
|  1 | Juan Carlos     |
|  2 | María Fernanda  |
|  5 | Esperanza       |
| 10 | Fernando        |
+----+-----------------+
```
</details>

### Con NOT EXISTS

Pacientes sin ninguna medición de PIO.

```sql
SELECT p.id, p.first_name
FROM patients p
WHERE NOT EXISTS (SELECT 1
                  FROM clinical_histories ch
                  JOIN medical_visits mv         ON mv.clinical_history_id = ch.id
                  JOIN intraocular_pressures iop ON iop.visit_id = mv.id
                  WHERE ch.patient_id = p.id);
```

<details><summary>Resultado</summary>

```text
+----+----------------+
| id | first_name     |
+----+----------------+
| 14 | Andrés Felipe  |
|  4 | Ana Milena     |
|  9 | Lucía Andrea   |
|  6 | Pedro José     |
|  7 | Diana Marcela  |
| 11 | Camilo Andrés  |
| 13 | Rosa María     |
+----+----------------+
```
</details>

### Correlacionada

La subconsulta usa un valor de la fila exterior (`iop.eye`), por eso se evalúa por cada fila.

```sql
SELECT iop.id, iop.eye, iop.pressure
FROM intraocular_pressures iop
WHERE iop.pressure > (SELECT AVG(i2.pressure)
                      FROM intraocular_pressures i2
                      WHERE i2.eye = iop.eye)
ORDER BY iop.eye, iop.pressure DESC
LIMIT 6;
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+
| id | eye | pressure |
+----+-----+----------+
|  9 | OD  |    48.00 |
| 13 | OD  |    26.00 |
| 15 | OD  |    25.50 |
|  1 | OD  |    24.50 |
|  5 | OD  |    23.00 |
| 14 | OI  |    25.00 |
+----+-----+----------+
```
</details>

### En el SELECT

Una columna calculada con una subconsulta por fila.

```sql
SELECT s.name AS especialidad,
       (SELECT COUNT(*) FROM healthcare_professionals hp WHERE hp.specialty_id = s.id) AS profesionales
FROM specialties s;
```

<details><summary>Resultado</summary>

```text
+-----------------------------+---------------+
| especialidad                | profesionales |
+-----------------------------+---------------+
| Córnea y Segmento Anterior  |             1 |
| Glaucoma                    |             2 |
| Neuroftalmología            |             0 |
| Oftalmología                |             2 |
| Optometría                  |             0 |
| Retina y Vítreo             |             1 |
+-----------------------------+---------------+
```
</details>

### En el FROM (tabla derivada)

El resultado de una subconsulta se usa como tabla. Debe llevar alias.

```sql
SELECT ROUND(AVG(t.promedio_consulta), 2) AS promedio_de_promedios
FROM (SELECT visit_id, AVG(pressure) AS promedio_consulta
      FROM intraocular_pressures
      GROUP BY visit_id) AS t;
```

<details><summary>Resultado</summary>

```text
+-----------------------+
| promedio_de_promedios |
+-----------------------+
|                 20.73 |
+-----------------------+
```
</details>

### ANY y ALL

`> ALL` = mayor que todos; `> ANY` = mayor que al menos uno.

```sql
SELECT id, eye, pressure
FROM intraocular_pressures
WHERE pressure > ALL (SELECT target_iop_od FROM glaucoma_records)
ORDER BY pressure DESC;
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+
| id | eye | pressure |
+----+-----+----------+
|  9 | OD  |    48.00 |
| 13 | OD  |    26.00 |
| 15 | OD  |    25.50 |
| 14 | OI  |    25.00 |
|  1 | OD  |    24.50 |
|  5 | OD  |    23.00 |
| 16 | OI  |    23.00 |
|  6 | OI  |    22.50 |
… (17 filas en total)
+----+-----+----------+
```
</details>


## 7. UNION y UNION ALL

Une los resultados de varias consultas con las **mismas columnas**. `UNION` quita duplicados; `UNION ALL` los conserva y es más rápido.

### UNION ALL

Una lista con los exámenes OCT y de campo visual.

```sql
SELECT 'OCT' AS examen, visit_id, eye FROM oct_exams
UNION ALL
SELECT 'CAMPO VISUAL', visit_id, eye FROM visual_field_exams
ORDER BY visit_id
LIMIT 6;
```

<details><summary>Resultado</summary>

```text
+--------------+----------+-----+
| examen       | visit_id | eye |
+--------------+----------+-----+
| OCT          |        1 | OI  |
| CAMPO VISUAL |        1 | OI  |
| CAMPO VISUAL |        1 | OD  |
| OCT          |        1 | OD  |
| OCT          |        4 | OD  |
| CAMPO VISUAL |        4 | OI  |
+--------------+----------+-----+
```
</details>

### UNION

Consultas que tienen OCT **o** campo visual, sin repetir.

```sql
SELECT visit_id FROM oct_exams
UNION
SELECT visit_id FROM visual_field_exams
ORDER BY visit_id;
```

<details><summary>Resultado</summary>

```text
+----------+
| visit_id |
+----------+
|        1 |
|        4 |
|        8 |
|       14 |
+----------+
```
</details>


## 8. Condicionales y valores nulos

### CASE

Clasifica cada PIO en un rango clínico.

```sql
SELECT id, eye, pressure,
       CASE
           WHEN pressure < 10  THEN 'BAJA'
           WHEN pressure <= 21 THEN 'NORMAL'
           WHEN pressure <= 30 THEN 'ELEVADA'
           ELSE 'MUY ELEVADA'
       END AS clasificacion
FROM intraocular_pressures
ORDER BY pressure DESC
LIMIT 6;
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+---------------+
| id | eye | pressure | clasificacion |
+----+-----+----------+---------------+
|  9 | OD  |    48.00 | MUY ELEVADA   |
| 13 | OD  |    26.00 | ELEVADA       |
| 15 | OD  |    25.50 | ELEVADA       |
| 14 | OI  |    25.00 | ELEVADA       |
|  1 | OD  |    24.50 | ELEVADA       |
|  5 | OD  |    23.00 | ELEVADA       |
+----+-----+----------+---------------+
```
</details>

### CASE dentro de una agregación (pivote)

Convierte filas en columnas: PIO del OD y del OI en la misma fila.

```sql
SELECT visit_id,
       MAX(CASE WHEN eye = 'OD' THEN pressure END) AS pio_od,
       MAX(CASE WHEN eye = 'OI' THEN pressure END) AS pio_oi
FROM intraocular_pressures
GROUP BY visit_id
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----------+--------+--------+
| visit_id | pio_od | pio_oi |
+----------+--------+--------+
|        1 |  24.50 |  22.00 |
|        2 |  14.00 |  13.50 |
|        3 |  23.00 |  22.50 |
|        4 |  21.00 |  20.00 |
|        5 |  48.00 |  18.00 |
+----------+--------+--------+
```
</details>

### IF

Condicional corto de dos caminos: `IF(condición, si_verdadero, si_falso)`.

```sql
SELECT id, eye, pressure, IF(pressure > 21, 'Revisar', 'OK') AS alerta
FROM intraocular_pressures
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+--------+
| id | eye | pressure | alerta |
+----+-----+----------+--------+
|  3 | OD  |    14.00 | OK     |
| 21 | OD  |    15.00 | OK     |
| 11 | OD  |    16.00 | OK     |
| 17 | OD  |    16.50 | OK     |
| 19 | OD  |    19.00 | OK     |
+----+-----+----------+--------+
```
</details>

### IFNULL y COALESCE

`IFNULL(a, b)` devuelve b si a es NULL. `COALESCE` devuelve el primer valor no nulo de la lista.

```sql
SELECT first_name,
       IFNULL(email, 'Sin correo')            AS correo,
       COALESCE(email, phone, 'Sin contacto') AS contacto_principal
FROM patients
WHERE email IS NULL OR id <= 2;
```

<details><summary>Resultado</summary>

```text
+-----------------+---------------------------+---------------------------+
| first_name      | correo                    | contacto_principal        |
+-----------------+---------------------------+---------------------------+
| Juan Carlos     | juan.gomez@gmail.com      | juan.gomez@gmail.com      |
| María Fernanda  | maria.rodriguez@gmail.com | maria.rodriguez@gmail.com |
| Esperanza       | Sin correo                | 3105556677                |
| Héctor Fabio    | Sin correo                | 3138889900                |
| Rosa María      | Sin correo                | 3183334466                |
+-----------------+---------------------------+---------------------------+
```
</details>

### NULLIF

`NULLIF(a, b)` devuelve NULL si a = b. Útil para evitar dividir entre cero.

```sql
SELECT SUM(is_closed) AS cerradas, COUNT(*) AS total,
       ROUND(SUM(is_closed) / NULLIF(COUNT(*), 0) * 100, 1) AS porcentaje_cerradas
FROM medical_visits;
```

<details><summary>Resultado</summary>

```text
+----------+-------+---------------------+
| cerradas | total | porcentaje_cerradas |
+----------+-------+---------------------+
|       17 |    19 |                89.5 |
+----------+-------+---------------------+
```
</details>


## 9. Funciones de texto

### CONCAT y CONCAT_WS

`CONCAT` une textos; `CONCAT_WS` los une con un separador y omite los NULL.

```sql
SELECT CONCAT(first_name, ' ', last_name)            AS nombre_completo,
       CONCAT_WS(' | ', document_number, phone, email) AS contacto
FROM patients
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+-----------------------------------+-----------------------------------------------------+
| nombre_completo                   | contacto                                            |
+-----------------------------------+-----------------------------------------------------+
| Juan Carlos Gómez Pérez           | 1098123456 | 3151112233 | juan.gomez@gmail.com      |
| María Fernanda Rodríguez López    | 1098234567 | 3162223344 | maria.rodriguez@gmail.com |
| Carlos Alberto Gómez Mendoza      | 91234567 | 3173334455 | carlos.gomez@hotmail.com    |
+-----------------------------------+-----------------------------------------------------+
```
</details>

### UPPER, LOWER y LENGTH

Mayúsculas, minúsculas y longitud en bytes (`CHAR_LENGTH` la da en caracteres).

```sql
SELECT UPPER(last_name) AS mayus, LOWER(first_name) AS minus,
       LENGTH(last_name) AS bytes, CHAR_LENGTH(last_name) AS caracteres
FROM patients
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+----------------+----------------+-------+------------+
| mayus          | minus          | bytes | caracteres |
+----------------+----------------+-------+------------+
| ÁLVAREZ NIÑO   | fernando       |    14 |         12 |
| GARCÍA JAIMES  | andrés felipe  |    14 |         13 |
| GÓMEZ CASTRO   | esperanza      |    13 |         12 |
+----------------+----------------+-------+------------+
```
</details>

### SUBSTRING, LEFT y RIGHT

Extraen partes de un texto.

```sql
SELECT document_number,
       LEFT(document_number, 3)       AS primeros_3,
       RIGHT(document_number, 4)      AS ultimos_4,
       SUBSTRING(document_number, 2, 5) AS desde_2_cinco
FROM patients
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+-----------------+------------+-----------+---------------+
| document_number | primeros_3 | ultimos_4 | desde_2_cinco |
+-----------------+------------+-----------+---------------+
| 1095345678      | 109        | 5678      | 09534         |
| 1096678901      | 109        | 8901      | 09667         |
| 1098123456      | 109        | 3456      | 09812         |
+-----------------+------------+-----------+---------------+
```
</details>

### REPLACE, TRIM y LOCATE

`REPLACE` sustituye, `TRIM` quita espacios, `LOCATE` busca la posición.

```sql
SELECT email,
       REPLACE(email, '@', ' [arroba] ') AS reemplazado,
       LOCATE('@', email)               AS posicion_arroba,
       TRIM('   texto   ')               AS sin_espacios
FROM patients
WHERE email IS NOT NULL
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+-------------------------+----------------------------------+-----------------+--------------+
| email                   | reemplazado                      | posicion_arroba | sin_espacios |
+-------------------------+----------------------------------+-----------------+--------------+
| ana.martinez@gmail.com  | ana.martinez [arroba] gmail.com  |              13 | texto        |
| andres.garcia@gmail.com | andres.garcia [arroba] gmail.com |              14 | texto        |
| camilo.vargas@gmail.com | camilo.vargas [arroba] gmail.com |              14 | texto        |
+-------------------------+----------------------------------+-----------------+--------------+
```
</details>


## 10. Funciones numéricas

### ROUND, TRUNCATE, CEIL, FLOOR, ABS, MOD

Redondeo, corte de decimales, techo, piso, valor absoluto y residuo.

```sql
SELECT 21.678            AS valor,
       ROUND(21.678, 1)    AS round_1,
       TRUNCATE(21.678, 1) AS truncate_1,
       CEIL(21.2)          AS ceil,
       FLOOR(21.8)         AS floor,
       ABS(-4.5)           AS abs,
       MOD(17, 5)          AS mod_17_5;
```

<details><summary>Resultado</summary>

```text
+--------+---------+------------+------+-------+-----+----------+
| valor  | round_1 | truncate_1 | ceil | floor | abs | mod_17_5 |
+--------+---------+------------+------+-------+-----+----------+
| 21.678 |    21.7 |       21.6 |   22 |    21 | 4.5 |        2 |
+--------+---------+------------+------+-------+-----+----------+
```
</details>


## 11. Funciones de fecha

### NOW, CURDATE, YEAR, MONTH, DAY

Fecha y hora actuales y partes de una fecha.

```sql
SELECT DATE(visit_date) AS fecha, YEAR(visit_date) AS anio, MONTH(visit_date) AS mes,
       DAY(visit_date) AS dia, DAYNAME(visit_date) AS dia_semana
FROM medical_visits
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+------------+------+------+------+------------+
| fecha      | anio | mes  | dia  | dia_semana |
+------------+------+------+------+------------+
| 2025-11-12 | 2025 |   11 |   12 | Wednesday  |
| 2026-01-10 | 2026 |    1 |   10 | Saturday   |
| 2026-01-15 | 2026 |    1 |   15 | Thursday   |
+------------+------+------+------+------------+
```
</details>

### TIMESTAMPDIFF

Diferencia entre dos fechas en la unidad que se pida: la edad en años.

```sql
SELECT first_name, birth_date,
       TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS edad
FROM patients
ORDER BY edad DESC
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----------------+------------+------+
| first_name     | birth_date | edad |
+----------------+------------+------+
| Rosa María     | 1945-12-15 |   80 |
| Esperanza      | 1948-09-18 |   78 |
| Héctor Fabio   | 1950-04-25 |   76 |
| Carlos Alberto | 1952-11-05 |   73 |
| Juan Carlos    | 1958-03-15 |   68 |
+----------------+------------+------+
```
</details>

### DATEDIFF

Días entre dos fechas.

```sql
SELECT id, start_date, end_date, DATEDIFF(end_date, start_date) AS dias_tratamiento
FROM treatments
WHERE end_date IS NOT NULL
LIMIT 5;
```

<details><summary>Resultado</summary>

```text
+----+------------+------------+------------------+
| id | start_date | end_date   | dias_tratamiento |
+----+------------+------------+------------------+
|  1 | 2026-01-10 | 2026-07-10 |              181 |
|  2 | 2026-01-10 | 2026-07-10 |              181 |
|  3 | 2026-02-18 | 2026-08-18 |              181 |
|  4 | 2026-02-05 | 2026-02-08 |                3 |
|  5 | 2026-02-05 | 2026-02-12 |                7 |
+----+------------+------------+------------------+
```
</details>

### DATE_ADD y DATE_SUB

Suma o resta intervalos: próxima cita de control a los 3 meses.

```sql
SELECT id, DATE(visit_date) AS consulta,
       DATE_ADD(DATE(visit_date), INTERVAL 3 MONTH) AS proximo_control,
       DATE_SUB(DATE(visit_date), INTERVAL 7 DAY)   AS una_semana_antes
FROM medical_visits
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+----+------------+-----------------+------------------+
| id | consulta   | proximo_control | una_semana_antes |
+----+------------+-----------------+------------------+
| 13 | 2025-11-12 | 2026-02-12      | 2025-11-05       |
|  1 | 2026-01-10 | 2026-04-10      | 2026-01-03       |
|  3 | 2026-01-15 | 2026-04-15      | 2026-01-08       |
+----+------------+-----------------+------------------+
```
</details>

### DATE_FORMAT

Da formato a una fecha: `%d` día, `%m` mes, `%Y` año, `%H:%i` hora.

```sql
SELECT DATE_FORMAT(visit_date, '%d/%m/%Y %H:%i') AS fecha_formateada
FROM medical_visits
LIMIT 3;
```

<details><summary>Resultado</summary>

```text
+------------------+
| fecha_formateada |
+------------------+
| 12/11/2025 14:00 |
| 10/01/2026 09:00 |
| 15/01/2026 11:00 |
+------------------+
```
</details>

### Agrupar por mes

Consultas por mes con `DATE_FORMAT` en el `GROUP BY`.

```sql
SELECT DATE_FORMAT(visit_date, '%Y-%m') AS mes, COUNT(*) AS consultas
FROM medical_visits
GROUP BY mes
ORDER BY mes;
```

<details><summary>Resultado</summary>

```text
+---------+-----------+
| mes     | consultas |
+---------+-----------+
| 2025-11 |         1 |
| 2026-01 |         5 |
| 2026-02 |         7 |
| 2026-03 |         6 |
+---------+-----------+
```
</details>


## 12. Conversión de tipos

### CAST y CONVERT

Cambia el tipo de un valor.

```sql
SELECT CAST('2026-03-15' AS DATE)    AS texto_a_fecha,
       CAST(21.75 AS SIGNED)        AS decimal_a_entero,
       CONVERT(48, CHAR)            AS numero_a_texto;
```

<details><summary>Resultado</summary>

```text
+---------------+------------------+----------------+
| texto_a_fecha | decimal_a_entero | numero_a_texto |
+---------------+------------------+----------------+
| 2026-03-15    |               22 | 48             |
+---------------+------------------+----------------+
```
</details>


## 13. Funciones de ventana (MySQL 8)

Calculan sobre un grupo de filas **sin colapsarlas** como hace `GROUP BY`. Se escriben con `OVER (PARTITION BY … ORDER BY …)`.

### ROW_NUMBER, RANK y DENSE_RANK

Numeran filas dentro de cada ojo, de mayor a menor PIO. `RANK` deja huecos en los empates; `DENSE_RANK` no.

```sql
SELECT eye, pressure,
       ROW_NUMBER() OVER (PARTITION BY eye ORDER BY pressure DESC) AS fila,
       RANK()       OVER (PARTITION BY eye ORDER BY pressure DESC) AS rango,
       DENSE_RANK() OVER (PARTITION BY eye ORDER BY pressure DESC) AS rango_denso
FROM intraocular_pressures
WHERE eye = 'OI';
```

<details><summary>Resultado</summary>

```text
+-----+----------+------+-------+-------------+
| eye | pressure | fila | rango | rango_denso |
+-----+----------+------+-------+-------------+
| OI  |    25.00 |    1 |     1 |           1 |
| OI  |    23.00 |    2 |     2 |           2 |
| OI  |    22.50 |    3 |     3 |           3 |
| OI  |    22.00 |    4 |     4 |           4 |
| OI  |    20.00 |    5 |     5 |           5 |
| OI  |    20.00 |    6 |     5 |           5 |
| OI  |    18.50 |    7 |     7 |           6 |
| OI  |    18.00 |    8 |     8 |           7 |
… (12 filas en total)
+-----+----------+------+-------+-------------+
```
</details>

### Agregación como ventana

Cada medición junto al promedio de su ojo, sin perder el detalle.

```sql
SELECT id, eye, pressure,
       ROUND(AVG(pressure) OVER (PARTITION BY eye), 2)  AS promedio_ojo,
       ROUND(pressure - AVG(pressure) OVER (PARTITION BY eye), 2) AS diferencia
FROM intraocular_pressures
LIMIT 6;
```

<details><summary>Resultado</summary>

```text
+----+-----+----------+--------------+------------+
| id | eye | pressure | promedio_ojo | diferencia |
+----+-----+----------+--------------+------------+
| 21 | OD  |    15.00 |        22.50 |      -7.50 |
|  3 | OD  |    14.00 |        22.50 |      -8.50 |
|  9 | OD  |    48.00 |        22.50 |      25.50 |
| 13 | OD  |    26.00 |        22.50 |       3.50 |
| 15 | OD  |    25.50 |        22.50 |       3.00 |
|  1 | OD  |    24.50 |        22.50 |       2.00 |
+----+-----+----------+--------------+------------+
```
</details>

### LAG y LEAD

Valor de la fila anterior o siguiente: cómo cambió la PIO de un ojo entre consultas.

```sql
SELECT ch.patient_id, iop.eye, DATE(mv.visit_date) AS fecha, iop.pressure,
       LAG(iop.pressure) OVER (PARTITION BY ch.patient_id, iop.eye ORDER BY mv.visit_date) AS anterior,
       iop.pressure - LAG(iop.pressure) OVER (PARTITION BY ch.patient_id, iop.eye ORDER BY mv.visit_date) AS cambio
FROM intraocular_pressures iop
JOIN medical_visits mv     ON mv.id = iop.visit_id
JOIN clinical_histories ch ON ch.id = mv.clinical_history_id
WHERE ch.patient_id IN (1, 5)
ORDER BY ch.patient_id, iop.eye, fecha;
```

<details><summary>Resultado</summary>

```text
+------------+-----+------------+----------+----------+--------+
| patient_id | eye | fecha      | pressure | anterior | cambio |
+------------+-----+------------+----------+----------+--------+
|          1 | OD  | 2026-01-10 |    24.50 |     NULL |   NULL |
|          1 | OD  | 2026-03-12 |    14.00 |    24.50 | -10.50 |
|          1 | OI  | 2026-01-10 |    22.00 |     NULL |   NULL |
|          1 | OI  | 2026-03-12 |    13.50 |    22.00 |  -8.50 |
|          5 | OD  | 2026-01-25 |    26.00 |     NULL |   NULL |
|          5 | OD  | 2026-03-05 |    25.50 |    26.00 |  -0.50 |
|          5 | OI  | 2026-01-25 |    25.00 |     NULL |   NULL |
|          5 | OI  | 2026-03-05 |    23.00 |    25.00 |  -2.00 |
+------------+-----+------------+----------+----------+--------+
```
</details>


## 14. CTE: consultas con WITH

Una CTE es una subconsulta con nombre, declarada antes del `SELECT`. Hace legible una consulta larga.

### WITH

Primero se calcula el promedio por paciente y luego se filtra.

```sql
WITH pio_paciente AS (
    SELECT ch.patient_id, ROUND(AVG(iop.pressure), 2) AS promedio
    FROM intraocular_pressures iop
    JOIN medical_visits mv     ON mv.id = iop.visit_id
    JOIN clinical_histories ch ON ch.id = mv.clinical_history_id
    GROUP BY ch.patient_id
)
SELECT p.first_name, p.last_name, pp.promedio
FROM pio_paciente pp
JOIN patients p ON p.id = pp.patient_id
WHERE pp.promedio > 20
ORDER BY pp.promedio DESC;
```

<details><summary>Resultado</summary>

```text
+-----------------+-------------------+----------+
| first_name      | last_name         | promedio |
+-----------------+-------------------+----------+
| Esperanza       | Gómez Castro      |    24.88 |
| Carlos Alberto  | Gómez Mendoza     |    24.25 |
| María Fernanda  | Rodríguez López   |    21.63 |
| John David      | Smith Miller      |    20.75 |
+-----------------+-------------------+----------+
```
</details>

### WITH RECURSIVE

Una CTE que se llama a sí misma: genera los meses 1 a 6 para que el reporte muestre también los meses sin consultas (con 0).

```sql
WITH RECURSIVE meses AS (
    SELECT 1 AS mes
    UNION ALL
    SELECT mes + 1 FROM meses WHERE mes < 6
)
SELECT m.mes, COUNT(mv.id) AS consultas_2026
FROM meses m
LEFT JOIN medical_visits mv ON MONTH(mv.visit_date) = m.mes AND YEAR(mv.visit_date) = 2026
GROUP BY m.mes;
```

<details><summary>Resultado</summary>

```text
+------+----------------+
| mes  | consultas_2026 |
+------+----------------+
|    1 |              5 |
|    2 |              7 |
|    3 |              6 |
|    4 |              0 |
|    5 |              0 |
|    6 |              0 |
+------+----------------+
```
</details>


## 15. Modificar datos: INSERT, UPDATE, DELETE

Los ejemplos se ejecutan dentro de `START TRANSACTION … ROLLBACK`, así que no cambian la base. Sin `ROLLBACK`, los cambios serían permanentes al hacer `COMMIT`.

### INSERT

Inserta una fila. Las columnas con `DEFAULT` o `AUTO_INCREMENT` pueden omitirse.

```sql
START TRANSACTION;
INSERT INTO intraocular_pressures (visit_id, eye, pressure, method)
VALUES (18, 'OD', 16.50, 'ICARE');
SELECT id, visit_id, eye, pressure, method FROM intraocular_pressures WHERE id = LAST_INSERT_ID();
ROLLBACK;
```

<details><summary>Resultado</summary>

```text
+----+----------+-----+----------+--------+
| id | visit_id | eye | pressure | method |
+----+----------+-----+----------+--------+
| 31 |       18 | OD  |    16.50 | ICARE  |
+----+----------+-----+----------+--------+
```
</details>

### INSERT de varias filas

Varias filas en una sola sentencia.

```sql
START TRANSACTION;
INSERT INTO intraocular_pressures (visit_id, eye, pressure, method)
VALUES (18, 'OD', 16.50, 'ICARE'),
       (18, 'OI', 17.00, 'ICARE');
SELECT ROW_COUNT() AS filas_insertadas;
ROLLBACK;
```

<details><summary>Resultado</summary>

```text
+------------------+
| filas_insertadas |
+------------------+
|                2 |
+------------------+
```
</details>

### UPDATE

**Siempre** con `WHERE`: sin él se modifican todas las filas.

```sql
START TRANSACTION;
UPDATE medications SET presentation = 'Frasco gotero x 5 ml' WHERE generic_name = 'Latanoprost';
SELECT name, generic_name, presentation FROM medications WHERE generic_name = 'Latanoprost';
ROLLBACK;
```

<details><summary>Resultado</summary>

```text
+---------+--------------+----------------------+
| name    | generic_name | presentation         |
+---------+--------------+----------------------+
| Xalatan | Latanoprost  | Frasco gotero x 5 ml |
+---------+--------------+----------------------+
```
</details>

### UPDATE con JOIN

Actualiza usando datos de otra tabla: pone una nota en las PIO del paciente 1.

```sql
START TRANSACTION;
UPDATE intraocular_pressures iop
JOIN medical_visits mv     ON mv.id = iop.visit_id
JOIN clinical_histories ch ON ch.id = mv.clinical_history_id
SET iop.notes = 'Revisado en junta'
WHERE ch.patient_id = 1;
SELECT ROW_COUNT() AS filas_actualizadas;
ROLLBACK;
```

<details><summary>Resultado</summary>

```text
+--------------------+
| filas_actualizadas |
+--------------------+
|                  4 |
+--------------------+
```
</details>

### DELETE

**Siempre** con `WHERE`. Las FK pueden impedirlo (`RESTRICT`) o borrar en cascada (`CASCADE`).

```sql
START TRANSACTION;
DELETE FROM intraocular_pressures WHERE visit_id = 19;
SELECT ROW_COUNT() AS filas_borradas;
ROLLBACK;
```

<details><summary>Resultado</summary>

```text
+----------------+
| filas_borradas |
+----------------+
|              2 |
+----------------+
```
</details>

### INSERT … SELECT

Inserta el resultado de una consulta.

```sql
START TRANSACTION;
INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by)
SELECT 'glaucoma_records', id, 'ALERT', JSON_OBJECT('estadio', clinical_stage), 'GUIA_SQL'
FROM glaucoma_records
WHERE clinical_stage IN ('AVANZADO', 'TERMINAL');
SELECT ROW_COUNT() AS alertas_creadas;
ROLLBACK;
```

<details><summary>Resultado</summary>

```text
+-----------------+
| alertas_creadas |
+-----------------+
|               2 |
+-----------------+
```
</details>


## 16. JSON

MySQL 8 guarda y consulta JSON. La tabla `audit_logs` lo usa en `old_values` y `new_values`.

### JSON_OBJECT y JSON_EXTRACT (->>)

`JSON_OBJECT` crea un JSON; `->>` extrae un valor como texto.

```sql
SELECT JSON_OBJECT('ojo', eye, 'pio', pressure) AS como_json
FROM intraocular_pressures
LIMIT 2;
```

<details><summary>Resultado</summary>

```text
+-----------------------------+
| como_json                   |
+-----------------------------+
| {"ojo": "OD", "pio": 14.00} |
| {"ojo": "OD", "pio": 15.00} |
+-----------------------------+
```
</details>

### Leer JSON guardado

Extrae campos del JSON de la auditoría.

```sql
SELECT table_name, action,
       new_values->>'$.first_name' AS nombre,
       new_values->>'$.last_name'  AS apellido,
       JSON_EXTRACT(new_values, '$.first_name') AS con_json_extract
FROM audit_logs
WHERE table_name = 'patients';
```

<details><summary>Resultado</summary>

```text
+------------+--------+----------------+----------------+------------------+
| table_name | action | nombre         | apellido       | con_json_extract |
+------------+--------+----------------+----------------+------------------+
| patients   | INSERT | Juan Carlos    | Gómez Pérez    | "Juan Carlos"    |
| patients   | INSERT | Carlos Alberto | Gómez Mendoza  | "Carlos Alberto" |
+------------+--------+----------------+----------------+------------------+
```
</details>


## 17. Objetos de la base (resumen de sintaxis)

Plantillas de los objetos del taller. Están probadas en `docs/06_practica_examen.md` y en los scripts de `sql/`.

| Objeto | Plantilla |
|---|---|
| **Vista** | `CREATE OR REPLACE VIEW vw_nombre AS SELECT …;` |
| **Procedimiento** | `DELIMITER $$` · `CREATE PROCEDURE sp_nombre(IN p_x INT, OUT p_msg VARCHAR(100)) BEGIN … END $$` · `DELIMITER ;` · se llama con `CALL sp_nombre(1, @msg); SELECT @msg;` |
| **Función** | `CREATE FUNCTION fn_nombre(p_x INT) RETURNS VARCHAR(20) READS SQL DATA BEGIN … RETURN …; END $$` · se usa dentro de un `SELECT` |
| **Trigger** | `CREATE TRIGGER trg_nombre BEFORE INSERT ON tabla FOR EACH ROW BEGIN … END $$` · `NEW.col` (fila nueva) y `OLD.col` (fila anterior) |
| **Evento** | `CREATE EVENT ev_nombre ON SCHEDULE EVERY 1 DAY DO …;` (requiere `event_scheduler = ON`) |
| **Variables** | `DECLARE v_total INT DEFAULT 0;` · `SET v_total = (SELECT COUNT(*) FROM …);` |
| **Condicionales** | `IF cond THEN … ELSEIF cond THEN … ELSE … END IF;` |
| **Ciclos** | `WHILE cond DO … END WHILE;` · `REPEAT … UNTIL cond END REPEAT;` · `etiqueta: LOOP … LEAVE etiqueta; END LOOP;` |
| **Errores** | `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '…';` · `DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;` |
| **Transacción** | `START TRANSACTION; … COMMIT;` o `ROLLBACK;` · `SAVEPOINT sp1; … ROLLBACK TO sp1;` |
| **Índice** | `CREATE INDEX idx_nombre ON tabla (col1, col2);` · comprobar con `EXPLAIN SELECT …;` |

---

## Errores frecuentes

| Error | Causa | Solución |
|---|---|---|
| `Expression #… isn't in GROUP BY` | Columna sin agregar fuera del `GROUP BY` (modo `ONLY_FULL_GROUP_BY`) | Agregarla al `GROUP BY` o envolverla en una función de agregación |
| `Unknown column 'alias' in 'where clause'` | Alias del `SELECT` usado en el `WHERE` | Repetir la expresión o usar una subconsulta/CTE |
| `= NULL` no devuelve nada | `NULL` no es igual a nada, ni a sí mismo | Usar `IS NULL` / `IS NOT NULL` |
| `NOT IN` devuelve vacío | La subconsulta contiene un `NULL` | Usar `NOT EXISTS` o filtrar `WHERE col IS NOT NULL` |
| Conteos inflados | Varios `LEFT JOIN` antes de `COUNT(*)` multiplican filas | `COUNT(DISTINCT …)` o una subconsulta por conteo |
| `Every derived table must have its own alias` | Subconsulta en el `FROM` sin alias | `FROM (SELECT …) AS t` |
| Error de sintaxis en procedimientos | Falta cambiar el delimitador | `DELIMITER $$ … END $$ DELIMITER ;` |
