-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 07_part5_functions.sql
-- DESCRIPCIÓN: PARTE V — 50 Funciones Almacenadas (Cálculos clínicos, KPIs y Resúmenes)
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

DELIMITER $$

-- ------------------------------------------------------------------------------
-- FUNCIONES BÁSICAS (1 a 10)
-- ------------------------------------------------------------------------------

-- 1. Calcular la edad de un paciente a partir de su fecha de nacimiento.
DROP FUNCTION IF EXISTS fn_calculate_age $$
CREATE FUNCTION fn_calculate_age(p_birth_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_birth_date, CURDATE());
END $$

-- 2. Recibir nombres y apellidos y retornar el nombre completo.
DROP FUNCTION IF EXISTS fn_full_name $$
CREATE FUNCTION fn_full_name(p_first VARCHAR(100), p_last VARCHAR(100))
RETURNS VARCHAR(210)
DETERMINISTIC
BEGIN
    RETURN CONCAT(TRIM(p_first), ' ', TRIM(p_last));
END $$

-- 3. Recibir un ID de paciente y retornar su número de documento.
DROP FUNCTION IF EXISTS fn_get_patient_document $$
CREATE FUNCTION fn_get_patient_document(p_patient_id BIGINT)
RETURNS VARCHAR(30)
READS SQL DATA
BEGIN
    DECLARE v_doc VARCHAR(30);
    SELECT document_number INTO v_doc FROM patients WHERE id = p_patient_id;
    RETURN IFNULL(v_doc, 'NO ENCONTRADO');
END $$

-- 4. Recibir un ID de paciente y retornar su edad.
DROP FUNCTION IF EXISTS fn_get_patient_age $$
CREATE FUNCTION fn_get_patient_age(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_age INT;
    SELECT TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) INTO v_age FROM patients WHERE id = p_patient_id;
    RETURN IFNULL(v_age, 0);
END $$

