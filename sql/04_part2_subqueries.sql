-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 04_part2_subqueries.sql
-- DESCRIPCIÓN: PARTE II — 50 Ejercicios de Subconsultas SQL (Escalares, IN, NOT EXISTS, Correlacionadas, Avanzadas)
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

-- ------------------------------------------------------------------------------
-- SUBCONSULTAS ESCALARES (Ejercicios 1 a 10)
-- ------------------------------------------------------------------------------

-- 1. Mostrar los pacientes cuya edad sea superior a la edad promedio de todos los pacientes.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) AS age
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) > (
    SELECT AVG(TIMESTAMPDIFF(YEAR, per2.birth_date, CURDATE()))
    FROM patients p2
    JOIN persons per2 ON p2.person_id = per2.id
);

-- 2. Mostrar los pacientes cuya edad sea inferior a la edad promedio.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) AS age
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) < (
    SELECT AVG(TIMESTAMPDIFF(YEAR, per2.birth_date, CURDATE()))
    FROM patients p2
    JOIN persons per2 ON p2.person_id = per2.id
);

-- 3. Consultar la medición de presión intraocular más alta registrada.
SELECT *
FROM intraocular_pressures
WHERE pressure = (SELECT MAX(pressure) FROM intraocular_pressures);

-- 4. Mostrar todas las mediciones que tengan el mismo valor que la presión máxima registrada.
SELECT iop.id, iop.visit_id, iop.eye, iop.pressure, iop.method, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
WHERE iop.pressure = (SELECT MAX(pressure) FROM intraocular_pressures);

-- 5. Mostrar la presión intraocular mínima registrada.
SELECT *
FROM intraocular_pressures
WHERE pressure = (SELECT MIN(pressure) FROM intraocular_pressures);

-- 6. Mostrar los estudios OCT cuyo RNFL sea inferior al promedio general.
SELECT *
FROM oct_exams
WHERE rnfl_average < (SELECT AVG(rnfl_average) FROM oct_exams);

-- 7. Mostrar los estudios OCT cuyo RNFL sea superior al promedio general.
SELECT *
FROM oct_exams
WHERE rnfl_average > (SELECT AVG(rnfl_average) FROM oct_exams);

-- 8. Consultar pacientes cuya cantidad de consultas sea mayor que el promedio de consultas por paciente.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(mv.id) AS total_visits
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name
HAVING COUNT(mv.id) > (
    SELECT AVG(visit_count)
    FROM (
        SELECT COUNT(mv2.id) AS visit_count
        FROM clinical_histories ch2
        LEFT JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
        GROUP BY ch2.patient_id
    ) AS patient_averages
);

-- 9. Mostrar profesionales cuya cantidad de consultas sea superior al promedio por profesional.
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, COUNT(mv.id) AS total_visits
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY hp.id, professional_name
HAVING COUNT(mv.id) > (
    SELECT AVG(prof_visits)
    FROM (
        SELECT COUNT(mv2.id) AS prof_visits
        FROM healthcare_professionals hp2
        LEFT JOIN medical_visits mv2 ON hp2.id = mv2.professional_id
        GROUP BY hp2.id
    ) AS prof_averages
);

-- 10. Consultar pacientes cuya última presión intraocular sea superior al promedio general.
SELECT DISTINCT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, iop.pressure AS latest_iop
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN intraocular_pressures iop ON mv.id = iop.visit_id
WHERE iop.id = (
    SELECT iop2.id
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
    ORDER BY mv2.visit_date DESC, iop2.id DESC
    LIMIT 1
)
AND iop.pressure > (SELECT AVG(pressure) FROM intraocular_pressures);


-- ------------------------------------------------------------------------------
-- SUBCONSULTAS CON IN (Ejercicios 11 a 20)
-- ------------------------------------------------------------------------------

-- 11. Mostrar pacientes que tengan al menos una consulta registrada.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
);

-- 12. Mostrar pacientes que tengan diagnóstico de glaucoma.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visit_diagnoses vd ON mv.id = vd.visit_id
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    WHERE d.is_glaucoma_type = TRUE
);

-- 13. Mostrar pacientes que hayan recibido tratamiento farmacológico.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN treatments t ON mv.id = t.visit_id
);

-- 14. Mostrar pacientes que tengan estudios OCT registrados.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN oct_exams oct ON mv.id = oct.visit_id
);

-- 15. Mostrar pacientes que tengan campos visuales registrados.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visual_field_exams vf ON mv.id = vf.visit_id
);

-- 16. Mostrar medicamentos que hayan sido utilizados en al menos un tratamiento.
SELECT id, name, generic_name, concentration
FROM medications
WHERE id IN (
    SELECT DISTINCT medication_id FROM treatments
);

