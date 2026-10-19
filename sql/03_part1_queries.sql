-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 03_part1_queries.sql
-- DESCRIPCIÓN: PARTE I — 50 Ejercicios de Consultas SQL (Básicas, Intermedias, Avanzadas)
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

-- ------------------------------------------------------------------------------
-- NIVEL BÁSICO (Ejercicios 1 a 20)
-- ------------------------------------------------------------------------------

-- 1. Mostrar todos los pacientes registrados en la base de datos.
SELECT p.id, per.document_number, per.first_name, per.last_name, per.birth_date, per.gender, p.blood_type, p.health_insurance, p.affiliation_type
FROM patients p
JOIN persons per ON p.person_id = per.id;

-- 2. Mostrar únicamente el número de documento, nombres y apellidos de todos los pacientes.
SELECT per.document_number, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id;

-- 3. Listar todos los profesionales de salud registrados.
SELECT hp.id, per.document_number, per.first_name, per.last_name, hp.medical_license, hp.specialty_id, hp.is_active
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id;

-- 4. Mostrar todos los diagnósticos disponibles en el catálogo.
SELECT * FROM diagnoses;

-- 5. Consultar todas las historias clínicas registradas.
SELECT * FROM clinical_histories;

-- 6. Mostrar todos los pacientes ordenados alfabéticamente por apellido.
SELECT p.id, per.document_number, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id
ORDER BY per.last_name ASC, per.first_name ASC;

-- 7. Mostrar los pacientes ordenados por fecha de nacimiento desde el más joven hasta el de mayor edad.
SELECT p.id, per.first_name, per.last_name, per.birth_date
FROM patients p
JOIN persons per ON p.person_id = per.id
ORDER BY per.birth_date DESC;

-- 8. Consultar los pacientes cuyo apellido sea Gómez.
SELECT p.id, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.last_name LIKE '%Gómez%' OR per.last_name LIKE '%Gomez%';

-- 9. Mostrar los pacientes cuyo número de documento comience por 10.
SELECT p.id, per.document_number, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.document_number LIKE '10%';

-- 10. Consultar los pacientes cuyo correo electrónico pertenezca al dominio gmail.com.
SELECT p.id, per.first_name, per.last_name, per.email
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.email LIKE '%@gmail.com';

-- 11. Mostrar los pacientes que no tengan correo electrónico registrado.
SELECT p.id, per.first_name, per.last_name, per.email
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.email IS NULL;

-- 12. Mostrar los profesionales cuya especialidad sea Oftalmología.
SELECT hp.id, per.first_name, per.last_name, hp.medical_license, s.name AS specialty
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id
WHERE s.name = 'Oftalmología';

-- 13. Consultar todas las consultas médicas realizadas durante el año 2026.
SELECT * FROM medical_visits WHERE YEAR(visit_date) = 2026;

-- 14. Mostrar las consultas realizadas durante un mes determinado (enero 2026).
SELECT * FROM medical_visits WHERE YEAR(visit_date) = 2026 AND MONTH(visit_date) = 1;

-- 15. Consultar las mediciones de presión intraocular superiores a 20 mmHg.
SELECT * FROM intraocular_pressures WHERE pressure > 20.00;

-- 16. Mostrar las mediciones de presión intraocular correspondientes únicamente al ojo derecho (OD).
SELECT * FROM intraocular_pressures WHERE eye = 'OD';

-- 17. Mostrar las mediciones correspondientes únicamente al ojo izquierdo (OI).
SELECT * FROM intraocular_pressures WHERE eye = 'OI';

-- 18. Consultar todos los tratamientos que se encuentren activos.
SELECT * FROM treatments WHERE is_active = TRUE;

-- 19. Mostrar todos los tratamientos que hayan finalizado.
SELECT * FROM treatments WHERE is_active = FALSE OR (end_date IS NOT NULL AND end_date < CURDATE());

-- 20. Consultar los procedimientos realizados después de una fecha determinada ('2026-01-01').
SELECT * FROM procedures WHERE procedure_date >= '2026-01-01 00:00:00';


-- ------------------------------------------------------------------------------
-- NIVEL INTERMEDIO (Ejercicios 21 a 40)
-- ------------------------------------------------------------------------------

