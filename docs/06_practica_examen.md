# 6. Práctica para el Examen

Seis ejercicios nuevos, uno por cada tipo de objeto del taller: **consulta, subconsulta, procedimiento, función, vista y trigger**. Están escritos como "nuevos requerimientos" sobre la base `oftalmologia_glaucoma_db`, en el estilo que puede pedir el profesor.

**Cómo practicar**

1. Despliegue la base limpia: `bash tests/run_all.sh` (Linux/macOS) o `tests\run_all.cmd` (Windows).
2. Resuelva cada ejercicio en phpMyAdmin (`http://localhost:8081`) o con el cliente `mysql`, **sin mirar la solución**.
3. Compare su resultado con el **resultado esperado** y ejecute las **pruebas** de cada ejercicio.
4. Abra la solución solo al final. Para dejar la base como estaba, vuelva a ejecutar `run_all`.

> La base usa el modo `ONLY_FULL_GROUP_BY`: toda columna del `SELECT` que no esté dentro de una función de agregación debe aparecer en el `GROUP BY`.

### Tablas que va a necesitar

```
patients(id, first_name, last_name, …)
clinical_histories(id, patient_id, …)                  -- 1 por paciente
medical_visits(id, clinical_history_id, visit_date, is_closed, …)
intraocular_pressures(id, visit_id, eye, pressure, measurement_time, method)
glaucoma_records(id, patient_id, target_iop_od, target_iop_oi, clinical_stage, …)
oct_exams(id, visit_id, eye, …)
treatments(id, visit_id, medication_id, is_active, …)
```

Camino para llegar del paciente a sus mediciones:
`patients → clinical_histories (patient_id) → medical_visits (clinical_history_id) → intraocular_pressures (visit_id)`

---

## Ejercicio 1 · Consulta

**Requerimiento:** el área de glaucoma necesita un reporte con los pacientes cuya **presión intraocular promedio supera los 21 mmHg** en algún ojo. Para cada paciente y ojo muestre: id del paciente, nombre completo, ojo, número de mediciones, PIO promedio (2 decimales) y PIO máxima. Ordene de mayor a menor promedio.

**Pistas:** `JOIN` de 4 tablas, `GROUP BY` por paciente y ojo, el filtro sobre el promedio va en `HAVING`, no en `WHERE`.

**Resultado esperado (6 filas):**

| patient_id | paciente | eye | mediciones | pio_promedio | pio_maxima |
|---|---|---|---|---|---|
| 3 | Carlos Alberto Gómez Mendoza | OD | 2 | 32.00 | 48.00 |
| 5 | Esperanza Gómez Castro | OD | 2 | 25.75 | 26.00 |
| 5 | Esperanza Gómez Castro | OI | 2 | 24.00 | 25.00 |
| 2 | María Fernanda Rodríguez López | OD | 2 | 22.00 | 23.00 |
| 15 | John David Smith Miller | OD | 1 | 21.50 | 21.50 |
| 2 | María Fernanda Rodríguez López | OI | 2 | 21.25 | 22.50 |

**Preguntas para la sustentación**
- ¿Por qué el filtro va en `HAVING` y no en `WHERE`?
- ¿Qué pasaría si quitara `iop.eye` del `GROUP BY`?

---

## Ejercicio 2 · Subconsulta

**Requerimiento:** liste las mediciones de presión intraocular que están **por encima del promedio general de su mismo ojo**: las del OD comparadas con el promedio de todos los OD y las del OI con el promedio de todos los OI. Muestre id de la medición, paciente, ojo, presión y fecha de la consulta. Ordene por ojo y por presión descendente.

**Pistas:** es una **subconsulta correlacionada**: la subconsulta del `WHERE` usa el ojo de la fila exterior. Los promedios reales son OD = 22.50 y OI = 18.96.

**Resultado esperado (11 filas):** 5 del OD (48.00, 26.00, 25.50, 24.50, 23.00) y 6 del OI (25.00, 23.00, 22.50, 22.00, 20.00, 20.00).

**Preguntas para la sustentación**
- ¿Qué diferencia hay entre una subconsulta correlacionada y una que no lo es?
- ¿Cuántas veces se evalúa la subconsulta?

---

## Ejercicio 3 · Procedimiento almacenado

**Requerimiento:** cree `sp_registrar_pio_bilateral` para registrar en un solo paso la PIO de **ambos ojos** de una consulta.

