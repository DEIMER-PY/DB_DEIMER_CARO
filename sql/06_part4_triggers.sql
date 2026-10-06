-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 06_part4_triggers.sql
-- DESCRIPCIÓN: PARTE IV — 50 Triggers y Lógica de Auditoría / Integridad
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

DELIMITER $$

-- ------------------------------------------------------------------------------
-- BEFORE INSERT (1 a 10)
-- ------------------------------------------------------------------------------

-- 1. Eliminar espacios externos de los nombres de pacientes antes de insertarlos.
DROP TRIGGER IF EXISTS trg_bi_patients_trim_names $$
CREATE TRIGGER trg_bi_patients_trim_names
BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
    SET NEW.first_name = TRIM(NEW.first_name);
    SET NEW.last_name = TRIM(NEW.last_name);
END $$

-- 2. Convertir automáticamente el correo del paciente a minúsculas.
DROP TRIGGER IF EXISTS trg_bi_patients_lower_email $$
CREATE TRIGGER trg_bi_patients_lower_email
BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
    IF NEW.email IS NOT NULL THEN
        SET NEW.email = LOWER(TRIM(NEW.email));
    END IF;
END $$

-- 3. Convertir el número de documento a mayúsculas cuando contenga caracteres.
DROP TRIGGER IF EXISTS trg_bi_patients_upper_document $$
CREATE TRIGGER trg_bi_patients_upper_document
BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
    SET NEW.document_number = UPPER(TRIM(NEW.document_number));
END $$

-- 4. Impedir registrar una fecha de nacimiento futura.
DROP TRIGGER IF EXISTS trg_bi_patients_check_birth_date $$
CREATE TRIGGER trg_bi_patients_check_birth_date
BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
    IF NEW.birth_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error cronológico: La fecha de nacimiento no puede ser posterior a la fecha actual.';
    END IF;
END $$

-- 5. Impedir registrar una presión intraocular negativa.
DROP TRIGGER IF EXISTS trg_bi_iop_check_positive $$
CREATE TRIGGER trg_bi_iop_check_positive
BEFORE INSERT ON intraocular_pressures
FOR EACH ROW
BEGIN
    IF NEW.pressure <= 0.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de rango: La presión intraocular debe ser estrictamente mayor a 0 mmHg.';
    END IF;
END $$

-- 6. Impedir registrar una PIO superior a un límite definido para datos plausibles.
DROP TRIGGER IF EXISTS trg_bi_iop_check_max_plausible $$
CREATE TRIGGER trg_bi_iop_check_max_plausible
BEFORE INSERT ON intraocular_pressures
FOR EACH ROW
BEGIN
    IF NEW.pressure > 80.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error clínico: La presión intraocular no puede superar los 80.00 mmHg.';
    END IF;
END $$

-- 7. Validar que el campo eye solo admita OD u OI.
DROP TRIGGER IF EXISTS trg_bi_iop_check_eye $$
CREATE TRIGGER trg_bi_iop_check_eye
BEFORE INSERT ON intraocular_pressures
FOR EACH ROW
BEGIN
    IF NEW.eye NOT IN ('OD', 'OI') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error anatómico: La lateralidad debe especificarse como OD u OI.';
    END IF;
END $$

-- 8. Impedir que un tratamiento tenga fecha final anterior a la inicial.
DROP TRIGGER IF EXISTS trg_bi_treatments_check_dates $$
CREATE TRIGGER trg_bi_treatments_check_dates
BEFORE INSERT ON treatments
FOR EACH ROW
BEGIN
    IF NEW.end_date IS NOT NULL AND NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de fechas: La fecha final del tratamiento no puede ser anterior a la inicial.';
    END IF;
END $$

-- 9. Validar que el VFI de un campo visual esté entre 0 y 100.
DROP TRIGGER IF EXISTS trg_bi_vf_check_vfi_range $$
CREATE TRIGGER trg_bi_vf_check_vfi_range
BEFORE INSERT ON visual_field_exams
FOR EACH ROW
BEGIN
    IF NEW.visual_field_index_vfi < 0.00 OR NEW.visual_field_index_vfi > 100.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de índice: El Visual Field Index (VFI) debe encontrarse entre 0% y 100%.';
    END IF;