-- 17. Mostrar profesionales que hayan atendido pacientes con glaucoma.
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, hp.medical_license
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
WHERE hp.id IN (
    SELECT mv.professional_id
    FROM medical_visits mv
    JOIN visit_diagnoses vd ON mv.id = vd.visit_id
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    WHERE d.is_glaucoma_type = TRUE
);

-- 18. Mostrar diagnósticos utilizados en alguna consulta.
SELECT id, code, name
FROM diagnoses
WHERE id IN (
    SELECT DISTINCT diagnosis_id FROM visit_diagnoses
);

-- 19. Mostrar pacientes que hayan tenido algún procedimiento quirúrgico o clínico.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN procedures pr ON mv.id = pr.visit_id
);

-- 20. Mostrar pacientes que tengan registros de paquimetría.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN pachymetry_exams pe ON mv.id = pe.visit_id
);


-- ------------------------------------------------------------------------------
-- SUBCONSULTAS CON NOT IN / NOT EXISTS (Ejercicios 21 a 30)
-- ------------------------------------------------------------------------------

-- 21. Mostrar pacientes que nunca hayan tenido una consulta.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    WHERE ch.patient_id = p.id
);

-- 22. Mostrar pacientes que nunca hayan tenido un control de glaucoma.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM glaucoma_records gr
    JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
    WHERE gr.patient_id = p.id
);

-- 23. Mostrar pacientes que no tengan estudios OCT.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN oct_exams oct ON mv.id = oct.visit_id
    WHERE ch.patient_id = p.id
);

-- 24. Mostrar pacientes que no tengan campos visuales.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visual_field_exams vf ON mv.id = vf.visit_id
    WHERE ch.patient_id = p.id
);

-- 25. Mostrar medicamentos que nunca hayan sido utilizados.
SELECT m.id, m.name, m.generic_name
FROM medications m
WHERE m.id NOT IN (
    SELECT DISTINCT medication_id FROM treatments WHERE medication_id IS NOT NULL
);

-- 26. Mostrar profesionales que todavía no hayan registrado consultas.
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1 FROM medical_visits mv WHERE mv.professional_id = hp.id
);

-- 27. Mostrar diagnósticos que nunca hayan sido asociados a una consulta.
SELECT d.id, d.code, d.name
FROM diagnoses d
WHERE d.id NOT IN (
    SELECT DISTINCT diagnosis_id FROM visit_diagnoses WHERE diagnosis_id IS NOT NULL
);

-- 28. Mostrar pacientes que no tengan tratamientos activos.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN treatments t ON mv.id = t.visit_id
    WHERE ch.patient_id = p.id AND t.is_active = TRUE
);

-- 29. Mostrar pacientes que nunca hayan tenido procedimientos.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN procedures pr ON mv.id = pr.visit_id
    WHERE ch.patient_id = p.id
);

-- 30. Mostrar pacientes sin mediciones de presión intraocular.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN intraocular_pressures iop ON mv.id = iop.visit_id
    WHERE ch.patient_id = p.id
);


-- ------------------------------------------------------------------------------
-- SUBCONSULTAS CORRELACIONADAS (Ejercicios 31 a 40)
-- ------------------------------------------------------------------------------

-- 31. Mostrar las mediciones de PIO superiores al promedio del mismo paciente.
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       iop.eye, iop.pressure, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE iop.pressure > (
    SELECT AVG(iop2.pressure)
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);

-- 32. Mostrar los estudios OCT cuyo RNFL sea inferior al promedio del mismo paciente.
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       oct.eye, oct.rnfl_average, oct.exam_date
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE oct.rnfl_average < (
    SELECT AVG(oct2.rnfl_average)
    FROM oct_exams oct2
    JOIN medical_visits mv2 ON oct2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);

-- 33. Mostrar las consultas posteriores a la primera consulta de cada paciente.
SELECT mv.id AS visit_id, p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date > (
    SELECT MIN(mv2.visit_date)
    FROM medical_visits mv2
    WHERE mv2.clinical_history_id = ch.id
);

-- 34. Mostrar la última consulta de cada paciente utilizando una subconsulta correlacionada.
SELECT mv.id AS visit_id, p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date, mv.reason
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date = (
    SELECT MAX(mv2.visit_date)
    FROM medical_visits mv2
    WHERE mv2.clinical_history_id = ch.id
);

-- 35. Mostrar la primera medición de PIO de cada paciente.
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       iop.eye, iop.pressure, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date = (
    SELECT MIN(mv2.visit_date)
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);

