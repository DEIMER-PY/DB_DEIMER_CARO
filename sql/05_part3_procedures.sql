-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 05_part3_procedures.sql
-- DESCRIPCIÓN: PARTE III — 50 Ejercicios de Procedimientos Almacenados (CRUD, Control, Transacciones)
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

DELIMITER $$

-- ------------------------------------------------------------------------------
-- PROCEDIMIENTOS BÁSICOS (1 a 10)
-- ------------------------------------------------------------------------------

-- 1. Crear un procedimiento que liste todos los pacientes.
DROP PROCEDURE IF EXISTS sp_list_all_patients $$
CREATE PROCEDURE sp_list_all_patients()
BEGIN
    SELECT p.id, per.document_number, per.first_name, per.last_name, per.birth_date, per.gender, per.phone, per.email
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    ORDER BY per.last_name, per.first_name;
END $$

-- 2. Crear un procedimiento que reciba el ID de un paciente y muestre sus datos.
DROP PROCEDURE IF EXISTS sp_get_patient_by_id $$
CREATE PROCEDURE sp_get_patient_by_id(IN p_patient_id BIGINT)
BEGIN
    SELECT p.*, per.document_number, per.first_name, per.last_name, per.birth_date, per.gender, per.address, per.phone, per.email,
           dt.code AS doc_type, c.name AS city_name
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    JOIN document_types dt ON per.document_type_id = dt.id
    JOIN cities c ON per.city_id = c.id
    WHERE p.id = p_patient_id;
END $$

-- 3. Crear un procedimiento que busque un paciente por número de documento.
DROP PROCEDURE IF EXISTS sp_get_patient_by_document $$
CREATE PROCEDURE sp_get_patient_by_document(IN p_doc_number VARCHAR(30))
BEGIN
    SELECT p.*, per.document_number, per.first_name, per.last_name, per.birth_date, per.gender, per.address, per.phone, per.email,
           dt.code AS doc_type, c.name AS city_name
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    JOIN document_types dt ON per.document_type_id = dt.id
    JOIN cities c ON per.city_id = c.id
    WHERE per.document_number = p_doc_number;
END $$

-- 4. Crear un procedimiento que liste todas las consultas de un paciente.
DROP PROCEDURE IF EXISTS sp_list_visits_by_patient $$
CREATE PROCEDURE sp_list_visits_by_patient(IN p_patient_id BIGINT)
BEGIN
    SELECT mv.id AS visit_id, mv.visit_date, mv.reason, mv.assessment, mv.plan,
           CONCAT(per.first_name, ' ', per.last_name) AS professional_name
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    JOIN healthcare_professionals hp ON mv.professional_id = hp.id
    JOIN persons per ON hp.person_id = per.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC;
END $$

-- 5. Crear un procedimiento que muestre todos los profesionales.
DROP PROCEDURE IF EXISTS sp_list_all_professionals $$
CREATE PROCEDURE sp_list_all_professionals()
BEGIN
    SELECT hp.id, per.document_number, per.first_name, per.last_name, hp.medical_license,
           s.name AS specialty, per.email, per.phone, hp.is_active
    FROM healthcare_professionals hp
    JOIN persons per ON hp.person_id = per.id
    JOIN specialties s ON hp.specialty_id = s.id
    ORDER BY per.last_name;
END $$

-- 6. Crear un procedimiento que reciba una especialidad y muestre sus profesionales.
DROP PROCEDURE IF EXISTS sp_list_professionals_by_specialty $$
CREATE PROCEDURE sp_list_professionals_by_specialty(IN p_specialty_name VARCHAR(100))
BEGIN
    SELECT hp.id, per.first_name, per.last_name, hp.medical_license, per.email, per.phone
    FROM healthcare_professionals hp
    JOIN persons per ON hp.person_id = per.id
    JOIN specialties s ON hp.specialty_id = s.id
    WHERE s.name LIKE CONCAT('%', p_specialty_name, '%');
END $$

-- 7. Crear un procedimiento que liste diagnósticos.
DROP PROCEDURE IF EXISTS sp_list_diagnoses $$
CREATE PROCEDURE sp_list_diagnoses()
BEGIN
    SELECT id, code, name, is_glaucoma_type, description
    FROM diagnoses
    ORDER BY code;
END $$

-- 8. Crear un procedimiento que muestre medicamentos activos.
DROP PROCEDURE IF EXISTS sp_list_active_medications $$
CREATE PROCEDURE sp_list_active_medications()
BEGIN
    SELECT m.id, m.name, mc.name AS class_name, m.generic_name, m.concentration, m.presentation
    FROM medications m
    JOIN medication_classes mc ON m.medication_class_id = mc.id
    WHERE m.is_active = TRUE
    ORDER BY mc.name, m.name;
END $$

