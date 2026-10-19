-- =============================================================================
-- PROYECTO: HISTORIAS CLÍNICAS DE OFTALMOLOGÍA Y GLAUCOMA
-- AUTOR: Deimer Caro
-- ARCHIVO: 01_ddl_schema.sql
-- DESCRIPCIÓN: Definición física DDL super-normalizada (4FN/5FN) con personas, citas y exámenes especializados
-- =============================================================================

USE oftalmologia_glaucoma_db;

-- 1. Catálogo de Departamentos
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_department_name UNIQUE (name)
) ENGINE=InnoDB;

-- 2. Catálogo de Municipios / Ciudades
CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_cities_department FOREIGN KEY (department_id) 
        REFERENCES departments(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_city_department UNIQUE (department_id, name)
) ENGINE=InnoDB;

-- 3. Tipos de Documento de Identificación
CREATE TABLE document_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_document_type_code UNIQUE (code)
) ENGINE=InnoDB;

-- 4. Personas Naturales (Super-tipo generalizador 3FN/BCNF)
CREATE TABLE persons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_type_id INT NOT NULL,
    document_number VARCHAR(30) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('M', 'F', 'OTRO') NOT NULL,
    city_id INT NOT NULL,
    address VARCHAR(255) NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(150) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_person_document UNIQUE (document_number),
    CONSTRAINT uq_person_email UNIQUE (email),
    CONSTRAINT fk_person_doc_type FOREIGN KEY (document_type_id) 
        REFERENCES document_types(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_person_city FOREIGN KEY (city_id) 
        REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. Catálogo de Especialidades Médicas
CREATE TABLE specialties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    CONSTRAINT uq_specialty_name UNIQUE (name)
) ENGINE=InnoDB;