-- 36. Mostrar la última medición de presión intraocular de cada paciente y ojo.
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       iop.eye, iop.pressure, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date = (
    SELECT MAX(mv2.visit_date)
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id AND iop2.eye = iop.eye
);

-- 37. Mostrar los tratamientos cuya fecha de inicio sea posterior a la primera consulta del paciente.
SELECT t.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, t.dosage, t.start_date
FROM treatments t
JOIN medical_visits mv ON t.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE t.start_date > (
    SELECT MIN(DATE(mv2.visit_date))
    FROM medical_visits mv2
    WHERE mv2.clinical_history_id = ch.id
);

-- 38. Mostrar pacientes cuyo número de consultas sea mayor que el de todos los demás pacientes de su misma ciudad.
SELECT p1.id, CONCAT(per1.first_name, ' ', per1.last_name) AS patient_name, per1.city_id, COUNT(mv1.id) AS visit_count
FROM patients p1
JOIN persons per1 ON p1.person_id = per1.id
JOIN clinical_histories ch1 ON p1.id = ch1.patient_id
JOIN medical_visits mv1 ON ch1.id = mv1.clinical_history_id
GROUP BY p1.id, patient_name, per1.city_id
HAVING visit_count >= ALL (
    SELECT COUNT(mv2.id)
    FROM patients p2
    JOIN persons per2 ON p2.person_id = per2.id
    JOIN clinical_histories ch2 ON p2.id = ch2.patient_id
    JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
    WHERE per2.city_id = per1.city_id AND p2.id <> p1.id
    GROUP BY p2.id
);

-- 39. Mostrar profesionales cuya cantidad de consultas sea superior al promedio de los profesionales de su especialidad.
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, hp.specialty_id, COUNT(mv.id) AS visits_count
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY hp.id, professional_name, hp.specialty_id
HAVING visits_count >= (
    SELECT AVG(specialty_visits)
    FROM (
        SELECT COUNT(mv2.id) AS specialty_visits
        FROM healthcare_professionals hp2
        LEFT JOIN medical_visits mv2 ON hp2.id = mv2.professional_id
        WHERE hp2.specialty_id = hp.specialty_id
        GROUP BY hp2.id
    ) AS spec_sub
);

-- 40. Mostrar el estudio OCT más reciente de cada paciente.
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       oct.eye, oct.rnfl_average, oct.exam_date
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE oct.exam_date = (
    SELECT MAX(oct2.exam_date)
    FROM oct_exams oct2
    JOIN medical_visits mv2 ON oct2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);


-- ------------------------------------------------------------------------------
-- SUBCONSULTAS AVANZADAS (Ejercicios 41 a 50)
-- ------------------------------------------------------------------------------

-- 41. Mostrar pacientes cuya presión intraocular máxima sea mayor que la presión máxima promedio de todos los pacientes.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, MAX(iop.pressure) AS patient_max_iop
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN intraocular_pressures iop ON mv.id = iop.visit_id
GROUP BY p.id, patient_name
HAVING patient_max_iop > (
    SELECT AVG(max_p)
    FROM (
        SELECT MAX(iop2.pressure) AS max_p
        FROM intraocular_pressures iop2
        JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
        JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
        GROUP BY ch2.patient_id
    ) AS patient_max_averages
);

-- 42. Mostrar pacientes cuya cantidad de diagnósticos diferentes sea superior al promedio.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(DISTINCT vd.diagnosis_id) AS distinct_diag_count
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
GROUP BY p.id, patient_name
HAVING distinct_diag_count > (
    SELECT AVG(diag_count)
    FROM (
        SELECT COUNT(DISTINCT vd2.diagnosis_id) AS diag_count
        FROM clinical_histories ch2
        JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
        JOIN visit_diagnoses vd2 ON mv2.id = vd2.visit_id
        GROUP BY ch2.patient_id
    ) AS diag_averages
);

-- 43. Mostrar los pacientes que tengan más tratamientos activos que el promedio de tratamientos activos por paciente.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(t.id) AS active_treatments
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN treatments t ON mv.id = t.visit_id
WHERE t.is_active = TRUE
GROUP BY p.id, patient_name
HAVING active_treatments > (
    SELECT AVG(active_count)
    FROM (
        SELECT COUNT(t2.id) AS active_count
        FROM clinical_histories ch2
        LEFT JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
        LEFT JOIN treatments t2 ON mv2.id = t2.visit_id AND t2.is_active = TRUE
        GROUP BY ch2.patient_id
    ) AS active_averages
);