END $$

-- 10. Validar que la paquimetría sea mayor que cero.
DROP TRIGGER IF EXISTS trg_bi_pachy_check_thickness $$
CREATE TRIGGER trg_bi_pachy_check_thickness
BEFORE INSERT ON pachymetry_exams
FOR EACH ROW
BEGIN
    IF NEW.corneal_thickness <= 0.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error corneal: El espesor paquimétrico debe ser superior a 0 micras.';
    END IF;
END $$


-- ------------------------------------------------------------------------------
-- AFTER INSERT (11 a 20)
-- ------------------------------------------------------------------------------

-- 11. Registrar en auditoría la creación de un nuevo paciente.
DROP TRIGGER IF EXISTS trg_ai_audit_patient $$
CREATE TRIGGER trg_ai_audit_patient
AFTER INSERT ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('patients', NEW.id, 'INSERT', JSON_OBJECT('document', NEW.document_number, 'name', CONCAT(NEW.first_name, ' ', NEW.last_name)), 'SYSTEM', NOW());
END $$

-- 12. Registrar en auditoría la creación de una historia clínica.
DROP TRIGGER IF EXISTS trg_ai_audit_clinical_history $$
CREATE TRIGGER trg_ai_audit_clinical_history
AFTER INSERT ON clinical_histories
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('clinical_histories', NEW.id, 'INSERT', JSON_OBJECT('history_number', NEW.history_number, 'patient_id', NEW.patient_id), 'SYSTEM', NOW());
END $$

-- 13. Registrar automáticamente en auditoría cada nueva consulta.
DROP TRIGGER IF EXISTS trg_ai_audit_medical_visit $$
CREATE TRIGGER trg_ai_audit_medical_visit
AFTER INSERT ON medical_visits
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('medical_visits', NEW.id, 'INSERT', JSON_OBJECT('history_id', NEW.clinical_history_id, 'professional_id', NEW.professional_id, 'date', NEW.visit_date), 'SYSTEM', NOW());
END $$

-- 14. Registrar cada nuevo diagnóstico asociado a una consulta.
DROP TRIGGER IF EXISTS trg_ai_audit_visit_diagnosis $$
CREATE TRIGGER trg_ai_audit_visit_diagnosis
AFTER INSERT ON visit_diagnoses
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('visit_diagnoses', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'diagnosis_id', NEW.diagnosis_id, 'primary', NEW.is_primary), 'SYSTEM', NOW());
END $$

-- 15. Registrar cada nueva medición de presión intraocular.
DROP TRIGGER IF EXISTS trg_ai_audit_iop $$
CREATE TRIGGER trg_ai_audit_iop
AFTER INSERT ON intraocular_pressures
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('intraocular_pressures', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'eye', NEW.eye, 'pressure', NEW.pressure), 'SYSTEM', NOW());
END $$

-- 16. Registrar cada nuevo tratamiento.
DROP TRIGGER IF EXISTS trg_ai_audit_treatment $$
CREATE TRIGGER trg_ai_audit_treatment
AFTER INSERT ON treatments
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('treatments', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'medication_id', NEW.medication_id, 'eye', NEW.eye), 'SYSTEM', NOW());
END $$

-- 17. Registrar cada nuevo procedimiento.
DROP TRIGGER IF EXISTS trg_ai_audit_procedure $$
CREATE TRIGGER trg_ai_audit_procedure
AFTER INSERT ON procedures
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('procedures', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'name', NEW.name, 'eye', NEW.eye), 'SYSTEM', NOW());
END $$

-- 18. Registrar en auditoría cada nuevo estudio OCT.
DROP TRIGGER IF EXISTS trg_ai_audit_oct $$
CREATE TRIGGER trg_ai_audit_oct
AFTER INSERT ON oct_exams
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('oct_exams', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'eye', NEW.eye, 'rnfl_average', NEW.rnfl_average), 'SYSTEM', NOW());
END $$