- Parámetros: `p_visit_id`, `p_pio_od`, `p_pio_oi`, `p_metodo` (entrada) y `p_mensaje` (salida).
- Si la consulta **no existe**, error `'La consulta no existe'`.
- Si la consulta **está cerrada** (`is_closed = TRUE`), error `'La consulta está cerrada: no admite nuevas mediciones'`.
- Las dos mediciones se insertan en **una transacción**: si una falla, no debe quedar ninguna.
- Al terminar, `p_mensaje` debe decir, por ejemplo: `PIO registrada en la consulta 18: OD 17.50 / OI 18.00 mmHg`.

**Pistas:** `DELIMITER $$`, `DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;`, `SIGNAL SQLSTATE '45000'`, `START TRANSACTION` … `COMMIT`. Las consultas 18 y 19 están abiertas; la 1 a la 17, cerradas.

**Pruebas**

```sql
CALL sp_registrar_pio_bilateral(18, 17.5, 18.0, 'GOLDMANN', @msg);  -- correcto
SELECT @msg;
CALL sp_registrar_pio_bilateral(1, 15, 15, 'GOLDMANN', @msg);       -- error: cerrada
CALL sp_registrar_pio_bilateral(999, 15, 15, 'GOLDMANN', @msg);     -- error: no existe
CALL sp_registrar_pio_bilateral(19, 15, 95, 'GOLDMANN', @msg);      -- error: 95 > 80
SELECT COUNT(*) FROM intraocular_pressures
WHERE visit_id = 19 AND pressure = 15;                               -- debe dar 0 (se revirtió el OD)
```

**Preguntas para la sustentación**
- ¿Por qué la última prueba deja 0 filas aunque la PIO del OD (15) era válida?
- ¿Para qué sirve `RESIGNAL` después del `ROLLBACK`?

---

## Ejercicio 4 · Función

**Requerimiento:** cree `fn_estado_pio(p_patient_id, p_eye)` que compare la **última PIO** medida en un ojo con la **PIO objetivo** de ese ojo (`glaucoma_records`) y devuelva:

| Devuelve | Cuándo |
|---|---|
| `'SIN FICHA'` | El paciente no tiene ficha de glaucoma |
| `'SIN MEDICION'` | Tiene ficha, pero ninguna PIO en ese ojo |
| `'EN META'` | Última PIO ≤ PIO objetivo |
| `'FUERA DE META'` | Última PIO > PIO objetivo |

**Pistas:** `RETURNS VARCHAR(20)` y `READS SQL DATA`. La "última" es la de la consulta más reciente: `ORDER BY mv.visit_date DESC LIMIT 1`. Asignar con `SET v = (SELECT …)` evita el aviso que da `SELECT … INTO` cuando no hay filas.

**Prueba y resultado esperado**

```sql
SELECT gr.patient_id,
       fn_estado_pio(gr.patient_id, 'OD') AS estado_od,
       fn_estado_pio(gr.patient_id, 'OI') AS estado_oi
FROM glaucoma_records gr;
SELECT fn_estado_pio(4, 'OD');   -- 'SIN FICHA'
```

| patient_id | estado_od | estado_oi |
|---|---|---|
| 1 | EN META | EN META |
| 2 | FUERA DE META | FUERA DE META |
| 3 | FUERA DE META | EN META |
| 5 | FUERA DE META | FUERA DE META |
| 8 | FUERA DE META | FUERA DE META |
| 10 | FUERA DE META | FUERA DE META |

**Preguntas para la sustentación**
- ¿Qué diferencia hay entre `DETERMINISTIC` y `READS SQL DATA`? ¿Por qué esta función no es determinista?
- ¿Por qué el paciente 3 está fuera de meta en un ojo y en meta en el otro?

---

## Ejercicio 5 · Vista

**Requerimiento:** cree la vista `vw_resumen_clinico_paciente` con una fila por paciente: id, nombre completo, número de consultas, número de mediciones de PIO, número de estudios OCT, número de tratamientos activos y fecha de la última consulta.

**Pistas:** **cuidado con la multiplicación de filas**. Si une consultas, PIO y OCT con varios `LEFT JOIN` y luego cuenta, los conteos salen inflados: 2 PIO × 2 OCT = 4 filas. Use una **subconsulta por columna** o `COUNT(DISTINCT …)`.

**Prueba:** `SELECT * FROM vw_resumen_clinico_paciente WHERE patient_id IN (1, 3, 5);`

| patient_id | consultas | mediciones_pio | estudios_oct |
|---|---|---|---|
| 1 | 2 | 4 | 2 |
| 3 | 2 | 4 | 0 |
| 5 | 2 | 4 | 2 |

**Preguntas para la sustentación**
- ¿Una vista guarda datos? ¿Qué pasa con ella si inserto una consulta nueva?
- Muestre con un ejemplo por qué varios `LEFT JOIN` + `COUNT(*)` inflan los conteos.

---

## Ejercicio 6 · Trigger