-- 21. Mostrar cada paciente junto con el número de su historia clínica.
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, ch.history_number, ch.status
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id;

-- 22. Mostrar cada consulta indicando el nombre completo del paciente.
SELECT mv.id AS visit_id, mv.visit_date, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.reason
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;

-- 23. Mostrar cada consulta junto con el nombre del profesional que la realizó.
SELECT mv.id AS visit_id, mv.visit_date, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, s.name AS specialty, mv.reason
FROM medical_visits mv
JOIN healthcare_professionals hp ON mv.professional_id = hp.id
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id;

-- 24. Listar todos los pacientes junto con la fecha de sus consultas.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.id AS visit_id, mv.visit_date
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
ORDER BY p.id, mv.visit_date;

-- 25. Mostrar los diagnósticos asociados a cada consulta.
SELECT mv.id AS visit_id, mv.visit_date, d.code, d.name AS diagnosis_name, vd.is_primary, vd.notes
FROM medical_visits mv
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.id
ORDER BY mv.id, vd.is_primary DESC;

-- 26. Mostrar nombre del paciente, fecha de consulta y diagnóstico correspondiente.
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date, d.code, d.name AS diagnosis, vd.is_primary
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.id;

-- 27. Consultar todos los pacientes que tengan diagnóstico de glaucoma.
SELECT DISTINCT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, d.code, d.name AS glaucoma_diagnosis
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.id
WHERE d.is_glaucoma_type = TRUE;

-- 28. Mostrar todos los controles de glaucoma indicando el paciente correspondiente.
SELECT gc.id AS control_id, gc.control_date, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, gr.clinical_stage, gc.is_progression_detected, gc.adherence_score, gc.notes
FROM glaucoma_controls gc
JOIN glaucoma_records gr ON gc.glaucoma_record_id = gr.id
JOIN patients p ON gr.patient_id = p.id
JOIN persons per ON p.person_id = per.id;

-- 29. Mostrar cada medición de presión intraocular junto con nombre del paciente, fecha y ojo.
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date, iop.eye, iop.pressure, iop.method
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
ORDER BY mv.visit_date DESC, iop.eye;

-- 30. Mostrar los estudios OCT realizados indicando paciente, ojo y fecha.
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, oct.eye, oct.exam_date, oct.rnfl_average, oct.cup_to_disc_ratio, oct.interpretation
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;

-- 31. Mostrar los campos visuales registrados indicando paciente, ojo, MD, PSD y VFI.
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, vf.eye, vf.mean_deviation_md, vf.pattern_std_deviation_psd, vf.visual_field_index_vfi, vf.reliability, vf.exam_date
FROM visual_field_exams vf
JOIN medical_visits mv ON vf.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;

-- 32. Mostrar las paquimetrías realizadas junto con el paciente y el espesor corneal registrado.
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, pe.eye, pe.corneal_thickness, pe.method, pe.exam_date
FROM pachymetry_exams pe
JOIN medical_visits mv ON pe.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;

-- 33. Mostrar los tratamientos activos incluyendo nombre del paciente y medicamento.
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, m.name AS medication_name, m.generic_name, t.dosage, t.frequency, t.eye, t.start_date
FROM treatments t
JOIN medications m ON t.medication_id = m.id
JOIN medical_visits mv ON t.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE t.is_active = TRUE;

-- 34. Mostrar cada medicamento y la cantidad de tratamientos en los que ha sido utilizado.
SELECT m.id, m.name, m.generic_name, COUNT(t.id) AS total_treatments_prescribed
FROM medications m
LEFT JOIN treatments t ON m.id = t.medication_id
GROUP BY m.id, m.name, m.generic_name
ORDER BY total_treatments_prescribed DESC;

-- 35. Mostrar la cantidad total de pacientes registrados.
SELECT COUNT(*) AS total_patients_registered FROM patients;

-- 36. Mostrar la cantidad de consultas realizadas.
SELECT COUNT(*) AS total_visits_conducted FROM medical_visits;

-- 37. Mostrar la cantidad de pacientes por sexo.
SELECT per.gender, COUNT(*) AS total_patients
FROM patients p
JOIN persons per ON p.person_id = per.id
GROUP BY per.gender;

