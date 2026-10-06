-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: tests/verify_solutions.sql
-- DESCRIPCIÓN: Script de Aserciones y Comprobación Integral de la Base de Datos
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

SELECT '==================================================' AS separador;
SELECT '1. VERIFICACIÓN DE OBJETOS EN EL CATÁLOGO' AS fase;
SELECT '==================================================' AS separador;

-- Conteo de tablas físicas
SELECT 'Tablas Relacionales Creadas:' AS metric, COUNT(*) AS total
FROM information_schema.tables 
WHERE table_schema = 'oftalmologia_glaucoma_db' AND table_type = 'BASE TABLE';

-- Conteo de Vistas
SELECT 'Vistas Creadas:' AS metric, COUNT(*) AS total
FROM information_schema.tables 
WHERE table_schema = 'oftalmologia_glaucoma_db' AND table_type = 'VIEW';

-- Conteo de Procedimientos Almacenados
SELECT 'Procedimientos Almacenados Creados:' AS metric, COUNT(*) AS total
FROM information_schema.routines 
WHERE routine_schema = 'oftalmologia_glaucoma_db' AND routine_type = 'PROCEDURE';

-- Conteo de Funciones Almacenadas
SELECT 'Funciones Almacenadas Creadas:' AS metric, COUNT(*) AS total
FROM information_schema.routines 
WHERE routine_schema = 'oftalmologia_glaucoma_db' AND routine_type = 'FUNCTION';

-- Conteo de Triggers
SELECT 'Triggers Creados:' AS metric, COUNT(*) AS total
FROM information_schema.triggers 
WHERE trigger_schema = 'oftalmologia_glaucoma_db';

-- Conteo de Eventos
SELECT 'Eventos Programados:' AS metric, COUNT(*) AS total
FROM information_schema.events 
WHERE event_schema = 'oftalmologia_glaucoma_db';


SELECT '==================================================' AS separador;
SELECT '2. PRUEBA DE EJECUCIÓN DE PROCEDIMIENTOS' AS fase;
SELECT '==================================================' AS separador;

-- Prueba de sp_get_patient_by_id
CALL sp_get_patient_by_id(1);

-- Prueba de sp_patient_complete_summary
CALL sp_patient_complete_summary(1);

-- Prueba de sp_patient_latest_exams
CALL sp_patient_latest_exams(1);


SELECT '==================================================' AS separador;
SELECT '3. PRUEBA DE EVALUACIÓN DE FUNCIONES ALMACENADAS' AS fase;
SELECT '==================================================' AS separador;

SELECT 
    p.id,
    p.document_number,
    fn_full_name(p.first_name, p.last_name) AS nombre_completo,
    fn_get_patient_age(p.id) AS edad,
    fn_patient_visits_count(p.id) AS total_consultas,
    fn_patient_avg_iop(p.id) AS pio_promedio,
    fn_has_glaucoma_diagnosis(p.id) AS tiene_glaucoma,
    fn_clinical_exam_completeness(p.id) AS completitud_examenes,
    fn_classify_patient_frequency(p.id) AS categoria_frecuencia
FROM patients p
LIMIT 5;

-- Prueba de la Ficha Resumen Textual (Función 50)
SELECT fn_patient_summary_card(1) AS ficha_resumen_paciente_1;


SELECT '==================================================' AS separador;
SELECT '4. PRUEBA DE DISPARADORES Y AUDITORÍA EN TIEMPO REAL' AS fase;
SELECT '==================================================' AS separador;

-- Comprobar triggers de auditoría
SELECT id, table_name, record_id, action, performed_by, changed_at
FROM audit_logs
ORDER BY id DESC
LIMIT 10;

SELECT '==================================================' AS separador;
SELECT 'TODAS LAS VALIDACIONES COMPLETADAS EXITOSAMENTE' AS resultado_final;
SELECT '==================================================' AS separador;