-- 44. Mostrar el medicamento más utilizado en tratamientos.
SELECT m.id, m.name, m.generic_name, COUNT(t.id) AS usage_count
FROM medications m
JOIN treatments t ON m.id = t.medication_id
GROUP BY m.id, m.name, m.generic_name
HAVING usage_count = (
    SELECT MAX(med_count)
    FROM (
        SELECT COUNT(t2.id) AS med_count
        FROM treatments t2
        GROUP BY t2.medication_id
    ) AS med_counts
);

-- 45. Mostrar el diagnóstico más frecuente utilizando subconsultas.
SELECT d.id, d.code, d.name, COUNT(vd.id) AS occurrences
FROM diagnoses d
JOIN visit_diagnoses vd ON d.id = vd.diagnosis_id
GROUP BY d.id, d.code, d.name
HAVING occurrences = (
    SELECT MAX(diag_occ)
    FROM (
        SELECT COUNT(vd2.id) AS diag_occ
        FROM visit_diagnoses vd2
        GROUP BY vd2.diagnosis_id
    ) AS diag_counts
);

-- 46. Mostrar los pacientes cuya última PIO sea inferior a su primera PIO.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE (
    SELECT iop_first.pressure
    FROM intraocular_pressures iop_first
    JOIN medical_visits mv_first ON iop_first.visit_id = mv_first.id
    JOIN clinical_histories ch_first ON mv_first.clinical_history_id = ch_first.id
    WHERE ch_first.patient_id = p.id
    ORDER BY mv_first.visit_date ASC, iop_first.id ASC
    LIMIT 1
) > (
    SELECT iop_last.pressure
    FROM intraocular_pressures iop_last
    JOIN medical_visits mv_last ON iop_last.visit_id = mv_last.id
    JOIN clinical_histories ch_last ON mv_last.clinical_history_id = ch_last.id
    WHERE ch_last.patient_id = p.id
    ORDER BY mv_last.visit_date DESC, iop_last.id DESC
    LIMIT 1
);

-- 47. Mostrar pacientes cuya presión promedio del ojo derecho sea mayor que la del ojo izquierdo.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE (
    SELECT AVG(iop_od.pressure)
    FROM intraocular_pressures iop_od
    JOIN medical_visits mv_od ON iop_od.visit_id = mv_od.id
    JOIN clinical_histories ch_od ON mv_od.clinical_history_id = ch_od.id
    WHERE ch_od.patient_id = p.id AND iop_od.eye = 'OD'
) > (
    SELECT AVG(iop_oi.pressure)
    FROM intraocular_pressures iop_oi
    JOIN medical_visits mv_oi ON iop_oi.visit_id = mv_oi.id
    JOIN clinical_histories ch_oi ON mv_oi.clinical_history_id = ch_oi.id
    WHERE ch_oi.patient_id = p.id AND iop_oi.eye = 'OI'
);

-- 48. Mostrar los pacientes con mayor cantidad de controles de glaucoma que el promedio general.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(gc.id) AS controls_count
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN glaucoma_records gr ON p.id = gr.patient_id
JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
GROUP BY p.id, patient_name
HAVING controls_count > (
    SELECT AVG(patient_ctrls)
    FROM (
        SELECT COUNT(gc2.id) AS patient_ctrls
        FROM glaucoma_records gr2
        LEFT JOIN glaucoma_controls gc2 ON gr2.id = gc2.glaucoma_record_id
        GROUP BY gr2.patient_id
    ) AS ctrl_averages
);

-- 49. Mostrar las consultas que tengan más diagnósticos asociados que el promedio de diagnósticos por consulta.
SELECT mv.id AS visit_id, mv.visit_date, COUNT(vd.id) AS diag_count
FROM medical_visits mv
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
GROUP BY mv.id, mv.visit_date
HAVING diag_count > (
    SELECT AVG(visit_diag_count)
    FROM (
        SELECT COUNT(vd2.id) AS visit_diag_count
        FROM medical_visits mv2
        LEFT JOIN visit_diagnoses vd2 ON mv2.id = vd2.visit_id
        GROUP BY mv2.id
    ) AS avg_diag_per_visit
);

-- 50. Mostrar los pacientes que tengan simultáneamente OCT, campo visual, paquimetría y control de glaucoma registrados.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE EXISTS (
    SELECT 1 FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN oct_exams oct ON mv.id = oct.visit_id
    WHERE ch.patient_id = p.id
)
AND EXISTS (
    SELECT 1 FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visual_field_exams vf ON mv.id = vf.visit_id
    WHERE ch.patient_id = p.id
)
AND EXISTS (
    SELECT 1 FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN pachymetry_exams pe ON mv.id = pe.visit_id
    WHERE ch.patient_id = p.id
)
AND EXISTS (
    SELECT 1 FROM glaucoma_records gr
    JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
    WHERE gr.patient_id = p.id
);
