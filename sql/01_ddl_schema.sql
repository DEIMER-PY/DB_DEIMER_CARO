-- =============================================================================
-- PROYECTO: HISTORIAS CLÍNICAS DE OFTALMOLOGÍA Y GLAUCOMA
-- AUTOR: Deimer Caro
-- ARCHIVO: 01_ddl_schema.sql
-- DESCRIPCIÓN: Definición física DDL de todas las tablas con restricciones 4FN
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

-- 4. Catálogo de Especialidades Médicas
CREATE TABLE specialties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    CONSTRAINT uq_specialty_name UNIQUE (name)
) ENGINE=InnoDB;

-- 5. Profesionales de la Salud
CREATE TABLE healthcare_professionals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_type_id INT NOT NULL,
    document_number VARCHAR(30) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    medical_license VARCHAR(50) NOT NULL,
    specialty_id INT NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_prof_document UNIQUE (document_number),
    CONSTRAINT uq_prof_license UNIQUE (medical_license),
    CONSTRAINT uq_prof_email UNIQUE (email),
    CONSTRAINT fk_prof_doc_type FOREIGN KEY (document_type_id) 
        REFERENCES document_types(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prof_specialty FOREIGN KEY (specialty_id) 
        REFERENCES specialties(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. Pacientes (Normalizado en 3FN/BCNF)
CREATE TABLE patients (
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
    CONSTRAINT uq_patient_document UNIQUE (document_number),
    CONSTRAINT uq_patient_email UNIQUE (email),
    CONSTRAINT fk_patient_doc_type FOREIGN KEY (document_type_id) 
        REFERENCES document_types(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_patient_city FOREIGN KEY (city_id) 
        REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 7. Alergias del Paciente (Desacoplado por 4FN: Independiente de Antecedentes Familiares)
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

-- 8. Antecedentes Familiares (Desacoplado por 4FN: Independiente de Alergias)
CREATE TABLE patient_family_histories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    condition_name VARCHAR(150) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    notes TEXT NULL,
    CONSTRAINT fk_famhist_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. Antecedentes Personales (Desacoplado por 4FN)
CREATE TABLE patient_antecedents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    antecedent_type ENUM('PATOLOGICO', 'QUIRURGICO', 'TRAUMATICO', 'FARMACOLOGICO') NOT NULL DEFAULT 'PATOLOGICO',
    description TEXT NOT NULL,
    year_diagnosed YEAR NULL,
    CONSTRAINT fk_antecedents_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. Historias Clínicas (Relación 1 a 1 obligatoria con Paciente)
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

-- 11. Consultas Médicas
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

-- 12. Catálogo de Diagnósticos
CREATE TABLE diagnoses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    is_glaucoma_type BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT NULL,
    CONSTRAINT uq_diagnosis_code UNIQUE (code)
) ENGINE=InnoDB;

-- 13. Diagnósticos de la Consulta (Asociativa 2FN/3FN)
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

-- 14. Mediciones de Presión Intraocular (PIO)
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

-- 15. Exámenes de Paquimetría Corneal (CCT)
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

-- 16. Exámenes de Gonioscopía
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

-- 17. Exámenes de Tomografía de Coherencia Óptica (OCT)
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

-- 18. Exámenes de Campo Visual (Campimetría)
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

-- 19. Catálogo de Medicamentos
CREATE TABLE medications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    generic_name VARCHAR(150) NOT NULL,
    concentration VARCHAR(50) NOT NULL,
    presentation VARCHAR(100) NOT NULL DEFAULT 'Frasco gotero x 2.5 ml',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_medication_name UNIQUE (name)
) ENGINE=InnoDB;

-- 20. Tratamientos Médicos Prescritos
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

-- 21. Procedimientos y Cirugías
CREATE TABLE procedures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    eye ENUM('OD', 'OI', 'AMBOS') NOT NULL,
    procedure_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    complications TEXT NULL,
    results TEXT NULL,
    CONSTRAINT fk_procedure_visit FOREIGN KEY (visit_id) 
        REFERENCES medical_visits(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 22. Registro Principal de Glaucoma (1 a 1 por Paciente con Glaucoma)
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

-- 23. Controles Evolutivos de Glaucoma
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

-- 24. Documentos Clínicos y Adjuntos
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

-- 25. Bitácora General de Auditoría
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
CREATE TABLE patients_backup LIKE patients;
CREATE TABLE medical_visits_backup LIKE medical_visits;
CREATE TABLE treatments_backup LIKE treatments;
CREATE TABLE oct_exams_backup LIKE oct_exams;

-- Índices de Rendimiento
CREATE INDEX idx_patients_name ON patients(last_name, first_name);
CREATE INDEX idx_visits_date ON medical_visits(visit_date);
CREATE INDEX idx_iop_eye_pressure ON intraocular_pressures(eye, pressure);
CREATE INDEX idx_oct_exam_date ON oct_exams(exam_date);
CREATE INDEX idx_vf_exam_date ON visual_field_exams(exam_date);
CREATE INDEX idx_treatments_active ON treatments(is_active);
CREATE INDEX idx_audit_table_date ON audit_logs(table_name, changed_at);

SELECT 'Esquema físico DDL creado exitosamente con 25 tablas relacionales e índices' AS estado;