-- 19. Registrar cada campo visual creado.
DROP TRIGGER IF EXISTS trg_ai_audit_visual_field $$
CREATE TRIGGER trg_ai_audit_visual_field
AFTER INSERT ON visual_field_exams
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('visual_field_exams', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'eye', NEW.eye, 'vfi', NEW.visual_field_index_vfi, 'md', NEW.mean_deviation_md), 'SYSTEM', NOW());
END $$

-- 20. Crear una notificación interna cuando se registre una PIO mayor que 30 mmHg.
DROP TRIGGER IF EXISTS trg_ai_iop_alert_high $$
CREATE TRIGGER trg_ai_iop_alert_high
AFTER INSERT ON intraocular_pressures
FOR EACH ROW
BEGIN
    IF NEW.pressure >= 30.00 THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
        VALUES ('intraocular_pressures', NEW.id, 'ALERT', JSON_OBJECT('alert', 'PIO CRITICA DETECTADA', 'eye', NEW.eye, 'pressure', NEW.pressure), 'CLINICAL_MONITOR', NOW());
    END IF;
END $$


-- ------------------------------------------------------------------------------
-- BEFORE UPDATE (21 a 30)
-- ------------------------------------------------------------------------------

-- 21. Actualizar automáticamente updated_at antes de modificar un paciente.
DROP TRIGGER IF EXISTS trg_bu_patients_updated_at $$
CREATE TRIGGER trg_bu_patients_updated_at
BEFORE UPDATE ON patients
FOR EACH ROW
BEGIN
    SET NEW.first_name = TRIM(NEW.first_name);
    SET NEW.last_name = TRIM(NEW.last_name);
    IF NEW.email IS NOT NULL THEN
        SET NEW.email = LOWER(TRIM(NEW.email));
    END IF;
    SET NEW.updated_at = NOW();
END $$

-- 22. Actualizar updated_at antes de modificar una consulta.
DROP TRIGGER IF EXISTS trg_bu_visits_updated_at $$
CREATE TRIGGER trg_bu_visits_updated_at
BEFORE UPDATE ON medical_visits
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END $$

-- 23. Impedir modificar el número de documento una vez creada la historia clínica.
DROP TRIGGER IF EXISTS trg_bu_patients_freeze_doc $$
CREATE TRIGGER trg_bu_patients_freeze_doc
BEFORE UPDATE ON patients
FOR EACH ROW
BEGIN
    IF NEW.document_number <> OLD.document_number THEN
        IF EXISTS (SELECT 1 FROM clinical_histories WHERE patient_id = OLD.id) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Integridad clínica: No se permite modificar el número de documento una vez expedida la historia clínica.';
        END IF;
    END IF;
END $$

-- 24. Impedir asignar una fecha de consulta futura no permitida.
DROP TRIGGER IF EXISTS trg_bu_visits_check_date $$
CREATE TRIGGER trg_bu_visits_check_date
BEFORE UPDATE ON medical_visits
FOR EACH ROW
BEGIN
    IF NEW.visit_date > (NOW() + INTERVAL 1 DAY) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error cronológico: La consulta no puede registrarse con fecha posterior a 24 horas en el futuro.';
    END IF;
END $$

-- 25. Validar que una nueva presión objetivo sea positiva.
DROP TRIGGER IF EXISTS trg_bu_glaucoma_target_iop_positive $$
CREATE TRIGGER trg_bu_glaucoma_target_iop_positive
BEFORE UPDATE ON glaucoma_records
FOR EACH ROW
BEGIN
    IF NEW.target_iop_od <= 0.00 OR NEW.target_iop_oi <= 0.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Presión objetivo inválida: Las metas tensionales deben ser valores positivos mayores a cero.';
    END IF;
END $$