**Requerimiento:** la normativa exige conservar la historia clínica. Cree un trigger que **impida eliminar una consulta cerrada** (`is_closed = TRUE`) con el mensaje `'No se puede eliminar una consulta cerrada: forma parte de la historia clínica'`. Las consultas abiertas sí se pueden borrar.

**Pistas:** `BEFORE DELETE ON medical_visits`, `FOR EACH ROW`, pseudo-registro `OLD`. Ya existe otro `BEFORE DELETE` en esa tabla (`trg_bd_visits_backup`); con `PRECEDES trg_bd_visits_backup` el suyo se ejecuta primero.

**Pruebas**

```sql
DELETE FROM medical_visits WHERE id = 1;                       -- error: está cerrada
SELECT COUNT(*) FROM medical_visits WHERE id = 1;              -- 1: sigue existiendo
SELECT COUNT(*) FROM medical_visits_backup WHERE id = 1;       -- 0: no quedó respaldo huérfano
```

**Preguntas para la sustentación**
- ¿Por qué `BEFORE` y no `AFTER`?
- Si el trigger de respaldo se ejecutara primero, ¿quedaría la copia en `medical_visits_backup` después del error? ¿Por qué?

**Reto extra:** un trigger `BEFORE INSERT ON glaucoma_controls` que impida registrar un control cuya consulta (`visit_id`) pertenezca a un paciente distinto al de la ficha (`glaucoma_record_id`).

---

## Soluciones

Ábralas solo después de intentarlo. Todas se probaron en la base del proyecto.

<details>
<summary><b>Solución 1 · Consulta</b></summary>

```sql
SELECT p.id AS patient_id,
       CONCAT(p.first_name, ' ', p.last_name) AS paciente,
       iop.eye,
       COUNT(*)                    AS mediciones,
       ROUND(AVG(iop.pressure), 2) AS pio_promedio,
       MAX(iop.pressure)           AS pio_maxima
FROM patients p
JOIN clinical_histories ch     ON ch.patient_id = p.id
JOIN medical_visits mv         ON mv.clinical_history_id = ch.id
JOIN intraocular_pressures iop ON iop.visit_id = mv.id
GROUP BY p.id, paciente, iop.eye
HAVING AVG(iop.pressure) > 21
ORDER BY pio_promedio DESC;
```

`WHERE` filtra filas **antes** de agrupar; `HAVING` filtra grupos **después**. El promedio solo existe después de agrupar.
</details>

<details>
<summary><b>Solución 2 · Subconsulta</b></summary>

```sql
SELECT iop.id,
       CONCAT(p.first_name, ' ', p.last_name) AS paciente,
       iop.eye,
       iop.pressure,
       DATE(mv.visit_date) AS fecha
FROM intraocular_pressures iop
JOIN medical_visits mv     ON mv.id = iop.visit_id
JOIN clinical_histories ch ON ch.id = mv.clinical_history_id
JOIN patients p            ON p.id = ch.patient_id
WHERE iop.pressure > (SELECT AVG(i2.pressure)
                      FROM intraocular_pressures i2
                      WHERE i2.eye = iop.eye)      -- correlación con la fila exterior
ORDER BY iop.eye, iop.pressure DESC;
```

La subconsulta depende de `iop.eye`, por eso se evalúa por cada fila exterior.
</details>

<details>
<summary><b>Solución 3 · Procedimiento</b></summary>

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_registrar_pio_bilateral $$
CREATE PROCEDURE sp_registrar_pio_bilateral(
    IN  p_visit_id BIGINT,
    IN  p_pio_od   DECIMAL(5,2),
    IN  p_pio_oi   DECIMAL(5,2),
    IN  p_metodo   VARCHAR(20),
    OUT p_mensaje  VARCHAR(200))
BEGIN
    DECLARE v_cerrada BOOLEAN DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_cerrada = (SELECT is_closed FROM medical_visits WHERE id = p_visit_id);
    IF v_cerrada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La consulta no existe';
    END IF;
    IF v_cerrada = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La consulta está cerrada: no admite nuevas mediciones';
    END IF;

    START TRANSACTION;
        INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method)
        VALUES (p_visit_id, 'OD', p_pio_od, CURTIME(), p_metodo),
               (p_visit_id, 'OI', p_pio_oi, CURTIME(), p_metodo);
    COMMIT;

    SET p_mensaje = CONCAT('PIO registrada en la consulta ', p_visit_id,
                           ': OD ', p_pio_od, ' / OI ', p_pio_oi, ' mmHg');