-- 9. Crear un procedimiento que liste procedimientos clínicos realizados a un paciente.
DROP PROCEDURE IF EXISTS sp_list_patient_procedures $$
CREATE PROCEDURE sp_list_patient_procedures(IN p_patient_id BIGINT)
BEGIN
    SELECT pr.id, pt.name AS procedure_name, pr.eye, pr.procedure_date, pr.results, pr.complications
    FROM procedures pr
    JOIN procedure_types pt ON pr.procedure_type_id = pt.id
    JOIN medical_visits mv ON pr.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY pr.procedure_date DESC;
END $$

-- 10. Crear un procedimiento para consultar todos los controles de glaucoma de un paciente.
DROP PROCEDURE IF EXISTS sp_list_patient_glaucoma_controls $$
CREATE PROCEDURE sp_list_patient_glaucoma_controls(IN p_patient_id BIGINT)
BEGIN
    SELECT gc.id, gc.control_date, gc.is_progression_detected, gc.adherence_score, gc.notes,
           gr.clinical_stage, gr.target_iop_od, gr.target_iop_oi
    FROM glaucoma_controls gc
    JOIN glaucoma_records gr ON gc.glaucoma_record_id = gr.id
    WHERE gr.patient_id = p_patient_id
    ORDER BY gc.control_date DESC;
END $$


-- ------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE INSERCIÓN (11 a 20)
-- ------------------------------------------------------------------------------

-- 11. Crear un procedimiento para registrar un nuevo paciente.
DROP PROCEDURE IF EXISTS sp_insert_patient $$
CREATE PROCEDURE sp_insert_patient(
    IN p_doc_type_id INT,
    IN p_doc_num VARCHAR(30),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_birth_date DATE,
    IN p_gender ENUM('M', 'F', 'OTRO'),
    IN p_city_id INT,
    IN p_address VARCHAR(255),
    IN p_phone VARCHAR(30),
    IN p_email VARCHAR(150),
    OUT p_new_id BIGINT
)
BEGIN
    DECLARE v_person_id BIGINT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    INSERT INTO persons (document_type_id, document_number, first_name, last_name, birth_date, gender, city_id, address, phone, email)
    VALUES (p_doc_type_id, p_doc_num, p_first_name, p_last_name, p_birth_date, p_gender, p_city_id, p_address, p_phone, p_email);
    SET v_person_id = LAST_INSERT_ID();

    INSERT INTO patients (person_id, blood_type, health_insurance, affiliation_type, occupation, emergency_contact_name, emergency_contact_phone)
    VALUES (v_person_id, 'O+', 'Sanitas', 'COTIZANTE', 'No especificado', 'Contacto de Emergencia', p_phone);
    SET p_new_id = LAST_INSERT_ID();
    COMMIT;
END $$

-- 12. Crear un procedimiento para crear una historia clínica.
DROP PROCEDURE IF EXISTS sp_create_clinical_history $$
CREATE PROCEDURE sp_create_clinical_history(
    IN p_patient_id BIGINT,
    IN p_history_num VARCHAR(50),
    OUT p_new_history_id BIGINT
)
BEGIN
    INSERT INTO clinical_histories (patient_id, history_number, status)
    VALUES (p_patient_id, p_history_num, 'ACTIVA');
    SET p_new_history_id = LAST_INSERT_ID();
END $$

-- 13. Crear un procedimiento para registrar una consulta médica.
DROP PROCEDURE IF EXISTS sp_create_medical_visit $$
CREATE PROCEDURE sp_create_medical_visit(
    IN p_history_id BIGINT,
    IN p_prof_id BIGINT,
    IN p_reason TEXT,
    IN p_symptoms TEXT,
    IN p_assessment TEXT,
    IN p_plan TEXT,
    OUT p_new_visit_id BIGINT
)
BEGIN
    INSERT INTO medical_visits (clinical_history_id, professional_id, visit_date, reason, symptoms, assessment, plan, is_closed)
    VALUES (p_history_id, p_prof_id, NOW(), p_reason, p_symptoms, p_assessment, p_plan, FALSE);
    SET p_new_visit_id = LAST_INSERT_ID();

    UPDATE appointments 
    SET status = 'ATENDIDA'
    WHERE professional_id = p_prof_id
      AND patient_id = (SELECT patient_id FROM clinical_histories WHERE id = p_history_id)
      AND status IN ('PROGRAMADA', 'CONFIRMADA')
      AND DATE(appointment_date) = CURDATE()
    LIMIT 1;
END $$

-- 14. Crear un procedimiento para registrar un diagnóstico asociado a una consulta.
DROP PROCEDURE IF EXISTS sp_add_visit_diagnosis $$
CREATE PROCEDURE sp_add_visit_diagnosis(
    IN p_visit_id BIGINT,
    IN p_diagnosis_id INT,
    IN p_is_primary BOOLEAN,
    IN p_notes VARCHAR(255)
)
BEGIN
    INSERT INTO visit_diagnoses (visit_id, diagnosis_id, is_primary, notes)
    VALUES (p_visit_id, p_diagnosis_id, p_is_primary, p_notes);