-- 26. Impedir establecer una fecha final de tratamiento anterior a su inicio.
DROP TRIGGER IF EXISTS trg_bu_treatments_check_dates $$
CREATE TRIGGER trg_bu_treatments_check_dates
BEFORE UPDATE ON treatments
FOR EACH ROW
BEGIN
    IF NEW.end_date IS NOT NULL AND NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de tratamiento: La fecha de término no puede anteceder a la fecha de inicio.';
    END IF;
END $$

-- 27. Evitar modificar un examen OCT que haya sido marcado como validado.
DROP TRIGGER IF EXISTS trg_bu_oct_prevent_mod_validated $$
CREATE TRIGGER trg_bu_oct_prevent_mod_validated
BEFORE UPDATE ON oct_exams
FOR EACH ROW
BEGIN
    IF OLD.is_validated = TRUE AND NEW.is_validated = TRUE THEN
        IF OLD.rnfl_average <> NEW.rnfl_average OR OLD.cup_to_disc_ratio <> NEW.cup_to_disc_ratio THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registro inmutable: Un estudio OCT formalmente validado no puede ser alterado.';
        END IF;
    END IF;
END $$

-- 28. Evitar modificar una consulta marcada como cerrada.
DROP TRIGGER IF EXISTS trg_bu_visits_prevent_mod_closed $$
CREATE TRIGGER trg_bu_visits_prevent_mod_closed
BEFORE UPDATE ON medical_visits
FOR EACH ROW
BEGIN
    IF OLD.is_closed = TRUE AND NEW.is_closed = TRUE THEN
        IF OLD.reason <> NEW.reason OR OLD.assessment <> NEW.assessment OR OLD.plan <> NEW.plan THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Consulta cerrada: No es posible editar las conclusiones clínicas de una consulta ya cerrada.';
        END IF;
    END IF;
END $$

-- 29. Validar valores del campo visual antes de una actualización.
DROP TRIGGER IF EXISTS trg_bu_vf_check_values $$
CREATE TRIGGER trg_bu_vf_check_values
BEFORE UPDATE ON visual_field_exams
FOR EACH ROW
BEGIN
    IF NEW.visual_field_index_vfi < 0.00 OR NEW.visual_field_index_vfi > 100.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rango inválido: El VFI debe permanecer dentro del intervalo del 0% al 100%.';
    END IF;
END $$

-- 30. Normalizar observaciones eliminando espacios innecesarios antes de actualizar.
DROP TRIGGER IF EXISTS trg_bu_visits_normalize_notes $$
CREATE TRIGGER trg_bu_visits_normalize_notes
BEFORE UPDATE ON medical_visits
FOR EACH ROW
BEGIN
    SET NEW.reason = TRIM(NEW.reason);
    SET NEW.assessment = TRIM(NEW.assessment);
    SET NEW.plan = TRIM(NEW.plan);
END $$


-- ------------------------------------------------------------------------------
-- AFTER UPDATE (31 a 40)
-- ------------------------------------------------------------------------------

-- 31. Registrar cambios de datos personales del paciente.
DROP TRIGGER IF EXISTS trg_au_audit_patient_update $$
CREATE TRIGGER trg_au_audit_patient_update
AFTER UPDATE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
    VALUES ('patients', NEW.id, 'UPDATE',
            JSON_OBJECT('phone', OLD.phone, 'address', OLD.address),
            JSON_OBJECT('phone', NEW.phone, 'address', NEW.address),
            'SYSTEM', NOW());
END $$

-- 32. Guardar valor anterior y nuevo del correo del paciente.
DROP TRIGGER IF EXISTS trg_au_audit_patient_email $$
CREATE TRIGGER trg_au_audit_patient_email
AFTER UPDATE ON patients
FOR EACH ROW
BEGIN
    IF OLD.email <=> NEW.email THEN
        -- No cambió el correo
        BEGIN END;
    ELSE
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
        VALUES ('patients', NEW.id, 'UPDATE',
                JSON_OBJECT('email', OLD.email),
                JSON_OBJECT('email', NEW.email),
                'SECURITY_AUDIT', NOW());
    END IF;