END $$
DELIMITER ;
```

Con PIO 95, el trigger `trg_bi_iop_check_max_plausible` lanza un error; el `EXIT HANDLER` hace `ROLLBACK` (se deshace también el OD) y `RESIGNAL` devuelve el error original a quien llamó.
</details>

<details>
<summary><b>Solución 4 · Función</b></summary>

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_estado_pio $$
CREATE FUNCTION fn_estado_pio(p_patient_id BIGINT, p_eye VARCHAR(2))
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_meta   DECIMAL(5,2);
    DECLARE v_ultima DECIMAL(5,2);

    SET v_meta = (SELECT IF(p_eye = 'OD', target_iop_od, target_iop_oi)
                  FROM glaucoma_records
                  WHERE patient_id = p_patient_id);
    IF v_meta IS NULL THEN
        RETURN 'SIN FICHA';
    END IF;

    SET v_ultima = (SELECT iop.pressure
                    FROM intraocular_pressures iop
                    JOIN medical_visits mv     ON mv.id = iop.visit_id
                    JOIN clinical_histories ch ON ch.id = mv.clinical_history_id
                    WHERE ch.patient_id = p_patient_id AND iop.eye = p_eye
                    ORDER BY mv.visit_date DESC, iop.id DESC
                    LIMIT 1);
    IF v_ultima IS NULL THEN
        RETURN 'SIN MEDICION';
    END IF;

    RETURN IF(v_ultima <= v_meta, 'EN META', 'FUERA DE META');
END $$
DELIMITER ;
```

No es `DETERMINISTIC`: con los mismos parámetros puede devolver otro valor si se registran nuevas mediciones. Por eso es `READS SQL DATA`.
</details>

<details>
<summary><b>Solución 5 · Vista</b></summary>

```sql
DROP VIEW IF EXISTS vw_resumen_clinico_paciente;
CREATE VIEW vw_resumen_clinico_paciente AS
SELECT p.id AS patient_id,
       CONCAT(p.first_name, ' ', p.last_name) AS paciente,
       (SELECT COUNT(*) FROM medical_visits mv
        WHERE mv.clinical_history_id = ch.id)                        AS consultas,
       (SELECT COUNT(*) FROM intraocular_pressures iop
        JOIN medical_visits mv ON mv.id = iop.visit_id
        WHERE mv.clinical_history_id = ch.id)                        AS mediciones_pio,
       (SELECT COUNT(*) FROM oct_exams o
        JOIN medical_visits mv ON mv.id = o.visit_id
        WHERE mv.clinical_history_id = ch.id)                        AS estudios_oct,
       (SELECT COUNT(*) FROM treatments t
        JOIN medical_visits mv ON mv.id = t.visit_id
        WHERE mv.clinical_history_id = ch.id AND t.is_active = TRUE) AS tratamientos_activos,
       (SELECT MAX(mv.visit_date) FROM medical_visits mv
        WHERE mv.clinical_history_id = ch.id)                        AS ultima_consulta
FROM patients p
JOIN clinical_histories ch ON ch.patient_id = p.id;
```

Cada conteo se calcula por separado, así que no se multiplican las filas.
</details>

<details>
<summary><b>Solución 6 · Trigger</b></summary>

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bd_visits_prevent_delete_closed $$
CREATE TRIGGER trg_bd_visits_prevent_delete_closed
BEFORE DELETE ON medical_visits
FOR EACH ROW
PRECEDES trg_bd_visits_backup
BEGIN
    IF OLD.is_closed = TRUE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar una consulta cerrada: forma parte de la historia clínica';
    END IF;
END $$
DELIMITER ;
```

`BEFORE` permite cancelar la operación antes de que ocurra. Aunque el trigger de respaldo se ejecutara primero, su copia **también se desharía**: en InnoDB la sentencia y todos sus triggers son una sola unidad, y si uno falla se revierte todo.
</details>

<details>
<summary><b>Solución del reto extra</b></summary>

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bi_glaucoma_control_same_patient $$
CREATE TRIGGER trg_bi_glaucoma_control_same_patient
BEFORE INSERT ON glaucoma_controls
FOR EACH ROW
BEGIN
    DECLARE v_paciente_ficha    BIGINT;
    DECLARE v_paciente_consulta BIGINT;

    SET v_paciente_ficha = (SELECT patient_id FROM glaucoma_records WHERE id = NEW.glaucoma_record_id);
    SET v_paciente_consulta = (SELECT ch.patient_id
                               FROM medical_visits mv
                               JOIN clinical_histories ch ON ch.id = mv.clinical_history_id
                               WHERE mv.id = NEW.visit_id);

    IF v_paciente_ficha <> v_paciente_consulta THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El control y la consulta pertenecen a pacientes distintos';
    END IF;
END $$
DELIMITER ;
```
</details>