END $$

-- 15. Crear un procedimiento para registrar una medición de PIO.
DROP PROCEDURE IF EXISTS sp_record_intraocular_pressure $$
CREATE PROCEDURE sp_record_intraocular_pressure(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_pressure DECIMAL(5,2),
    IN p_method ENUM('GOLDMANN', 'AIRE', 'PERKINS', 'ICARE'),
    IN p_notes VARCHAR(255)
)
BEGIN
    INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method, notes)
    VALUES (p_visit_id, p_eye, p_pressure, CURTIME(), p_method, p_notes);
END $$

-- 16. Crear un procedimiento para registrar un control de glaucoma.
DROP PROCEDURE IF EXISTS sp_record_glaucoma_control $$
CREATE PROCEDURE sp_record_glaucoma_control(
    IN p_glaucoma_record_id BIGINT,
    IN p_visit_id BIGINT,
    IN p_progression BOOLEAN,
    IN p_adherence ENUM('EXCELENTE', 'BUENA', 'REGULAR', 'MALA'),
    IN p_notes TEXT
)
BEGIN
    INSERT INTO glaucoma_controls (glaucoma_record_id, visit_id, control_date, is_progression_detected, adherence_score, notes)
    VALUES (p_glaucoma_record_id, p_visit_id, CURDATE(), p_progression, p_adherence, p_notes);
END $$

-- 17. Crear un procedimiento para registrar un examen OCT.
DROP PROCEDURE IF EXISTS sp_record_oct_exam $$
CREATE PROCEDURE sp_record_oct_exam(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_rnfl_avg DECIMAL(6,2),
    IN p_rnfl_sup DECIMAL(6,2),
    IN p_rnfl_inf DECIMAL(6,2),
    IN p_cup_disc DECIMAL(4,2),
    IN p_interpretation TEXT
)
BEGIN
    INSERT INTO oct_exams (visit_id, eye, rnfl_average, rnfl_superior, rnfl_inferior, cup_to_disc_ratio, interpretation, is_validated, exam_date)
    VALUES (p_visit_id, p_eye, p_rnfl_avg, p_rnfl_sup, p_rnfl_inf, p_cup_disc, p_interpretation, TRUE, NOW());
END $$

-- 18. Crear un procedimiento para registrar un campo visual.
DROP PROCEDURE IF EXISTS sp_record_visual_field $$
CREATE PROCEDURE sp_record_visual_field(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_md DECIMAL(6,2),
    IN p_psd DECIMAL(6,2),
    IN p_vfi DECIMAL(5,2),
    IN p_reliability ENUM('CONFIABLE', 'NO CONFIABLE'),
    IN p_interpretation TEXT
)
BEGIN
    INSERT INTO visual_field_exams (visit_id, eye, strategy, mean_deviation_md, pattern_std_deviation_psd, visual_field_index_vfi, reliability, interpretation, exam_date)
    VALUES (p_visit_id, p_eye, 'SITA-Standard 24-2', p_md, p_psd, p_vfi, p_reliability, p_interpretation, NOW());
END $$

-- 19. Crear un procedimiento para registrar una paquimetría.
DROP PROCEDURE IF EXISTS sp_record_pachymetry $$
CREATE PROCEDURE sp_record_pachymetry(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_thickness DECIMAL(6,2),
    IN p_method VARCHAR(50)
)
BEGIN
    INSERT INTO pachymetry_exams (visit_id, eye, corneal_thickness, method, exam_date)
    VALUES (p_visit_id, p_eye, p_thickness, IFNULL(p_method, 'ULTRASONICA'), NOW());
END $$

-- 20. Crear un procedimiento para registrar un tratamiento.
DROP PROCEDURE IF EXISTS sp_create_treatment $$
CREATE PROCEDURE sp_create_treatment(
    IN p_visit_id BIGINT,
    IN p_medication_id INT,
    IN p_eye ENUM('OD', 'OI', 'AMBOS'),
    IN p_dosage VARCHAR(100),
    IN p_frequency VARCHAR(100),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_notes TEXT
)
BEGIN
    INSERT INTO treatments (visit_id, medication_id, eye, dosage, frequency, start_date, end_date, is_active, notes)
    VALUES (p_visit_id, p_medication_id, p_eye, p_dosage, p_frequency, p_start_date, p_end_date, TRUE, p_notes);
END $$


-- ------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE MODIFICACIÓN (21 a 30)
-- ------------------------------------------------------------------------------

-- 21. Crear un procedimiento para actualizar teléfono y correo de un paciente.
DROP PROCEDURE IF EXISTS sp_update_patient_contact $$
CREATE PROCEDURE sp_update_patient_contact(
    IN p_patient_id BIGINT,
    IN p_new_phone VARCHAR(30),
    IN p_new_email VARCHAR(150)
)
BEGIN
    UPDATE persons per
    JOIN patients p ON per.id = p.person_id
    SET per.phone = p_new_phone, per.email = p_new_email
    WHERE p.id = p_patient_id;