END $$

-- 33. Registrar cambios en la presión objetivo.
DROP TRIGGER IF EXISTS trg_au_audit_glaucoma_target_iop $$
CREATE TRIGGER trg_au_audit_glaucoma_target_iop
AFTER UPDATE ON glaucoma_records
FOR EACH ROW
BEGIN
    IF OLD.target_iop_od <> NEW.target_iop_od OR OLD.target_iop_oi <> NEW.target_iop_oi THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
        VALUES ('glaucoma_records', NEW.id, 'UPDATE',
                JSON_OBJECT('target_od', OLD.target_iop_od, 'target_oi', OLD.target_iop_oi),
                JSON_OBJECT('target_od', NEW.target_iop_od, 'target_oi', NEW.target_iop_oi),
                'GLAUCOMA_SERVICE', NOW());
    END IF;
END $$

-- 34. Auditar cambios en el estado del glaucoma.
DROP TRIGGER IF EXISTS trg_au_audit_glaucoma_stage $$
CREATE TRIGGER trg_au_audit_glaucoma_stage
AFTER UPDATE ON glaucoma_records
FOR EACH ROW
BEGIN
    IF OLD.clinical_stage <> NEW.clinical_stage THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
        VALUES ('glaucoma_records', NEW.id, 'UPDATE',
                JSON_OBJECT('clinical_stage', OLD.clinical_stage),
                JSON_OBJECT('clinical_stage', NEW.clinical_stage),
                'CLINICAL_AUDIT', NOW());
    END IF;
END $$

-- 35. Registrar cambios en tratamientos.
DROP TRIGGER IF EXISTS trg_au_audit_treatment_update $$
CREATE TRIGGER trg_au_audit_treatment_update
AFTER UPDATE ON treatments
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
    VALUES ('treatments', NEW.id, 'UPDATE',
            JSON_OBJECT('dosage', OLD.dosage, 'is_active', OLD.is_active, 'medication_id', OLD.medication_id),
            JSON_OBJECT('dosage', NEW.dosage, 'is_active', NEW.is_active, 'medication_id', NEW.medication_id),
            'PHARMACY_AUDIT', NOW());
END $$

-- 36. Registrar cambios en diagnósticos.
DROP TRIGGER IF EXISTS trg_au_audit_diagnosis_update $$
CREATE TRIGGER trg_au_audit_diagnosis_update
AFTER UPDATE ON visit_diagnoses
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
    VALUES ('visit_diagnoses', NEW.id, 'UPDATE',
            JSON_OBJECT('diagnosis_id', OLD.diagnosis_id, 'is_primary', OLD.is_primary),
            JSON_OBJECT('diagnosis_id', NEW.diagnosis_id, 'is_primary', NEW.is_primary),
            'SYSTEM', NOW());
END $$

-- 37. Registrar cambios de interpretación de OCT.
DROP TRIGGER IF EXISTS trg_au_audit_oct_interpretation $$
CREATE TRIGGER trg_au_audit_oct_interpretation
AFTER UPDATE ON oct_exams
FOR EACH ROW
BEGIN
    IF OLD.interpretation <> NEW.interpretation THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
        VALUES ('oct_exams', NEW.id, 'UPDATE',
                JSON_OBJECT('interpretation', OLD.interpretation),
                JSON_OBJECT('interpretation', NEW.interpretation),
                'IMAGING_AUDIT', NOW());
    END IF;
END $$

-- 38. Registrar modificaciones de campos visuales.
DROP TRIGGER IF EXISTS trg_au_audit_vf_update $$
CREATE TRIGGER trg_au_audit_vf_update
AFTER UPDATE ON visual_field_exams
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
    VALUES ('visual_field_exams', NEW.id, 'UPDATE',
            JSON_OBJECT('vfi', OLD.visual_field_index_vfi, 'reliability', OLD.reliability),
            JSON_OBJECT('vfi', NEW.visual_field_index_vfi, 'reliability', NEW.reliability),
            'FUNCTIONAL_AUDIT', NOW());