-- 5. Recibir el ID de una consulta y retornar su fecha.
DROP FUNCTION IF EXISTS fn_get_visit_date $$
CREATE FUNCTION fn_get_visit_date(p_visit_id BIGINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
    DECLARE v_date DATETIME;
    SELECT visit_date INTO v_date FROM medical_visits WHERE id = p_visit_id;
    RETURN v_date;
END $$

-- 6. Determinar cuántos años han pasado desde una fecha.
DROP FUNCTION IF EXISTS fn_years_since $$
CREATE FUNCTION fn_years_since(p_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_date IS NULL THEN
        RETURN 0;
    END IF;
    RETURN TIMESTAMPDIFF(YEAR, p_date, CURDATE());
END $$

-- 7. Recibir un valor de PIO y retornar un texto descriptivo.
DROP FUNCTION IF EXISTS fn_iop_status_text $$
CREATE FUNCTION fn_iop_status_text(p_pressure DECIMAL(5,2))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    IF p_pressure <= 10.00 THEN
        RETURN 'HIPOTONÍA OCULAR';
    ELSEIF p_pressure <= 21.00 THEN
        RETURN 'DENTRO DE LÍMITES NORMALES';
    ELSEIF p_pressure <= 29.00 THEN
        RETURN 'HIPERTENSIÓN OCULAR MODERADA';
    ELSE
        RETURN 'HIPERTENSIÓN OCULAR SEVERA / CRÍTICA';
    END IF;
END $$

-- 8. Recibir OD u OI y devolver Ojo derecho u Ojo izquierdo.
DROP FUNCTION IF EXISTS fn_eye_label $$
CREATE FUNCTION fn_eye_label(p_eye VARCHAR(10))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_eye = 'OD' THEN
        RETURN 'Ojo Derecho';
    ELSEIF p_eye = 'OI' THEN
        RETURN 'Ojo Izquierdo';
    ELSEIF p_eye = 'AMBOS' THEN
        RETURN 'Ambos Ojos';
    ELSE
        RETURN 'No Especificado';
    END IF;
END $$

-- 9. Recibir un booleano y retornar Activo o Inactivo.
DROP FUNCTION IF EXISTS fn_status_label $$
CREATE FUNCTION fn_status_label(p_status BOOLEAN)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_status = TRUE THEN
        RETURN 'Activo';
    ELSE
        RETURN 'Inactivo';
    END IF;
END $$

-- 10. Formatear un número de historia clínica con prefijo oficial.
DROP FUNCTION IF EXISTS fn_format_history_number $$
CREATE FUNCTION fn_format_history_number(p_raw VARCHAR(50))
RETURNS VARCHAR(60)
DETERMINISTIC
BEGIN
    IF p_raw LIKE 'HC-%' THEN
        RETURN UPPER(TRIM(p_raw));
    ELSE
        RETURN CONCAT('HC-2026-', UPPER(TRIM(p_raw)));
    END IF;
END $$


-- ------------------------------------------------------------------------------
-- FUNCIONES CON CONSULTAS (11 a 20)
-- ------------------------------------------------------------------------------

-- 11. Retornar la cantidad de consultas de un paciente.
DROP FUNCTION IF EXISTS fn_patient_visits_count $$
CREATE FUNCTION fn_patient_visits_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(mv.id) INTO v_count
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$

-- 12. Retornar la cantidad de diagnósticos distintos de un paciente.
DROP FUNCTION IF EXISTS fn_patient_diagnoses_count $$
CREATE FUNCTION fn_patient_diagnoses_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(DISTINCT vd.diagnosis_id) INTO v_count
    FROM visit_diagnoses vd
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$

-- 13. Retornar la cantidad de controles de glaucoma de un paciente.
DROP FUNCTION IF EXISTS fn_patient_glaucoma_controls_count $$
CREATE FUNCTION fn_patient_glaucoma_controls_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(gc.id) INTO v_count
    FROM glaucoma_controls gc
    JOIN glaucoma_records gr ON gc.glaucoma_record_id = gr.id
    WHERE gr.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$

-- 14. Retornar la última fecha de consulta de un paciente.
DROP FUNCTION IF EXISTS fn_patient_last_visit_date $$
CREATE FUNCTION fn_patient_last_visit_date(p_patient_id BIGINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(mv.visit_date) INTO v_last
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN v_last;
END $$

-- 15. Retornar la primera fecha de consulta de un paciente.
DROP FUNCTION IF EXISTS fn_patient_first_visit_date $$
CREATE FUNCTION fn_patient_first_visit_date(p_patient_id BIGINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
    DECLARE v_first DATETIME;
    SELECT MIN(mv.visit_date) INTO v_first
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN v_first;
END $$

-- 16. Retornar la presión intraocular promedio de un paciente.
DROP FUNCTION IF EXISTS fn_patient_avg_iop $$
CREATE FUNCTION fn_patient_avg_iop(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 17. Retornar la presión promedio de OD de un paciente.
DROP FUNCTION IF EXISTS fn_patient_avg_iop_od $$
CREATE FUNCTION fn_patient_avg_iop_od(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = 'OD';
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 18. Retornar la presión promedio de OI de un paciente.
DROP FUNCTION IF EXISTS fn_patient_avg_iop_oi $$
CREATE FUNCTION fn_patient_avg_iop_oi(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = 'OI';
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 19. Retornar la PIO máxima registrada para un paciente.
DROP FUNCTION IF EXISTS fn_patient_max_iop $$
CREATE FUNCTION fn_patient_max_iop(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_max DECIMAL(5,2);
    SELECT MAX(iop.pressure) INTO v_max
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_max, 0.00);
END $$

-- 20. Retornar la PIO mínima registrada para un paciente.
DROP FUNCTION IF EXISTS fn_patient_min_iop $$
CREATE FUNCTION fn_patient_min_iop(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_min DECIMAL(5,2);
    SELECT MIN(iop.pressure) INTO v_min
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_min, 0.00);
END $$


-- ------------------------------------------------------------------------------
-- FUNCIONES CLÍNICAS Y DE CLASIFICACIÓN (21 a 30)
-- ------------------------------------------------------------------------------

-- 21. Clasificar una PIO según rangos clínicos estandarizados.
DROP FUNCTION IF EXISTS fn_classify_iop_range $$
CREATE FUNCTION fn_classify_iop_range(p_iop DECIMAL(5,2))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_iop < 10.00 THEN
        RETURN 'HIPOTONIA';
    ELSEIF p_iop <= 21.00 THEN
        RETURN 'RANGO NORMAL';
    ELSEIF p_iop <= 25.00 THEN
        RETURN 'HTO LEVE';
    ELSEIF p_iop <= 30.00 THEN
        RETURN 'HTO MODERADA';
    ELSE
        RETURN 'HTO CRITICA';
    END IF;
END $$

-- 22. Indicar si una PIO supera una presión objetivo recibida como parámetro.
DROP FUNCTION IF EXISTS fn_is_iop_above_target $$
CREATE FUNCTION fn_is_iop_above_target(p_pressure DECIMAL(5,2), p_target DECIMAL(5,2))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN (p_pressure > p_target);
END $$

-- 23. Determinar si un paciente tiene diagnóstico de glaucoma.
DROP FUNCTION IF EXISTS fn_has_glaucoma_diagnosis $$
CREATE FUNCTION fn_has_glaucoma_diagnosis(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists
    FROM visit_diagnoses vd
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND d.is_glaucoma_type = TRUE;
    RETURN (v_exists > 0);
END $$

-- 24. Determinar si un paciente tiene tratamientos activos.
DROP FUNCTION IF EXISTS fn_has_active_treatments $$
CREATE FUNCTION fn_has_active_treatments(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(t.id) INTO v_count
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND t.is_active = TRUE;
    RETURN (v_count > 0);
END $$

-- 25. Indicar si el paciente tiene al menos un OCT registrado.
DROP FUNCTION IF EXISTS fn_has_oct_exam $$
CREATE FUNCTION fn_has_oct_exam(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(oct.id) INTO v_count
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$

-- 26. Indicar si tiene campo visual registrado.
DROP FUNCTION IF EXISTS fn_has_visual_field $$
CREATE FUNCTION fn_has_visual_field(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(vf.id) INTO v_count
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$

-- 27. Determinar si tiene paquimetría.
DROP FUNCTION IF EXISTS fn_has_pachymetry $$
CREATE FUNCTION fn_has_pachymetry(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(pe.id) INTO v_count
    FROM pachymetry_exams pe
    JOIN medical_visits mv ON pe.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$

-- 28. Determinar si el paciente tiene controles pendientes según un número de meses.
DROP FUNCTION IF EXISTS fn_has_pending_controls $$
CREATE FUNCTION fn_has_pending_controls(p_patient_id BIGINT, p_months INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(visit_date) INTO v_last
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    
    IF v_last IS NULL THEN
        RETURN TRUE;
    END IF;
    RETURN (TIMESTAMPDIFF(MONTH, v_last, NOW()) >= p_months);
END $$

-- 29. Clasificar un paciente según cantidad de consultas: nuevo, recurrente o frecuente.
DROP FUNCTION IF EXISTS fn_classify_patient_frequency $$
CREATE FUNCTION fn_classify_patient_frequency(p_patient_id BIGINT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_visits INT;
    SET v_visits = fn_patient_visits_count(p_patient_id);
    IF v_visits <= 1 THEN
        RETURN 'NUEVO';
    ELSEIF v_visits <= 3 THEN
        RETURN 'RECURRENTE';
    ELSE
        RETURN 'FRECUENTE';
    END IF;
END $$

-- 30. Retornar Completo si el paciente tiene OCT, campo visual, PIO y paquimetría, o Incompleto en caso contrario.
DROP FUNCTION IF EXISTS fn_clinical_exam_completeness $$
CREATE FUNCTION fn_clinical_exam_completeness(p_patient_id BIGINT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    IF fn_has_oct_exam(p_patient_id)
       AND fn_has_visual_field(p_patient_id)
       AND fn_has_pachymetry(p_patient_id)
       AND (fn_patient_avg_iop(p_patient_id) > 0.00) THEN
        RETURN 'COMPLETO';
    ELSE
        RETURN 'INCOMPLETO';
    END IF;
END $$


-- ------------------------------------------------------------------------------
-- FUNCIONES ESTADÍSTICAS Y TEMPORALES (31 a 40)
-- ------------------------------------------------------------------------------

-- 31. Calcular el promedio de PIO entre dos fechas para un paciente.
DROP FUNCTION IF EXISTS fn_patient_avg_iop_period $$
CREATE FUNCTION fn_patient_avg_iop_period(p_patient_id BIGINT, p_start DATE, p_end DATE)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
      AND DATE(mv.visit_date) BETWEEN p_start AND p_end;
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 32. Calcular la diferencia entre la primera y última PIO.
DROP FUNCTION IF EXISTS fn_patient_iop_difference $$
CREATE FUNCTION fn_patient_iop_difference(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_first DECIMAL(5,2);
    DECLARE v_last DECIMAL(5,2);

    SELECT iop.pressure INTO v_first
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date ASC, iop.id ASC LIMIT 1;

    SELECT iop.pressure INTO v_last
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;

    IF v_first IS NULL OR v_last IS NULL THEN
        RETURN 0.00;
    END IF;
    RETURN (v_last - v_first);
END $$

-- 33. Retornar el número de días desde la última consulta.
DROP FUNCTION IF EXISTS fn_days_since_last_visit $$
CREATE FUNCTION fn_days_since_last_visit(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SET v_last = fn_patient_last_visit_date(p_patient_id);
    IF v_last IS NULL THEN
        RETURN -1;
    END IF;
    RETURN DATEDIFF(CURDATE(), DATE(v_last));
END $$

-- 34. Retornar el número de meses desde el último OCT.
DROP FUNCTION IF EXISTS fn_months_since_last_oct $$
CREATE FUNCTION fn_months_since_last_oct(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(oct.exam_date) INTO v_last
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;

    IF v_last IS NULL THEN
        RETURN -1;
    END IF;
    RETURN TIMESTAMPDIFF(MONTH, v_last, NOW());
END $$

-- 35. Retornar el número de meses desde el último campo visual.
DROP FUNCTION IF EXISTS fn_months_since_last_vf $$
CREATE FUNCTION fn_months_since_last_vf(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(vf.exam_date) INTO v_last
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;

    IF v_last IS NULL THEN
        RETURN -1;
    END IF;
    RETURN TIMESTAMPDIFF(MONTH, v_last, NOW());
END $$

-- 36. Calcular el promedio de RNFL de los OCT de un paciente.
DROP FUNCTION IF EXISTS fn_patient_avg_rnfl $$
CREATE FUNCTION fn_patient_avg_rnfl(p_patient_id BIGINT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(6,2);
    SELECT AVG(oct.rnfl_average) INTO v_avg
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 37. Retornar el valor más reciente de RNFL.
DROP FUNCTION IF EXISTS fn_patient_latest_rnfl $$
CREATE FUNCTION fn_patient_latest_rnfl(p_patient_id BIGINT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_rnfl DECIMAL(6,2);
    SELECT oct.rnfl_average INTO v_rnfl
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY oct.exam_date DESC LIMIT 1;
    RETURN IFNULL(v_rnfl, 0.00);
END $$

-- 38. Calcular el promedio de VFI de un paciente.
DROP FUNCTION IF EXISTS fn_patient_avg_vfi $$
CREATE FUNCTION fn_patient_avg_vfi(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(vf.visual_field_index_vfi) INTO v_avg
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 39. Retornar la cantidad de tratamientos históricos.
DROP FUNCTION IF EXISTS fn_patient_total_treatments $$
CREATE FUNCTION fn_patient_total_treatments(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(t.id) INTO v_count
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$

-- 40. Retornar la cantidad de medicamentos diferentes utilizados por un paciente.
DROP FUNCTION IF EXISTS fn_patient_distinct_medications_count $$
CREATE FUNCTION fn_patient_distinct_medications_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(DISTINCT t.medication_id) INTO v_count
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$


-- ------------------------------------------------------------------------------
-- FUNCIONES AVANZADAS (41 a 50)
-- ------------------------------------------------------------------------------

-- 41. Recibir paciente y ojo y retornar la última PIO registrada.
DROP FUNCTION IF EXISTS fn_patient_latest_iop_by_eye $$
CREATE FUNCTION fn_patient_latest_iop_by_eye(p_patient_id BIGINT, p_eye VARCHAR(10))
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_iop DECIMAL(5,2);
    SELECT iop.pressure INTO v_iop
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = p_eye
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;
    RETURN IFNULL(v_iop, 0.00);
END $$

-- 42. Recibir paciente y ojo y retornar la PIO promedio.
DROP FUNCTION IF EXISTS fn_patient_avg_iop_by_eye $$
CREATE FUNCTION fn_patient_avg_iop_by_eye(p_patient_id BIGINT, p_eye VARCHAR(10))
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = p_eye;
    RETURN IFNULL(v_avg, 0.00);
END $$

-- 43. Determinar si la última PIO es mayor o menor que la primera.
DROP FUNCTION IF EXISTS fn_iop_trend $$
CREATE FUNCTION fn_iop_trend(p_patient_id BIGINT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_diff DECIMAL(5,2);
    SET v_diff = fn_patient_iop_difference(p_patient_id);
    IF v_diff > 0.00 THEN
        RETURN 'AUMENTO';
    ELSEIF v_diff < 0.00 THEN
        RETURN 'DISMINUCION';
    ELSE
        RETURN 'ESTABLE';
    END IF;
END $$

-- 44. Retornar la diferencia porcentual entre primera y última PIO.
DROP FUNCTION IF EXISTS fn_iop_pct_change $$
CREATE FUNCTION fn_iop_pct_change(p_patient_id BIGINT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_first DECIMAL(5,2);
    DECLARE v_last DECIMAL(5,2);

    SELECT iop.pressure INTO v_first
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date ASC, iop.id ASC LIMIT 1;

    SELECT iop.pressure INTO v_last
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;

    IF v_first IS NULL OR v_first = 0.00 OR v_last IS NULL THEN
        RETURN 0.00;
    END IF;
    RETURN ROUND(((v_last - v_first) / v_first) * 100.0, 2);
END $$

-- 45. Retornar el diagnóstico principal más reciente de un paciente.
DROP FUNCTION IF EXISTS fn_patient_latest_primary_diagnosis $$
CREATE FUNCTION fn_patient_latest_primary_diagnosis(p_patient_id BIGINT)
RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
    DECLARE v_diag VARCHAR(200);
    SELECT d.name INTO v_diag
    FROM visit_diagnoses vd
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND vd.is_primary = TRUE
    ORDER BY mv.visit_date DESC LIMIT 1;
    RETURN IFNULL(v_diag, 'SIN DIAGNOSTICO PRINCIPAL');
END $$

-- 46. Retornar el nombre del medicamento activo más reciente.
DROP FUNCTION IF EXISTS fn_patient_latest_active_medication $$
CREATE FUNCTION fn_patient_latest_active_medication(p_patient_id BIGINT)
RETURNS VARCHAR(150)
READS SQL DATA
BEGIN
    DECLARE v_med VARCHAR(150);
    SELECT m.name INTO v_med
    FROM treatments t
    JOIN medications m ON t.medication_id = m.id
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND t.is_active = TRUE
    ORDER BY t.start_date DESC LIMIT 1;
    RETURN IFNULL(v_med, 'SIN TRATAMIENTO ACTIVO');
END $$

-- 47. Retornar la cantidad de procedimientos realizados a un paciente.
DROP FUNCTION IF EXISTS fn_patient_procedures_count $$
CREATE FUNCTION fn_patient_procedures_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(pr.id) INTO v_count
    FROM procedures pr
    JOIN medical_visits mv ON pr.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$

-- 48. Determinar si un profesional ha atendido alguna vez a un paciente específico.
DROP FUNCTION IF EXISTS fn_has_doctor_treated_patient $$
CREATE FUNCTION fn_has_doctor_treated_patient(p_prof_id BIGINT, p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(mv.id) INTO v_count
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE mv.professional_id = p_prof_id AND ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$

-- 49. Cantidad total de exámenes especializados registrados para un paciente.
DROP FUNCTION IF EXISTS fn_patient_total_specialized_exams $$
CREATE FUNCTION fn_patient_total_specialized_exams(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_oct INT DEFAULT 0;
    DECLARE v_vf INT DEFAULT 0;
    DECLARE v_pachy INT DEFAULT 0;
    DECLARE v_gonio INT DEFAULT 0;

    SELECT COUNT(oct.id) INTO v_oct
    FROM oct_exams oct JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(vf.id) INTO v_vf
    FROM visual_field_exams vf JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(pe.id) INTO v_pachy
    FROM pachymetry_exams pe JOIN medical_visits mv ON pe.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(ge.id) INTO v_gonio
    FROM gonioscopy_exams ge JOIN medical_visits mv ON ge.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SET v_total = v_oct + v_vf + v_pachy + v_gonio;
    RETURN v_total;
END $$

-- 50. Generar una ficha resumen textual por paciente.
DROP FUNCTION IF EXISTS fn_patient_summary_card $$
CREATE FUNCTION fn_patient_summary_card(p_patient_id BIGINT)
RETURNS TEXT
READS SQL DATA
BEGIN
    DECLARE v_name VARCHAR(210);
    DECLARE v_visits INT;
    DECLARE v_controls INT;
    DECLARE v_last_od DECIMAL(5,2);
    DECLARE v_last_oi DECIMAL(5,2);
    DECLARE v_active_tx INT;
    DECLARE v_result TEXT;

    SELECT CONCAT(first_name, ' ', last_name) INTO v_name FROM patients WHERE id = p_patient_id;
    IF v_name IS NULL THEN
        RETURN 'PACIENTE NO REGISTRADO';
    END IF;

    SET v_visits = fn_patient_visits_count(p_patient_id);
    SET v_controls = fn_patient_glaucoma_controls_count(p_patient_id);
    SET v_last_od = fn_patient_latest_iop_by_eye(p_patient_id, 'OD');
    SET v_last_oi = fn_patient_latest_iop_by_eye(p_patient_id, 'OI');

    SELECT COUNT(t.id) INTO v_active_tx
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND t.is_active = TRUE;

    SET v_result = CONCAT(
        'Paciente: ', v_name, '\n',
        'Consultas: ', v_visits, '\n',
        'Controles glaucoma: ', v_controls, '\n',
        'Última PIO OD: ', IF(v_last_od > 0, v_last_od, 'Sin registro'), '\n',
        'Última PIO OI: ', IF(v_last_oi > 0, v_last_oi, 'Sin registro'), '\n',
        'Tratamientos activos: ', v_active_tx
    );

    RETURN v_result;
END $$

DELIMITER ;