END $$

-- 22. Crear un procedimiento para modificar el estado de una historia clínica.
DROP PROCEDURE IF EXISTS sp_update_history_status $$
CREATE PROCEDURE sp_update_history_status(
    IN p_history_id BIGINT,
    IN p_new_status ENUM('ACTIVA', 'ARCHIVADA', 'INACTIVA')
)
BEGIN
    UPDATE clinical_histories
    SET status = p_new_status
    WHERE id = p_history_id;
END $$

-- 23. Crear un procedimiento para actualizar observaciones de una consulta.
DROP PROCEDURE IF EXISTS sp_update_visit_notes $$
CREATE PROCEDURE sp_update_visit_notes(
    IN p_visit_id BIGINT,
    IN p_new_assessment TEXT,
    IN p_new_plan TEXT
)
BEGIN
    UPDATE medical_visits
    SET assessment = p_new_assessment, plan = p_new_plan
    WHERE id = p_visit_id;
END $$

-- 24. Crear un procedimiento para modificar la presión objetivo de un paciente con glaucoma.
DROP PROCEDURE IF EXISTS sp_update_target_iop $$
CREATE PROCEDURE sp_update_target_iop(
    IN p_patient_id BIGINT,
    IN p_target_od DECIMAL(5,2),
    IN p_target_oi DECIMAL(5,2)
)
BEGIN
    UPDATE glaucoma_records
    SET target_iop_od = p_target_od, target_iop_oi = p_target_oi
    WHERE patient_id = p_patient_id;
END $$

-- 25. Crear un procedimiento para finalizar un tratamiento.
DROP PROCEDURE IF EXISTS sp_finalize_treatment $$
CREATE PROCEDURE sp_finalize_treatment(IN p_treatment_id BIGINT)
BEGIN
    UPDATE treatments
    SET is_active = FALSE, end_date = CURDATE()
    WHERE id = p_treatment_id;
END $$

-- 26. Crear un procedimiento para cambiar el medicamento de un tratamiento.
DROP PROCEDURE IF EXISTS sp_change_treatment_medication $$
CREATE PROCEDURE sp_change_treatment_medication(
    IN p_treatment_id BIGINT,
    IN p_new_medication_id INT,
    IN p_new_dosage VARCHAR(100)
)
BEGIN
    UPDATE treatments
    SET medication_id = p_new_medication_id, dosage = p_new_dosage
    WHERE id = p_treatment_id;
END $$

-- 27. Crear un procedimiento para actualizar el estado clínico del glaucoma.
DROP PROCEDURE IF EXISTS sp_update_glaucoma_stage $$
CREATE PROCEDURE sp_update_glaucoma_stage(
    IN p_patient_id BIGINT,
    IN p_new_stage ENUM('SOSPECHA', 'INICIAL', 'MODERADO', 'AVANZADO', 'TERMINAL')
)
BEGIN
    UPDATE glaucoma_records
    SET clinical_stage = p_new_stage
    WHERE patient_id = p_patient_id;
END $$

-- 28. Crear un procedimiento para actualizar información de un profesional.
DROP PROCEDURE IF EXISTS sp_update_professional_contact $$
CREATE PROCEDURE sp_update_professional_contact(
    IN p_prof_id BIGINT,
    IN p_phone VARCHAR(30),
    IN p_email VARCHAR(150),
    IN p_is_active BOOLEAN
)
BEGIN
    UPDATE healthcare_professionals hp
    JOIN persons per ON hp.person_id = per.id
    SET per.phone = p_phone, per.email = p_email, hp.is_active = p_is_active
    WHERE hp.id = p_prof_id;
END $$

-- 29. Crear un procedimiento para modificar la interpretación de un OCT.
DROP PROCEDURE IF EXISTS sp_update_oct_interpretation $$
CREATE PROCEDURE sp_update_oct_interpretation(
    IN p_oct_id BIGINT,
    IN p_new_interpretation TEXT
)
BEGIN
    UPDATE oct_exams
    SET interpretation = p_new_interpretation
    WHERE id = p_oct_id;
END $$

-- 30. Crear un procedimiento para actualizar la interpretación de un campo visual.
DROP PROCEDURE IF EXISTS sp_update_visual_field_interpretation $$
CREATE PROCEDURE sp_update_visual_field_interpretation(
    IN p_vf_id BIGINT,
    IN p_new_interpretation TEXT,
    IN p_new_reliability ENUM('CONFIABLE', 'NO CONFIABLE')
)
BEGIN
    UPDATE visual_field_exams
    SET interpretation = p_new_interpretation, reliability = p_new_reliability
    WHERE id = p_vf_id;
END $$


-- ------------------------------------------------------------------------------
-- PROCEDIMIENTOS CON VALIDACIONES (31 a 40)
-- ------------------------------------------------------------------------------

