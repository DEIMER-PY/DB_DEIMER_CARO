-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 08_views_and_events.sql
-- DESCRIPCIÓN: Definición de Vistas de Explotación Clínica y Eventos Programados
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

-- ==============================================================================
-- VISTAS CLÍNICAS Y DE GESTIÓN
-- ==============================================================================

-- 1. Vista de Resumen de Pacientes e Historia Clínica
DROP VIEW IF EXISTS vw_patient_summary;
CREATE VIEW vw_patient_summary AS
SELECT 
    p.id AS patient_id,
    p.document_number,
    dt.code AS doc_type,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    p.birth_date,
    TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()) AS age,
    p.gender,
    c.name AS city_name,
    p.phone,
    p.email,
    ch.history_number,
    ch.status AS history_status,
    ch.created_at AS history_created_at
FROM patients p
JOIN document_types dt ON p.document_type_id = dt.id
JOIN cities c ON p.city_id = c.id
JOIN clinical_histories ch ON p.id = ch.patient_id;

-- 2. Vista de Última Consulta por Paciente
DROP VIEW IF EXISTS vw_patient_last_visit;
CREATE VIEW vw_patient_last_visit AS
SELECT 
    p.id AS patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    ch.history_number,
    COUNT(mv.id) AS total_visits,
    MAX(mv.visit_date) AS last_visit_date,
    DATEDIFF(CURDATE(), DATE(MAX(mv.visit_date))) AS days_since_last_visit
FROM patients p
JOIN clinical_histories ch ON p.id = ch.patient_id
LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name, ch.history_number;

-- 3. Vista de Tratamientos Activos con Detalles Clínicos
DROP VIEW IF EXISTS vw_active_treatments;
CREATE VIEW vw_active_treatments AS
SELECT 
    t.id AS treatment_id,
    p.id AS patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    m.name AS medication_name,
    m.generic_name,
    m.concentration,
    t.eye,
    t.dosage,
    t.frequency,
    t.start_date,
    t.end_date,
    t.notes
FROM treatments t
JOIN medications m ON t.medication_id = m.id
JOIN medical_visits mv ON t.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
WHERE t.is_active = TRUE;

-- 4. Vista de Monitoreo Integral de Glaucoma
DROP VIEW IF EXISTS vw_glaucoma_monitoring;
CREATE VIEW vw_glaucoma_monitoring AS
SELECT 
    gr.id AS glaucoma_record_id,
    p.id AS patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    gr.clinical_stage,
    gr.target_iop_od,
    gr.target_iop_oi,
    gr.diagnosis_date,
    COUNT(gc.id) AS total_controls,
    MAX(gc.control_date) AS last_control_date,
    MAX(gc.is_progression_detected) AS progression_flag
FROM glaucoma_records gr
JOIN patients p ON gr.patient_id = p.id
LEFT JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
GROUP BY gr.id, p.id, patient_name, gr.clinical_stage, gr.target_iop_od, gr.target_iop_oi, gr.diagnosis_date;

-- 5. Vista de Presión Intraocular Bilateral por Consulta
DROP VIEW IF EXISTS vw_iop_bilateral;
CREATE VIEW vw_iop_bilateral AS
SELECT 
    mv.id AS visit_id,
    p.id AS patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    mv.visit_date,
    MAX(CASE WHEN iop.eye = 'OD' THEN iop.pressure END) AS iop_od,
    MAX(CASE WHEN iop.eye = 'OI' THEN iop.pressure END) AS iop_oi,
    MAX(iop.method) AS method
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN intraocular_pressures iop ON mv.id = iop.visit_id
GROUP BY mv.id, p.id, patient_name, mv.visit_date;

-- 6. Vista de Exámenes Especializados Consolidados
DROP VIEW IF EXISTS vw_specialized_exams;
CREATE VIEW vw_specialized_exams AS
SELECT 
    'OCT' AS exam_type,
    oct.id AS exam_id,
    oct.visit_id,
    ch.patient_id,
    oct.eye,
    oct.exam_date,
    CONCAT('RNFL: ', oct.rnfl_average, ' µm') AS metric_primary,
    oct.interpretation
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
UNION ALL
SELECT 
    'CAMPO_VISUAL',
    vf.id,
    vf.visit_id,
    ch.patient_id,
    vf.eye,
    vf.exam_date,
    CONCAT('VFI: ', vf.visual_field_index_vfi, '% | MD: ', vf.mean_deviation_md, ' dB'),
    vf.interpretation
FROM visual_field_exams vf
JOIN medical_visits mv ON vf.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
UNION ALL
SELECT 
    'PAQUIMETRIA',
    pe.id,
    pe.visit_id,
    ch.patient_id,
    pe.eye,
    pe.exam_date,
    CONCAT('Espesor: ', pe.corneal_thickness, ' µm'),
    pe.method
FROM pachymetry_exams pe
JOIN medical_visits mv ON pe.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id;

-- 7. Vista de Productividad por Profesional
DROP VIEW IF EXISTS vw_physician_workload;
CREATE VIEW vw_physician_workload AS
SELECT 
    hp.id AS professional_id,
    CONCAT(hp.first_name, ' ', hp.last_name) AS professional_name,
    s.name AS specialty,
    COUNT(mv.id) AS total_visits,
    COUNT(DISTINCT ch.patient_id) AS distinct_patients_seen,
    MIN(mv.visit_date) AS first_visit_attended,
    MAX(mv.visit_date) AS last_visit_attended
FROM healthcare_professionals hp
JOIN specialties s ON hp.specialty_id = s.id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
LEFT JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
GROUP BY hp.id, professional_name, s.name;

-- 8. Vista de Auditoría y Alertas Críticas
DROP VIEW IF EXISTS vw_audit_alerts;
CREATE VIEW vw_audit_alerts AS
SELECT 
    id AS log_id,
    table_name,
    record_id,
    action,
    new_values,
    performed_by,
    changed_at
FROM audit_logs
WHERE action = 'ALERT' OR action = 'DELETE'
ORDER BY changed_at DESC;


-- ==============================================================================
-- EVENTOS PROGRAMADOS (Event Scheduler)
-- ==============================================================================

SET GLOBAL event_scheduler = ON;

DELIMITER $$

-- Evento 1: Depuración Semanal de Auditoría y Notificaciones Antiguas
DROP EVENT IF EXISTS ev_weekly_audit_maintenance $$
CREATE EVENT ev_weekly_audit_maintenance
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
COMMENT 'Mantenimiento preventivo periódico de la tabla de auditoría'
DO
BEGIN
    -- Registro de ejecución del evento
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('SYSTEM_MAINTENANCE', 0, 'INSERT',
            JSON_OBJECT('event', 'ev_weekly_audit_maintenance', 'status', 'SUCCESS'),
            'EVENT_SCHEDULER', NOW());
END $$

-- Evento 2: Verificación Diaria de Tratamientos Vencidos
DROP EVENT IF EXISTS ev_daily_treatment_status_check $$
CREATE EVENT ev_daily_treatment_status_check
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
COMMENT 'Actualización automática del estado de tratamientos caducados'
DO
BEGIN
    UPDATE treatments
    SET is_active = FALSE
    WHERE end_date IS NOT NULL 
      AND end_date < CURDATE() 
      AND is_active = TRUE;
END $$

DELIMITER ;

SELECT 'Vistas y eventos programados creados exitosamente' AS estado;