END $$

-- 39. Generar una alerta cuando una PIO sea actualizada a un valor superior al objetivo.
DROP TRIGGER IF EXISTS trg_au_iop_alert_target_exceeded $$
CREATE TRIGGER trg_au_iop_alert_target_exceeded
AFTER UPDATE ON intraocular_pressures
FOR EACH ROW
BEGIN
    IF NEW.pressure > 24.00 AND NEW.pressure > OLD.pressure THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
        VALUES ('intraocular_pressures', NEW.id, 'ALERT',
                JSON_OBJECT('alert', 'AUMENTO DE PIO POR ENCIMA DE UMBRAL', 'old_p', OLD.pressure, 'new_p', NEW.pressure),
                'SAFETY_SYSTEM', NOW());
    END IF;
END $$

-- 40. Registrar cuándo un tratamiento cambia de activo a finalizado.
DROP TRIGGER IF EXISTS trg_au_treatment_finalize_audit $$
CREATE TRIGGER trg_au_treatment_finalize_audit
AFTER UPDATE ON treatments
FOR EACH ROW
BEGIN
    IF OLD.is_active = TRUE AND NEW.is_active = FALSE THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
        VALUES ('treatments', NEW.id, 'UPDATE',
                JSON_OBJECT('status', 'ACTIVO', 'end_date', OLD.end_date),
                JSON_OBJECT('status', 'FINALIZADO', 'end_date', NEW.end_date),
                'TREATMENT_CLOSURE', NOW());
    END IF;
END $$


-- ------------------------------------------------------------------------------
-- DELETE Y AUDITORÍA DE SEGURIDAD (41 a 50)
-- ------------------------------------------------------------------------------

-- 41. Guardar una copia de un paciente antes de eliminarlo.
DROP TRIGGER IF EXISTS trg_bd_patients_backup $$
CREATE TRIGGER trg_bd_patients_backup
BEFORE DELETE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO patients_backup (id, document_type_id, document_number, first_name, last_name, birth_date, gender, city_id, address, phone, email, created_at, updated_at)
    VALUES (OLD.id, OLD.document_type_id, OLD.document_number, OLD.first_name, OLD.last_name, OLD.birth_date, OLD.gender, OLD.city_id, OLD.address, OLD.phone, OLD.email, OLD.created_at, OLD.updated_at);
END $$

-- 42. Guardar una copia de una consulta eliminada.
DROP TRIGGER IF EXISTS trg_bd_visits_backup $$
CREATE TRIGGER trg_bd_visits_backup
BEFORE DELETE ON medical_visits
FOR EACH ROW
BEGIN
    INSERT INTO medical_visits_backup (id, clinical_history_id, professional_id, visit_date, reason, symptoms, assessment, plan, is_closed, created_at, updated_at)
    VALUES (OLD.id, OLD.clinical_history_id, OLD.professional_id, OLD.visit_date, OLD.reason, OLD.symptoms, OLD.assessment, OLD.plan, OLD.is_closed, OLD.created_at, OLD.updated_at);
END $$

-- 43. Guardar un histórico de un tratamiento eliminado.
DROP TRIGGER IF EXISTS trg_bd_treatments_backup $$
CREATE TRIGGER trg_bd_treatments_backup
BEFORE DELETE ON treatments
FOR EACH ROW
BEGIN
    INSERT INTO treatments_backup (id, visit_id, medication_id, eye, dosage, frequency, start_date, end_date, is_active, notes)
    VALUES (OLD.id, OLD.visit_id, OLD.medication_id, OLD.eye, OLD.dosage, OLD.frequency, OLD.start_date, OLD.end_date, OLD.is_active, OLD.notes);
END $$