-- 31. Crear un procedimiento que registre una PIO únicamente si la consulta médica existe.
DROP PROCEDURE IF EXISTS sp_val_insert_iop $$
CREATE PROCEDURE sp_val_insert_iop(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_pressure DECIMAL(5,2)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM medical_visits WHERE id = p_visit_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La consulta médica especificada no existe.';
    END IF;
    
    INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method)
    VALUES (p_visit_id, p_eye, p_pressure, CURTIME(), 'GOLDMANN');
END $$

-- 32. Crear un procedimiento que registre una consulta solo si existe la historia clínica.
DROP PROCEDURE IF EXISTS sp_val_insert_visit $$
CREATE PROCEDURE sp_val_insert_visit(
    IN p_history_id BIGINT,
    IN p_prof_id BIGINT,
    IN p_reason TEXT,
    IN p_assessment TEXT,
    IN p_plan TEXT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clinical_histories WHERE id = p_history_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La historia clínica no existe.';
    END IF;
    
    INSERT INTO medical_visits (clinical_history_id, professional_id, visit_date, reason, assessment, plan)
    VALUES (p_history_id, p_prof_id, NOW(), p_reason, p_assessment, p_plan);
END $$

-- 33. Crear un procedimiento que impida registrar un tratamiento con fecha final anterior a la inicial.
DROP PROCEDURE IF EXISTS sp_val_insert_treatment $$
CREATE PROCEDURE sp_val_insert_treatment(
    IN p_visit_id BIGINT,
    IN p_med_id INT,
    IN p_start DATE,
    IN p_end DATE,
    IN p_dosage VARCHAR(100),
    IN p_freq VARCHAR(100)
)
BEGIN
    IF p_end IS NOT NULL AND p_end < p_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de integridad: La fecha de finalización no puede ser anterior a la inicial.';
    END IF;
    
    INSERT INTO treatments (visit_id, medication_id, start_date, end_date, dosage, frequency)
    VALUES (p_visit_id, p_med_id, p_start, p_end, p_dosage, p_freq);
END $$

-- 34. Crear un procedimiento que impida registrar valores negativos o nulos de PIO.
DROP PROCEDURE IF EXISTS sp_val_check_iop_positive $$
CREATE PROCEDURE sp_val_check_iop_positive(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_pressure DECIMAL(5,2)
)
BEGIN
    IF p_pressure <= 0.00 OR p_pressure > 80.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error clínico: El valor de PIO debe ser estrictamente positivo y menor a 80 mmHg.';
    END IF;
    
    INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method)
    VALUES (p_visit_id, p_eye, p_pressure, CURTIME(), 'GOLDMANN');
END $$

-- 35. Crear un procedimiento que valide que el ojo recibido sea OD u OI.
DROP PROCEDURE IF EXISTS sp_val_check_eye $$
CREATE PROCEDURE sp_val_check_eye(
    IN p_visit_id BIGINT,
    IN p_eye VARCHAR(10),
    IN p_pressure DECIMAL(5,2)
)
BEGIN
    IF p_eye NOT IN ('OD', 'OI') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error anatómico: El ojo especificado debe ser OD u OI.';
    END IF;
    
    INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method)
    VALUES (p_visit_id, p_eye, p_pressure, CURTIME(), 'GOLDMANN');
END $$