-- 38. Mostrar la cantidad de pacientes atendidos por cada profesional.
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, COUNT(DISTINCT ch.patient_id) AS distinct_patients_attended
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
LEFT JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
GROUP BY hp.id, professional_name
ORDER BY distinct_patients_attended DESC;

-- 39. Calcular el promedio general de presión intraocular.
SELECT ROUND(AVG(pressure), 2) AS overall_average_iop FROM intraocular_pressures;

-- 40. Calcular la presión intraocular mínima y máxima registrada.
SELECT MIN(pressure) AS min_iop_recorded, MAX(pressure) AS max_iop_recorded FROM intraocular_pressures;


-- ------------------------------------------------------------------------------
-- NIVEL AVANZADO (Ejercicios 41 a 50)
-- ------------------------------------------------------------------------------

-- 41. Calcular la presión intraocular promedio para OD y OI por separado.
SELECT eye, ROUND(AVG(pressure), 2) AS avg_pressure, MIN(pressure) AS min_pressure, MAX(pressure) AS max_pressure, COUNT(*) AS total_measurements
FROM intraocular_pressures
GROUP BY eye;

-- 42. Mostrar la cantidad de consultas realizadas por cada paciente.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(mv.id) AS total_visits
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name
ORDER BY total_visits DESC;

-- 43. Mostrar únicamente los pacientes que tengan dos o más consultas.
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(mv.id) AS total_visits
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name
HAVING COUNT(mv.id) >= 2
ORDER BY total_visits DESC;

-- 44. Mostrar cada profesional junto con la cantidad de consultas realizadas.
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, s.name AS specialty, COUNT(mv.id) AS total_visits
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY hp.id, professional_name, s.name
ORDER BY total_visits DESC;

-- 45. Mostrar los profesionales que hayan realizado consultas agrupados por especialidad.
SELECT s.name AS specialty, COUNT(mv.id) AS visits_count
FROM specialties s
JOIN healthcare_professionals hp ON s.id = hp.specialty_id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY s.name
HAVING visits_count > 0;

-- 46. Calcular la cantidad de diagnósticos registrados por tipo de diagnóstico.
SELECT d.id, d.code, d.name AS diagnosis_name, d.is_glaucoma_type, COUNT(vd.id) AS total_occurrences
FROM diagnoses d
LEFT JOIN visit_diagnoses vd ON d.id = vd.diagnosis_id
GROUP BY d.id, d.code, d.name, d.is_glaucoma_type
ORDER BY total_occurrences DESC;

-- 47. Mostrar los cinco diagnósticos más frecuentes.
SELECT d.code, d.name AS diagnosis_name, COUNT(vd.id) AS frequency
FROM diagnoses d
JOIN visit_diagnoses vd ON d.id = vd.diagnosis_id
GROUP BY d.id, d.code, d.name
ORDER BY frequency DESC
LIMIT 5;

-- 48. Mostrar la cantidad de estudios OCT realizados por mes.
SELECT DATE_FORMAT(exam_date, '%Y-%m') AS exam_month, COUNT(*) AS total_oct_exams
FROM oct_exams
GROUP BY exam_month
ORDER BY exam_month;

-- 49. Mostrar la cantidad de campos visuales realizados por año.
SELECT YEAR(exam_date) AS exam_year, COUNT(*) AS total_visual_fields
FROM visual_field_exams
GROUP BY exam_year
ORDER BY exam_year;

-- 50. Generar un reporte consolidado por paciente: nombre completo, número de consultas,
-- cantidad de controles de glaucoma, promedio de PIO y fecha de última consulta.
SELECT 
    p.id AS patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    COUNT(DISTINCT mv.id) AS total_visits,
    COUNT(DISTINCT gc.id) AS total_glaucoma_controls,
    ROUND(AVG(iop.pressure), 2) AS avg_iop,
    MAX(mv.visit_date) AS last_visit_date
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
LEFT JOIN glaucoma_records gr ON p.id = gr.patient_id
LEFT JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
LEFT JOIN intraocular_pressures iop ON mv.id = iop.visit_id
GROUP BY p.id, patient_name
ORDER BY total_visits DESC, p.id;