-- 44. Registrar en auditoría la eliminación de un diagnóstico.
DROP TRIGGER IF EXISTS trg_ad_audit_diagnosis_delete $$
CREATE TRIGGER trg_ad_audit_diagnosis_delete
AFTER DELETE ON diagnoses
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, performed_by, changed_at)
    VALUES ('diagnoses', OLD.id, 'DELETE', JSON_OBJECT('code', OLD.code, 'name', OLD.name), 'ADMIN', NOW());
END $$

-- 45. Impedir eliminar pacientes que tengan historia clínica activa.
DROP TRIGGER IF EXISTS trg_bd_prevent_patient_delete_with_history $$
CREATE TRIGGER trg_bd_prevent_patient_delete_with_history
BEFORE DELETE ON patients
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM clinical_histories WHERE patient_id = OLD.id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integridad médico-legal: No está permitido eliminar pacientes con expediente clínico abierto.';
    END IF;
END $$

-- 46. Impedir eliminar profesionales con consultas registradas.
DROP TRIGGER IF EXISTS trg_bd_prevent_prof_delete_with_visits $$
CREATE TRIGGER trg_bd_prevent_prof_delete_with_visits
BEFORE DELETE ON healthcare_professionals
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM medical_visits WHERE professional_id = OLD.id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bloqueo referencial: El profesional posee consultas registradas; proceda a inactivarlo en su lugar.';
    END IF;
END $$

-- 47. Impedir eliminar medicamentos actualmente utilizados en tratamientos activos.
DROP TRIGGER IF EXISTS trg_bd_prevent_med_delete_active_treatment $$
CREATE TRIGGER trg_bd_prevent_med_delete_active_treatment
BEFORE DELETE ON medications
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM treatments WHERE medication_id = OLD.id AND is_active = TRUE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prescripción en curso: El medicamento forma parte de tratamientos activos en ejecución.';
    END IF;
END $$

-- 48. Registrar automáticamente la eliminación de un examen OCT.
DROP TRIGGER IF EXISTS trg_bd_oct_delete_backup $$
CREATE TRIGGER trg_bd_oct_delete_backup
BEFORE DELETE ON oct_exams
FOR EACH ROW
BEGIN
    INSERT INTO oct_exams_backup (id, visit_id, eye, rnfl_average, rnfl_superior, rnfl_inferior, cup_to_disc_ratio, interpretation, is_validated, exam_date)
    VALUES (OLD.id, OLD.visit_id, OLD.eye, OLD.rnfl_average, OLD.rnfl_superior, OLD.rnfl_inferior, OLD.cup_to_disc_ratio, OLD.interpretation, OLD.is_validated, OLD.exam_date);
    
    INSERT INTO audit_logs (table_name, record_id, action, old_values, performed_by, changed_at)
    VALUES ('oct_exams', OLD.id, 'DELETE', JSON_OBJECT('rnfl_average', OLD.rnfl_average, 'eye', OLD.eye), 'SYSTEM', NOW());
END $$

-- 49. Registrar quién eliminó un documento clínico.
DROP TRIGGER IF EXISTS trg_bd_clinical_document_delete $$
CREATE TRIGGER trg_bd_clinical_document_delete
BEFORE DELETE ON clinical_documents
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, performed_by, changed_at)
    VALUES ('clinical_documents', OLD.id, 'DELETE',
            JSON_OBJECT('title', OLD.title, 'path', OLD.file_path, 'deleted_by', IFNULL(OLD.deleted_by, 'USUARIO_ACTUAL')),
            'DOCUMENT_SYSTEM', NOW());
END $$

-- 50. Implementar un esquema completo de auditoría mediante triggers para DELETE sobre patients.
DROP TRIGGER IF EXISTS trg_ad_patients_full_audit $$
CREATE TRIGGER trg_ad_patients_full_audit
AFTER DELETE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, performed_by, changed_at)
    VALUES ('patients', OLD.id, 'DELETE',
            JSON_OBJECT('document', OLD.document_number, 'name', CONCAT(OLD.first_name, ' ', OLD.last_name), 'email', OLD.email),
            'AUDIT_CONTROLLER', NOW());
END $$

DELIMITER ;