-- 36. Crear un procedimiento que impida crear dos historias clínicas para el mismo paciente.
DROP PROCEDURE IF EXISTS sp_val_single_history $$
CREATE PROCEDURE sp_val_single_history(
    IN p_patient_id BIGINT,
    IN p_history_num VARCHAR(50)
)
BEGIN
    IF EXISTS (SELECT 1 FROM clinical_histories WHERE patient_id = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Violación de unicidad: El paciente ya cuenta con una historia clínica activa.';
    END IF;
    
    INSERT INTO clinical_histories (patient_id, history_number, status)
    VALUES (p_patient_id, p_history_num, 'ACTIVA');
END $$

-- 37. Crear un procedimiento que registre un diagnóstico solo si existe en el catálogo.
DROP PROCEDURE IF EXISTS sp_val_diagnosis_exists $$
CREATE PROCEDURE sp_val_diagnosis_exists(
    IN p_visit_id BIGINT,
    IN p_diagnosis_id INT,
    IN p_is_primary BOOLEAN
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM diagnoses WHERE id = p_diagnosis_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Catálogo inválido: El diagnóstico indicado no existe en el sistema.';
    END IF;
    
    INSERT INTO visit_diagnoses (visit_id, diagnosis_id, is_primary)
    VALUES (p_visit_id, p_diagnosis_id, p_is_primary);
END $$

-- 38. Crear un procedimiento que valide que el profesional se encuentre activo antes de registrar una consulta.
DROP PROCEDURE IF EXISTS sp_val_professional_active $$
CREATE PROCEDURE sp_val_professional_active(
    IN p_history_id BIGINT,
    IN p_prof_id BIGINT,
    IN p_reason TEXT,
    IN p_assessment TEXT,
    IN p_plan TEXT
)
BEGIN
    DECLARE v_is_active BOOLEAN;
    
    SELECT is_active INTO v_is_active FROM healthcare_professionals WHERE id = p_prof_id;
    
    IF v_is_active IS NULL OR v_is_active = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error operativo: El profesional asignado se encuentra inactivo.';
    END IF;
    
    INSERT INTO medical_visits (clinical_history_id, professional_id, visit_date, reason, assessment, plan)
    VALUES (p_history_id, p_prof_id, NOW(), p_reason, p_assessment, p_plan);
END $$

-- 39. Crear un procedimiento que registre un campo visual validando que VFI esté entre 0 y 100.
DROP PROCEDURE IF EXISTS sp_val_vfi_range $$
CREATE PROCEDURE sp_val_vfi_range(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_vfi DECIMAL(5,2),
    IN p_md DECIMAL(6,2),
    IN p_psd DECIMAL(6,2)
)
BEGIN
    IF p_vfi < 0.00 OR p_vfi > 100.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango inválido: El índice de campo visual (VFI) debe ubicarse estrictamente entre 0% y 100%.';
    END IF;
    
    INSERT INTO visual_field_exams (visit_id, eye, visual_field_index_vfi, mean_deviation_md, pattern_std_deviation_psd)
    VALUES (p_visit_id, p_eye, p_vfi, p_md, p_psd);
END $$

-- 40. Crear un procedimiento que registre una paquimetría validando que el valor sea positivo.
DROP PROCEDURE IF EXISTS sp_val_pachymetry_positive $$
CREATE PROCEDURE sp_val_pachymetry_positive(
    IN p_visit_id BIGINT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_thickness DECIMAL(6,2)
)
BEGIN
    IF p_thickness <= 0.00 OR p_thickness > 1000.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Espesor anómalo: La paquimetría debe ser un valor positivo plausible (menor a 1000 micras).';
    END IF;
    
    INSERT INTO pachymetry_exams (visit_id, eye, corneal_thickness)
    VALUES (p_visit_id, p_eye, p_thickness);
END $$


-- ------------------------------------------------------------------------------
-- PROCEDIMIENTOS AVANZADOS Y TRANSACCIONALES (41 a 50)
-- ------------------------------------------------------------------------------

-- 41. Crear un procedimiento que devuelva un resumen completo de la historia clínica de un paciente.
DROP PROCEDURE IF EXISTS sp_patient_complete_summary $$
CREATE PROCEDURE sp_patient_complete_summary(IN p_patient_id BIGINT)
BEGIN
    -- Datos demográficos e Historia
    SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS name,
           per.birth_date, TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) AS age,
           ch.history_number, ch.status AS history_status
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    JOIN clinical_histories ch ON p.id = ch.patient_id
    WHERE p.id = p_patient_id;
    
    -- Alergias, Antecedentes y Factores de Riesgo
    SELECT 'ALERGIAS' AS categoria, allergen AS detalle, severity AS extra FROM patient_allergies WHERE patient_id = p_patient_id
    UNION ALL
    SELECT 'ANTECEDENTE FAMILIAR', condition_name, relationship FROM patient_family_histories WHERE patient_id = p_patient_id
    UNION ALL
    SELECT 'ANTECEDENTE PERSONAL', description, antecedent_type FROM patient_antecedents WHERE patient_id = p_patient_id
    UNION ALL
    SELECT 'FACTOR RIESGO GLAUCOMA', risk_factor, IFNULL(notes, 'SIN OBSERVACIONES') FROM glaucoma_risk_factors WHERE patient_id = p_patient_id;
    
    -- Consultas Recientes
    SELECT mv.id, mv.visit_date, mv.reason, CONCAT(per.first_name, ' ', per.last_name) AS professional
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    JOIN healthcare_professionals hp ON mv.professional_id = hp.id
    JOIN persons per ON hp.person_id = per.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC LIMIT 5;
END $$

-- 42. Crear un procedimiento que muestre la evolución de PIO de un paciente entre dos fechas.
DROP PROCEDURE IF EXISTS sp_patient_iop_evolution $$
CREATE PROCEDURE sp_patient_iop_evolution(
    IN p_patient_id BIGINT,
    IN p_from_date DATE,
    IN p_to_date DATE
)
BEGIN
    SELECT mv.visit_date, iop.eye, iop.pressure, iop.method, iop.notes
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
      AND DATE(mv.visit_date) BETWEEN p_from_date AND p_to_date
    ORDER BY mv.visit_date ASC, iop.eye ASC;
END $$

-- 43. Crear un procedimiento que reciba paciente y ojo y muestre todas sus mediciones cronológicamente.
DROP PROCEDURE IF EXISTS sp_patient_iop_by_eye $$
CREATE PROCEDURE sp_patient_iop_by_eye(
    IN p_patient_id BIGINT,
    IN p_eye ENUM('OD', 'OI')
)
BEGIN
    SELECT mv.visit_date, iop.pressure, iop.method, iop.notes
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = p_eye
    ORDER BY mv.visit_date ASC;
END $$

-- 44. Crear un procedimiento que genere estadísticas mensuales de consultas.
DROP PROCEDURE IF EXISTS sp_monthly_visit_stats $$
CREATE PROCEDURE sp_monthly_visit_stats(IN p_year INT)
BEGIN
    SELECT MONTH(visit_date) AS visit_month,
           COUNT(*) AS total_visits,
           COUNT(DISTINCT clinical_history_id) AS distinct_patients,
           COUNT(DISTINCT professional_id) AS active_doctors
    FROM medical_visits
    WHERE YEAR(visit_date) = p_year
    GROUP BY MONTH(visit_date)
    ORDER BY visit_month;
END $$

-- 45. Crear un procedimiento que calcule la cantidad de pacientes atendidos por cada especialista.
DROP PROCEDURE IF EXISTS sp_patients_per_specialist $$
CREATE PROCEDURE sp_patients_per_specialist()
BEGIN
    SELECT s.name AS specialty,
           CONCAT(per.first_name, ' ', per.last_name) AS professional_name,
           COUNT(DISTINCT ch.patient_id) AS total_unique_patients
    FROM healthcare_professionals hp
    JOIN persons per ON hp.person_id = per.id
    JOIN specialties s ON hp.specialty_id = s.id
    LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
    LEFT JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    GROUP BY hp.id, s.name, professional_name
    ORDER BY s.name, total_unique_patients DESC;
END $$

-- 46. Crear un procedimiento que determine pacientes sin consulta durante un número de meses recibido como parámetro.
DROP PROCEDURE IF EXISTS sp_patients_inactive_months $$
CREATE PROCEDURE sp_patients_inactive_months(IN p_months INT)
BEGIN
    SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
           MAX(mv.visit_date) AS last_visit_date,
           TIMESTAMPDIFF(MONTH, MAX(mv.visit_date), NOW()) AS months_since_last_visit
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    JOIN clinical_histories ch ON p.id = ch.patient_id
    LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    GROUP BY p.id, patient_name, per.document_number
    HAVING last_visit_date IS NULL OR months_since_last_visit >= p_months
    ORDER BY months_since_last_visit DESC;
END $$

-- 47. Crear un procedimiento que genere un resumen de diagnósticos por paciente.
DROP PROCEDURE IF EXISTS sp_diagnoses_summary_by_patient $$
CREATE PROCEDURE sp_diagnoses_summary_by_patient(IN p_patient_id BIGINT)
BEGIN
    SELECT d.code, d.name AS diagnosis_name, d.is_glaucoma_type,
           COUNT(vd.id) AS occurrences,
           MIN(mv.visit_date) AS first_diagnosed,
           MAX(mv.visit_date) AS last_diagnosed
    FROM visit_diagnoses vd
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    GROUP BY d.code, d.name, d.is_glaucoma_type
    ORDER BY occurrences DESC;
END $$

-- 48. Crear un procedimiento que devuelva el último OCT, último campo visual y última PIO de un paciente.
DROP PROCEDURE IF EXISTS sp_patient_latest_exams $$
CREATE PROCEDURE sp_patient_latest_exams(IN p_patient_id BIGINT)
BEGIN
    -- Último OCT
    SELECT 'ÚLTIMO OCT' AS exam_type, oct.exam_date, oct.eye,
           CONCAT('RNFL: ', oct.rnfl_average, ' µm, Cup/Disc: ', IFNULL(oct.cup_to_disc_ratio, 'N/A')) AS metrics,
           oct.interpretation AS findings
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY oct.exam_date DESC LIMIT 1;
    
    -- Último Campo Visual
    SELECT 'ÚLTIMO CAMPO VISUAL' AS exam_type, vf.exam_date, vf.eye,
           CONCAT('MD: ', vf.mean_deviation_md, ' dB, VFI: ', vf.visual_field_index_vfi, '%') AS metrics,
           vf.interpretation AS findings
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY vf.exam_date DESC LIMIT 1;
    
    -- Última PIO
    SELECT 'ÚLTIMA PIO' AS exam_type, mv.visit_date AS exam_date, iop.eye,
           CONCAT('Presión: ', iop.pressure, ' mmHg') AS metrics,
           iop.notes AS findings
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;

    -- Última Agudeza Visual
    SELECT 'ÚLTIMA AGUDEZA VISUAL' AS exam_type, va.exam_date, va.eye,
           CONCAT('SC: ', va.uncorrected_va, ' | CC: ', va.corrected_va) AS metrics,
           CONCAT('Esfera: ', IFNULL(va.sphere, 0.00), ' Cil: ', IFNULL(va.cylinder, 0.00), ' Eje: ', IFNULL(va.axis, 0)) AS findings
    FROM visual_acuity_exams va
    JOIN medical_visits mv ON va.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY va.exam_date DESC LIMIT 1;

    -- Última Biomicroscopía
    SELECT 'ÚLTIMA BIOMICROSCOPIA' AS exam_type, bio.exam_date, bio.eye,
           CONCAT('Cámara: ', bio.anterior_chamber_depth, ' | Cristalino: ', bio.lens_status) AS metrics,
           CONCAT('Córnea: ', bio.cornea_status, ' | Iris: ', bio.iris_status, ' | PXF: ', IF(bio.pseudoexfoliation_present, 'SI', 'NO')) AS findings
    FROM biomicroscopy_exams bio
    JOIN medical_visits mv ON bio.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY bio.exam_date DESC LIMIT 1;
END $$

-- 49. Crear un procedimiento transaccional que registre en una sola transacción una consulta, un diagnóstico y una medición de PIO.
DROP PROCEDURE IF EXISTS sp_tx_create_visit_diagnosis_iop $$
CREATE PROCEDURE sp_tx_create_visit_diagnosis_iop(
    IN p_history_id BIGINT,
    IN p_prof_id BIGINT,
    IN p_reason TEXT,
    IN p_assessment TEXT,
    IN p_plan TEXT,
    IN p_diagnosis_id INT,
    IN p_eye ENUM('OD', 'OI'),
    IN p_pressure DECIMAL(5,2),
    OUT p_out_visit_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- 1. Crear Consulta
        INSERT INTO medical_visits (clinical_history_id, professional_id, visit_date, reason, assessment, plan, is_closed)
        VALUES (p_history_id, p_prof_id, NOW(), p_reason, p_assessment, p_plan, FALSE);
        SET p_out_visit_id = LAST_INSERT_ID();

        -- 2. Asociar Diagnóstico
        INSERT INTO visit_diagnoses (visit_id, diagnosis_id, is_primary, notes)
        VALUES (p_out_visit_id, p_diagnosis_id, TRUE, 'Diagnóstico principal ingresado en flujo transaccional');

        -- 3. Registrar Medición de PIO
        INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method)
        VALUES (p_out_visit_id, p_eye, p_pressure, CURTIME(), 'GOLDMANN');
    COMMIT;
END $$

-- 50. Crear un procedimiento transaccional que registre un control completo de glaucoma y ejecute ROLLBACK si alguna operación falla.
DROP PROCEDURE IF EXISTS sp_tx_full_glaucoma_control $$
CREATE PROCEDURE sp_tx_full_glaucoma_control(
    IN p_patient_id BIGINT,
    IN p_prof_id BIGINT,
    IN p_reason TEXT,
    IN p_assessment TEXT,
    IN p_plan TEXT,
    IN p_progression BOOLEAN,
    IN p_adherence ENUM('EXCELENTE', 'BUENA', 'REGULAR', 'MALA'),
    IN p_notes TEXT,
    IN p_iop_od DECIMAL(5,2),
    IN p_iop_oi DECIMAL(5,2)
)
BEGIN
    DECLARE v_history_id BIGINT;
    DECLARE v_glaucoma_record_id BIGINT;
    DECLARE v_new_visit_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Obtener historia clínica
        SELECT id INTO v_history_id FROM clinical_histories WHERE patient_id = p_patient_id;
        IF v_history_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Transaccional: El paciente no posee historia clínica activa.';
        END IF;

        -- Obtener ficha maestra de glaucoma
        SELECT id INTO v_glaucoma_record_id FROM glaucoma_records WHERE patient_id = p_patient_id;
        IF v_glaucoma_record_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Transaccional: El paciente no posee ficha registrada de glaucoma.';
        END IF;

        -- 1. Insertar Consulta
        INSERT INTO medical_visits (clinical_history_id, professional_id, visit_date, reason, assessment, plan, is_closed)
        VALUES (v_history_id, p_prof_id, NOW(), p_reason, p_assessment, p_plan, TRUE);
        SET v_new_visit_id = LAST_INSERT_ID();

        -- 2. Registrar PIO bilateral
        INSERT INTO intraocular_pressures (visit_id, eye, pressure, measurement_time, method)
        VALUES (v_new_visit_id, 'OD', p_iop_od, CURTIME(), 'GOLDMANN'),
               (v_new_visit_id, 'OI', p_iop_oi, CURTIME(), 'GOLDMANN');

        -- 3. Registrar Control Evolutivo
        INSERT INTO glaucoma_controls (glaucoma_record_id, visit_id, control_date, is_progression_detected, adherence_score, notes)
        VALUES (v_glaucoma_record_id, v_new_visit_id, CURDATE(), p_progression, p_adherence, p_notes);
    COMMIT;
END $$

DELIMITER ;