-- 6. Profesionales de la Salud (Sub-tipo de persons)
CREATE TABLE healthcare_professionals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    person_id BIGINT NOT NULL,
    medical_license VARCHAR(50) NOT NULL,
    specialty_id INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_prof_person UNIQUE (person_id),
    CONSTRAINT uq_prof_license UNIQUE (medical_license),
    CONSTRAINT fk_prof_person FOREIGN KEY (person_id) 
        REFERENCES persons(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prof_specialty FOREIGN KEY (specialty_id) 
        REFERENCES specialties(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 7. Pacientes (Sub-tipo clínico de persons normalizado en 4FN)
CREATE TABLE patients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    person_id BIGINT NOT NULL,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NULL,
    health_insurance VARCHAR(100) NULL,
    affiliation_type ENUM('COTIZANTE', 'BENEFICIARIO', 'PARTICULAR', 'SUBSIDIADO') NOT NULL DEFAULT 'COTIZANTE',
    occupation VARCHAR(100) NULL,
    emergency_contact_name VARCHAR(100) NULL,
    emergency_contact_phone VARCHAR(30) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_patient_person UNIQUE (person_id),
    CONSTRAINT fk_patient_person FOREIGN KEY (person_id) 
        REFERENCES persons(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. Alergias del Paciente (Desacoplado por 4FN)
CREATE TABLE patient_allergies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    allergen VARCHAR(150) NOT NULL,
    reaction VARCHAR(255) NULL,
    severity ENUM('LEVE', 'MODERADA', 'SEVERA') NOT NULL DEFAULT 'MODERADA',
    CONSTRAINT fk_allergies_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_patient_allergen UNIQUE (patient_id, allergen)
) ENGINE=InnoDB;

-- 9. Antecedentes Familiares (Desacoplado por 4FN)
CREATE TABLE patient_family_histories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    condition_name VARCHAR(150) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    notes TEXT NULL,
    CONSTRAINT fk_famhist_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. Antecedentes Personales (Desacoplado por 4FN)
CREATE TABLE patient_antecedents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    antecedent_type ENUM('PATOLOGICO', 'QUIRURGICO', 'TRAUMATICO', 'FARMACOLOGICO') NOT NULL DEFAULT 'PATOLOGICO',
    description TEXT NOT NULL,
    year_diagnosed YEAR NULL,
    CONSTRAINT fk_antecedents_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11. Factores de Riesgo Específicos de Glaucoma (Desacoplado por 4FN)
CREATE TABLE glaucoma_risk_factors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    risk_factor ENUM('CCT_DELGADO', 'MIOPIA_ALTA', 'ANTECEDENTE_FAMILIAR_1ER_GRADO', 'HIPOTENSION_NOCTURNA', 'VASOESPASMO_MIGRAÑA', 'HEMORRAGIA_DISCO', 'SINDROME_PSEUDOEXFOLIATIVO', 'SINDROME_DISPERSION_PIGMENTARIA') NOT NULL,
    notes VARCHAR(255) NULL,
    CONSTRAINT fk_grisk_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_patient_risk_factor UNIQUE (patient_id, risk_factor)
) ENGINE=InnoDB;

-- 12. Historias Clínicas (Relación 1 a 1 obligatoria con Paciente)
CREATE TABLE clinical_histories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    history_number VARCHAR(50) NOT NULL,
    status ENUM('ACTIVA', 'ARCHIVADA', 'INACTIVA') NOT NULL DEFAULT 'ACTIVA',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_history_patient UNIQUE (patient_id),
    CONSTRAINT uq_history_number UNIQUE (history_number),
    CONSTRAINT fk_history_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 13. Agendamiento de Citas Clínicas
CREATE TABLE appointments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    professional_id BIGINT NOT NULL,
    appointment_date DATETIME NOT NULL,
    appointment_type ENUM('PRIMERA_VEZ', 'CONTROL_GLAUCOMA', 'POST_QUIRURGICO', 'LECTURA_EXAMENES', 'URGENCIA') NOT NULL DEFAULT 'CONTROL_GLAUCOMA',
    status ENUM('PROGRAMADA', 'CONFIRMADA', 'ATENDIDA', 'CANCELADA', 'NO_ASISTIO') NOT NULL DEFAULT 'PROGRAMADA',
    reason VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_app_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_app_professional FOREIGN KEY (professional_id) 
        REFERENCES healthcare_professionals(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 14. Consultas Médicas
CREATE TABLE medical_visits (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    clinical_history_id BIGINT NOT NULL,
    professional_id BIGINT NOT NULL,
    visit_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    symptoms TEXT NULL,
    assessment TEXT NOT NULL,
    plan TEXT NOT NULL,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_visit_history FOREIGN KEY (clinical_history_id) 
        REFERENCES clinical_histories(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_visit_professional FOREIGN KEY (professional_id) 
        REFERENCES healthcare_professionals(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 15. Catálogo de Diagnósticos
CREATE TABLE diagnoses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    is_glaucoma_type BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT NULL,
    CONSTRAINT uq_diagnosis_code UNIQUE (code)
) ENGINE=InnoDB;

-- 16. Diagnósticos de la Consulta (Asociativa 2FN/3FN)
CREATE TABLE visit_diagnoses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    diagnosis_id INT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    notes VARCHAR(255) NULL,
    CONSTRAINT uq_visit_diag UNIQUE (visit_id, diagnosis_id),
    CONSTRAINT fk_vdiag_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_vdiag_diag FOREIGN KEY (diagnosis_id) 
        REFERENCES diagnoses(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 17. Exámenes de Agudeza Visual y Refracción
CREATE TABLE visual_acuity_exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    sphere DECIMAL(4,2) NULL,
    cylinder DECIMAL(4,2) NULL,
    axis INT NULL,
    uncorrected_va VARCHAR(20) NOT NULL,
    corrected_va VARCHAR(20) NOT NULL,
    pinhole_va VARCHAR(20) NULL,
    exam_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_va_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT chk_va_axis CHECK (axis IS NULL OR (axis >= 0 AND axis <= 180)),
    CONSTRAINT fk_va_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 18. Mediciones de Presión Intraocular (PIO)
CREATE TABLE intraocular_pressures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    pressure DECIMAL(5,2) NOT NULL,
    measurement_time TIME NULL,
    method ENUM('GOLDMANN', 'AIRE', 'PERKINS', 'ICARE') NOT NULL DEFAULT 'GOLDMANN',
    notes VARCHAR(255) NULL,
    CONSTRAINT chk_iop_pressure CHECK (pressure > 0.00 AND pressure <= 80.00),
    CONSTRAINT chk_iop_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT fk_iop_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 19. Exámenes de Paquimetría Corneal (CCT)
CREATE TABLE pachymetry_exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    corneal_thickness DECIMAL(6,2) NOT NULL,
    method VARCHAR(50) NOT NULL DEFAULT 'ULTRASONICA',
    exam_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pachy_thickness CHECK (corneal_thickness > 0.00 AND corneal_thickness <= 1000.00),
    CONSTRAINT chk_pachy_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT fk_pachy_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 20. Exámenes de Biomicroscopía con Lámpara de Hendidura
CREATE TABLE biomicroscopy_exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    cornea_status VARCHAR(100) NOT NULL DEFAULT 'TRANSPARENTE',
    anterior_chamber_depth ENUM('VAN_HERICK_I', 'VAN_HERICK_II', 'VAN_HERICK_III', 'VAN_HERICK_IV') NOT NULL DEFAULT 'VAN_HERICK_IV',
    iris_status VARCHAR(100) NOT NULL DEFAULT 'NORMAL',
    lens_status ENUM('TRANSPARENTE', 'CATARATA_NUCLEAR', 'CATARATA_CORTICAL', 'CATARATA_SUBCAPSULAR', 'PSEUDOFAQUICO', 'AFAQUICO') NOT NULL DEFAULT 'TRANSPARENTE',
    pseudoexfoliation_present BOOLEAN NOT NULL DEFAULT FALSE,
    pigment_dispersion_present BOOLEAN NOT NULL DEFAULT FALSE,
    exam_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_biomicro_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT fk_biomicro_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 21. Exámenes de Gonioscopía
CREATE TABLE gonioscopy_exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    angle_grade ENUM('GRADO 0', 'GRADO I', 'GRADO II', 'GRADO III', 'GRADO IV') NOT NULL,
    pigmentation ENUM('LEVE', 'MODERADA', 'SEVERA') NOT NULL DEFAULT 'LEVE',
    findings TEXT NULL,
    exam_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_gonio_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT fk_gonio_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 22. Exámenes de Tomografía de Coherencia Óptica (OCT)
CREATE TABLE oct_exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    rnfl_average DECIMAL(6,2) NOT NULL,
    rnfl_superior DECIMAL(6,2) NULL,
    rnfl_inferior DECIMAL(6,2) NULL,
    cup_to_disc_ratio DECIMAL(4,2) NULL,
    interpretation TEXT NULL,
    is_validated BOOLEAN NOT NULL DEFAULT FALSE,
    exam_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_oct_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT chk_oct_rnfl CHECK (rnfl_average >= 0.00 AND rnfl_average <= 300.00),
    CONSTRAINT chk_oct_cup_disc CHECK (cup_to_disc_ratio IS NULL OR (cup_to_disc_ratio >= 0.00 AND cup_to_disc_ratio <= 1.00)),
    CONSTRAINT fk_oct_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 23. Exámenes de Campo Visual (Campimetría)
CREATE TABLE visual_field_exams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    eye ENUM('OD', 'OI') NOT NULL,
    strategy VARCHAR(50) NOT NULL DEFAULT 'SITA-Standard 24-2',
    mean_deviation_md DECIMAL(6,2) NOT NULL,
    pattern_std_deviation_psd DECIMAL(6,2) NOT NULL,
    visual_field_index_vfi DECIMAL(5,2) NOT NULL,
    false_positives_pct DECIMAL(5,2) NULL,
    false_negatives_pct DECIMAL(5,2) NULL,
    reliability ENUM('CONFIABLE', 'NO CONFIABLE') NOT NULL DEFAULT 'CONFIABLE',
    interpretation TEXT NULL,
    exam_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_vf_eye CHECK (eye IN ('OD', 'OI')),
    CONSTRAINT chk_vf_vfi CHECK (visual_field_index_vfi >= 0.00 AND visual_field_index_vfi <= 100.00),
    CONSTRAINT fk_vf_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 24. Catálogo de Clases Farmacológicas de Medicamentos (3FN)
CREATE TABLE medication_classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    mechanism_of_action TEXT NULL,
    CONSTRAINT uq_med_class_name UNIQUE (name)
) ENGINE=InnoDB;

-- 25. Catálogo de Medicamentos Hipotensores
CREATE TABLE medications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    medication_class_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    generic_name VARCHAR(150) NOT NULL,
    concentration VARCHAR(50) NOT NULL,
    presentation VARCHAR(100) NOT NULL DEFAULT 'Frasco gotero x 2.5 ml',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_medication_name UNIQUE (name),
    CONSTRAINT fk_med_class FOREIGN KEY (medication_class_id) 
        REFERENCES medication_classes(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 26. Tratamientos Médicos Prescritos
CREATE TABLE treatments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    medication_id INT NOT NULL,
    eye ENUM('OD', 'OI', 'AMBOS') NOT NULL DEFAULT 'AMBOS',
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT NULL,
    CONSTRAINT chk_treatment_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_treatment_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_treatment_medication FOREIGN KEY (medication_id) 
        REFERENCES medications(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 27. Catálogo de Tipos de Procedimientos y Cirugías (3FN)
CREATE TABLE procedure_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(150) NOT NULL,
    category ENUM('LASER', 'QUIRURGICO', 'DIAGNOSTICO') NOT NULL DEFAULT 'QUIRURGICO',
    description TEXT NULL,
    CONSTRAINT uq_procedure_type_code UNIQUE (code)
) ENGINE=InnoDB;

-- 28. Procedimientos y Cirugías Ejecutados
CREATE TABLE procedures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    procedure_type_id INT NOT NULL,
    eye ENUM('OD', 'OI', 'AMBOS') NOT NULL,
    procedure_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    complications TEXT NULL,
    results TEXT NULL,
    CONSTRAINT fk_procedure_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_procedure_type FOREIGN KEY (procedure_type_id) 
        REFERENCES procedure_types(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 29. Registro Principal de Glaucoma (1 a 1 por Paciente con Glaucoma)
CREATE TABLE glaucoma_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    target_iop_od DECIMAL(5,2) NOT NULL,
    target_iop_oi DECIMAL(5,2) NOT NULL,
    clinical_stage ENUM('SOSPECHA', 'INICIAL', 'MODERADO', 'AVANZADO', 'TERMINAL') NOT NULL DEFAULT 'SOSPECHA',
    diagnosis_date DATE NOT NULL,
    notes TEXT NULL,
    CONSTRAINT uq_glaucoma_patient UNIQUE (patient_id),
    CONSTRAINT chk_target_iop_od CHECK (target_iop_od > 0.00 AND target_iop_od <= 50.00),
    CONSTRAINT chk_target_iop_oi CHECK (target_iop_oi > 0.00 AND target_iop_oi <= 50.00),
    CONSTRAINT fk_grecord_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 30. Controles Evolutivos de Glaucoma
CREATE TABLE glaucoma_controls (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    glaucoma_record_id BIGINT NOT NULL,
    visit_id BIGINT NOT NULL,
    control_date DATE NOT NULL,
    is_progression_detected BOOLEAN NOT NULL DEFAULT FALSE,
    adherence_score ENUM('EXCELENTE', 'BUENA', 'REGULAR', 'MALA') NOT NULL DEFAULT 'BUENA',
    notes TEXT NULL,
    CONSTRAINT fk_gcontrol_record FOREIGN KEY (glaucoma_record_id) 
        REFERENCES glaucoma_records(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_gcontrol_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 31. Documentos Clínicos y Adjuntos
CREATE TABLE clinical_documents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    clinical_history_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_by VARCHAR(100) NULL,
    CONSTRAINT fk_doc_history FOREIGN KEY (clinical_history_id) 
        REFERENCES clinical_histories(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 32. Bitácora General de Auditoría
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE', 'ALERT') NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    performed_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tablas de respaldo histórico para eliminaciones auditadas
CREATE TABLE persons_backup LIKE persons;
CREATE TABLE patients_backup LIKE patients;
CREATE TABLE medical_visits_backup LIKE medical_visits;
CREATE TABLE treatments_backup LIKE treatments;
CREATE TABLE oct_exams_backup LIKE oct_exams;

-- Índices de Rendimiento
CREATE INDEX idx_persons_name ON persons(last_name, first_name);
CREATE INDEX idx_visits_date ON medical_visits(visit_date);
CREATE INDEX idx_app_date ON appointments(appointment_date);
CREATE INDEX idx_iop_eye_pressure ON intraocular_pressures(eye, pressure);
CREATE INDEX idx_oct_exam_date ON oct_exams(exam_date);
CREATE INDEX idx_vf_exam_date ON visual_field_exams(exam_date);
CREATE INDEX idx_treatments_active ON treatments(is_active);
CREATE INDEX idx_audit_table_date ON audit_logs(table_name, changed_at);

SELECT 'Esquema físico DDL creado exitosamente con 32 tablas relacionales e índices' AS estado;
