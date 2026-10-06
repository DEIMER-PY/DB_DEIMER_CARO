-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 02_dml_seed_data.sql
-- DESCRIPCIÓN: Inserción de datos semilla clínicamente coherentes y exhaustivos.
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE audit_logs;
TRUNCATE TABLE clinical_documents;
TRUNCATE TABLE glaucoma_controls;
TRUNCATE TABLE glaucoma_records;
TRUNCATE TABLE procedures;
TRUNCATE TABLE treatments;
TRUNCATE TABLE medications;
TRUNCATE TABLE visual_field_exams;
TRUNCATE TABLE oct_exams;
TRUNCATE TABLE gonioscopy_exams;
TRUNCATE TABLE pachymetry_exams;
TRUNCATE TABLE intraocular_pressures;
TRUNCATE TABLE visit_diagnoses;
TRUNCATE TABLE diagnoses;
TRUNCATE TABLE medical_visits;
TRUNCATE TABLE clinical_histories;
TRUNCATE TABLE patient_antecedents;
TRUNCATE TABLE patient_family_histories;
TRUNCATE TABLE patient_allergies;
TRUNCATE TABLE patients;
TRUNCATE TABLE healthcare_professionals;
TRUNCATE TABLE specialties;
TRUNCATE TABLE document_types;
TRUNCATE TABLE cities;
TRUNCATE TABLE departments;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Departamentos
INSERT INTO departments (id, name) VALUES
(1, 'Santander'),
(2, 'Antioquia'),
(3, 'Cundinamarca'),
(4, 'Valle del Cauca'),
(5, 'Atlántico');

-- 2. Ciudades
INSERT INTO cities (id, department_id, name) VALUES
(1, 1, 'Bucaramanga'),
(2, 1, 'Floridablanca'),
(3, 1, 'Piedecuesta'),
(4, 1, 'Girón'),
(5, 2, 'Medellín'),
(6, 2, 'Envigado'),
(7, 3, 'Bogotá D.C.'),
(8, 4, 'Cali'),
(9, 5, 'Barranquilla');

-- 3. Tipos de Documento
INSERT INTO document_types (id, code, name) VALUES
(1, 'CC', 'Cédula de Ciudadanía'),
(2, 'TI', 'Tarjeta de Identidad'),
(3, 'CE', 'Cédula de Extranjería'),
(4, 'PAS', 'Pasaporte'),
(5, 'RC', 'Registro Civil');

-- 4. Especialidades
INSERT INTO specialties (id, name, description) VALUES
(1, 'Oftalmología', 'Atención médica y quirúrgica general de los ojos'),
(2, 'Glaucoma', 'Subespecialidad dedicada al diagnóstico y manejo del glaucoma y neuropatías ópticas'),
(3, 'Córnea y Segmento Anterior', 'Especialista en superficie ocular, trasplante corneal y cirugía refractiva'),
(4, 'Retina y Vítreo', 'Diagnóstico y cirugía de patologías de polo posterior'),
(5, 'Neuroftalmología', 'Trastornos visuales relacionados con el sistema nervioso central'),
(6, 'Optometría', 'Exámenes refractivos, agudeza visual y adaptación de lentes');

-- 5. Profesionales de la Salud
INSERT INTO healthcare_professionals (id, document_type_id, document_number, first_name, last_name, medical_license, specialty_id, email, phone) VALUES
(1, 1, '1098765432', 'Deimer', 'Caro', 'MP-OFT-2026-001', 2, 'deimer.caro@oftalmologia.com', '3157894512'),
(2, 1, '1095432187', 'Roberto', 'Silva Gómez', 'MP-OFT-2018-044', 1, 'roberto.silva@oftalmologia.com', '3104561234'),
(3, 1, '63456789', 'Elena', 'Vega Rincón', 'MP-GLA-2015-089', 2, 'elena.vega@glaucomaclinic.com', '3189876543'),
(4, 1, '1098712345', 'Carlos', 'Mendoza Duarte', 'MP-COR-2020-112', 3, 'carlos.mendoza@oftalmologia.com', '3123456789'),
(5, 1, '37890123', 'Sofía', 'Gómez Serrano', 'MP-OFT-2016-077', 1, 'sofia.gomez@oftalmologia.com', '3161239874'),
(6, 1, '1098654321', 'Javier', 'Hernández Plata', 'MP-RET-2019-204', 4, 'javier.hernandez@retinaclinic.com', '3176543210');

-- 6. Pacientes (Diversidad de edades, apellidos, correos y prefijos de documento)
INSERT INTO patients (id, document_type_id, document_number, first_name, last_name, birth_date, gender, city_id, address, phone, email) VALUES
(1, 1, '1098123456', 'Juan Carlos', 'Gómez Pérez', '1958-03-15', 'M', 1, 'Cra 27 # 45-12 Cabecera', '3151112233', 'juan.gomez@gmail.com'),
(2, 1, '1098234567', 'María Fernanda', 'Rodríguez López', '1964-07-22', 'F', 2, 'Cll 30 # 25-10 Cañaveral', '3162223344', 'maria.rodriguez@gmail.com'),
(3, 1, '91234567', 'Carlos Alberto', 'Gómez Mendoza', '1952-11-05', 'M', 1, 'Cra 33 # 52-20 San Pío', '3173334455', 'carlos.gomez@hotmail.com'),
(4, 1, '1095345678', 'Ana Milena', 'Martínez Silva', '1975-01-30', 'F', 4, 'Cll 12 # 15-40 El Poblado', '3184445566', 'ana.martinez@gmail.com'),
(5, 1, '63456123', 'Esperanza', 'Gómez Castro', '1948-09-18', 'F', 2, 'Cra 12 # 8-30 Lagos II', '3105556677', NULL),
(6, 1, '1098456789', 'Pedro José', 'Sánchez Rueda', '1982-05-14', 'M', 3, 'Cll 5 # 8-12 San Cristóbal', '3116667788', 'pedro.sanchez@yahoo.com'),
(7, 1, '1098567890', 'Diana Marcela', 'Torres Vargas', '1990-12-03', 'F', 1, 'Cra 19 # 36-25 Centro', '3127778899', 'diana.torres@gmail.com'),
(8, 1, '13890123', 'Héctor Fabio', 'Ramírez Ortiz', '1950-04-25', 'M', 3, 'Cll 10 # 4-15 La Colina', '3138889900', NULL),
(9, 1, '1096678901', 'Lucía Andrea', 'Navarro Plata', '1988-08-19', 'F', 5, 'Cra 43A # 1-50 El Poblado', '3149990011', 'lucia.navarro@gmail.com'),
(10, 1, '1098789012', 'Fernando', 'Álvarez Niño', '1961-02-10', 'M', 1, 'Cll 48 # 28-35 Sotomayor', '3150001122', 'fernando.alvarez@outlook.com'),
(11, 2, '1098890123', 'Camilo Andrés', 'Vargas Gómez', '2009-06-12', 'M', 1, 'Cra 21 # 37-14 Antonia Santos', '3161112244', 'camilo.vargas@gmail.com'),
(12, 1, '1098901234', 'Patricia', 'Herrera Díaz', '1970-10-28', 'F', 6, 'Cll 38Sur # 42-10 Zuñiga', '3172223355', 'patricia.herrera@gmail.com'),
(13, 1, '52123456', 'Rosa María', 'Villamizar León', '1945-12-15', 'F', 7, 'Cra 15 # 85-30 Chicó', '3183334466', NULL),
(14, 1, '1099012345', 'Andrés Felipe', 'García Jaimes', '1995-04-02', 'M', 1, 'Cra 35 # 48-18 Provenza', '3194445577', 'andres.garcia@gmail.com'),
(15, 3, 'CE987654', 'John David', 'Smith Miller', '1968-07-04', 'M', 7, 'Cll 93 # 11-40 Parque 93', '3105556688', 'john.smith@expat.com');

-- 7. Alergias del Paciente (Normalización 4FN)
INSERT INTO patient_allergies (id, patient_id, allergen, reaction, severity) VALUES
(1, 1, 'Penicilina', 'Rash cutáneo y prurito intenso', 'MODERADA'),
(2, 1, 'Sulfas', 'Edema facial y urticaria', 'SEVERA'),
(3, 2, 'Látex', 'Dermatitis por contacto', 'LEVE'),
(4, 3, 'Dipirona', 'Broncoespasmo', 'SEVERA'),
(5, 5, 'Polen', 'Rinitis alérgica y conjuntivitis', 'LEVE'),
(6, 8, 'Betabloqueadores tópicos', 'Bradicardia sintomática y broncoespasmo', 'SEVERA'),
(7, 10, 'AINEs', 'Gastritis erosiva y angioedema', 'MODERADA'),
(8, 13, 'Penicilina', 'Choque anafiláctico previo', 'SEVERA');

-- 8. Antecedentes Familiares (Normalización 4FN - Independiente de Alergias)
INSERT INTO patient_family_histories (id, patient_id, condition_name, relationship, notes) VALUES
(1, 1, 'Glaucoma Primario de Ángulo Abierto', 'Madre', 'Pérdida severa de campo visual en ojo izquierdo'),
(2, 1, 'Diabetes Mellitus Tipo 2', 'Padre', 'Diagnosticado a los 50 años'),
(3, 2, 'Glaucoma Neovascular', 'Hermano', 'Secundario a retinopatía diabética'),
(4, 3, 'Glaucoma de Ángulo Cerrado', 'Madre', 'Requirió iridotomía periférica bilateral'),
(5, 5, 'Ceguera bilateral por Glaucoma', 'Abuelo materno', 'Diagnóstico tardío'),
(6, 8, 'Hipertensión Arterial', 'Padre', 'Infarto agudo de miocardio a los 62 años'),
(7, 10, 'Glaucoma Primario de Ángulo Abierto', 'Tía paterna', 'Tratamiento crónico con análogos de prostaglandinas'),
(8, 12, 'Desprendimiento de Retina', 'Hermano', 'Miopía alta asociada');

-- 9. Antecedentes Personales (Normalización 4FN)
INSERT INTO patient_antecedents (id, patient_id, antecedent_type, description, year_diagnosed) VALUES
(1, 1, 'PATOLOGICO', 'Hipertensión Arterial Primaria controlada con Losartán 50mg', 2012),
(2, 1, 'QUIRURGICO', 'Apendicectomía por laparoscopia sin complicaciones', 2005),
(3, 2, 'PATOLOGICO', 'Diabetes Mellitus Tipo 2 no insulinodependiente', 2015),
(4, 3, 'FARMACOLOGICO', 'Uso crónico de corticoides tópicos por dermatitis palpebral', 2021),
(5, 5, 'PATOLOGICO', 'Miopía Magna (-6.50 D ojo derecho, -7.00 D ojo izquierdo)', 1970),
(6, 6, 'TRAUMATICO', 'Traumatismo contuso ojo derecho con pelota de tenis', 2023),
(7, 8, 'PATOLOGICO', 'Asma bronquial intermitente', 1980),
(8, 10, 'PATOLOGICO', 'Hipertensión ocular detectada en tamizaje de optometría', 2024),
(9, 13, 'QUIRURGICO', 'Facoemulsificación con lente intraocular bilateral', 2019);

-- 10. Historias Clínicas (1 a 1 con Pacientes)
INSERT INTO clinical_histories (id, patient_id, history_number, status, created_at) VALUES
(1, 1, 'HC-2026-0001', 'ACTIVA', '2025-01-15 08:30:00'),
(2, 2, 'HC-2026-0002', 'ACTIVA', '2025-02-10 09:15:00'),
(3, 3, 'HC-2026-0003', 'ACTIVA', '2025-03-05 10:00:00'),
(4, 4, 'HC-2026-0004', 'ACTIVA', '2025-04-12 11:30:00'),
(5, 5, 'HC-2026-0005', 'ACTIVA', '2025-05-20 14:00:00'),
(6, 6, 'HC-2026-0006', 'ACTIVA', '2025-06-18 15:30:00'),
(7, 7, 'HC-2026-0007', 'ACTIVA', '2025-07-22 08:00:00'),
(8, 8, 'HC-2026-0008', 'ACTIVA', '2025-08-14 09:45:00'),
(9, 9, 'HC-2026-0009', 'ACTIVA', '2025-09-09 10:30:00'),
(10, 10, 'HC-2026-0010', 'ACTIVA', '2025-10-17 11:15:00'),
(11, 11, 'HC-2026-0011', 'ACTIVA', '2025-11-25 14:45:00'),
(12, 12, 'HC-2026-0012', 'ACTIVA', '2025-12-05 16:00:00'),
(13, 13, 'HC-2026-0013', 'ACTIVA', '2026-01-08 08:30:00'),
(14, 14, 'HC-2026-0014', 'ACTIVA', '2026-01-20 10:00:00'),
(15, 15, 'HC-2026-0015', 'ACTIVA', '2026-02-02 11:30:00');

-- 11. Consultas Médicas (Años 2025 y 2026, diversos meses)
INSERT INTO medical_visits (id, clinical_history_id, professional_id, visit_date, reason, symptoms, assessment, plan, is_closed) VALUES
(1, 1, 1, '2026-01-10 09:00:00', 'Control periódico de glaucoma y ajuste de medicación', 'Visión borrosa ocasional en ojo derecho, halos leves', 'Glaucoma primario de ángulo abierto moderado bilateral con PIO fuera de meta', 'Ajustar análogo de prostaglandina y solicitar campo visual de control', TRUE),
(2, 1, 1, '2026-03-12 10:30:00', 'Seguimiento post-ajuste farmacológico', 'Asintomático, buena tolerancia a colirios', 'Presión intraocular dentro de rango meta terapéutico', 'Continuar tratamiento actual y control en 3 meses', TRUE),
(3, 2, 3, '2026-01-15 11:00:00', 'Evaluación inicial por sospecha de hipertensión ocular', 'Cefalea frontal leve vespertina', 'PIO elevada bilateralmente sin daño glaucomatoso evidente en fondo de ojo', 'Ordenar paquimetría y gonioscopía', TRUE),
(4, 2, 3, '2026-02-18 14:30:00', 'Revisión de exámenes diagnósticos especializados', 'Sin cambios en sintomatología', 'Córneas gruesas que sobrestiman PIO; hipertensión ocular confirmada', 'Iniciar monoterapia hipotensora y vigilar', TRUE),
(5, 3, 1, '2026-02-05 08:30:00', 'Urgencia: dolor ocular agudo ojo derecho', 'Dolor intenso hemicraneano, náuseas, visión en halos', 'Glaucoma agudo de ángulo cerrado ojo derecho con PIO 48 mmHg', 'Manejo hipotensor endovenoso inmediato e iridotomía láser de urgencia', TRUE),
(6, 3, 1, '2026-02-06 09:00:00', 'Control post-procedimiento iridotomía periférica', 'Alivio del dolor, visión recuperando gradualmente', 'Ángulo abierto en sector iridotomizado, PIO controlada en 16 mmHg', 'Gotas antiinflamatorias y control profiláctico ojo izquierdo', TRUE),
(7, 4, 2, '2026-02-20 15:00:00', 'Examen rutinario de oftalmología general', 'Dificultad para lectura cercana y fatiga visual', 'Presbicia y leve ojo seco evaporativo', 'Prescripción óptica y lágrimas artificiales', TRUE),
(8, 5, 1, '2026-01-25 10:00:00', 'Control semestral de glaucoma avanzado', 'Pérdida notable de visión periférica bilateral', 'Glaucoma crónico en estadio severo con excavación 0.85 bilateral', 'Tratamiento combinado triple y valorar cirugía filtrante', TRUE),
(9, 5, 1, '2026-03-05 11:30:00', 'Evaluación prequirúrgica para trabeculectomía', 'Estable dentro de su limitación campimétrica', 'Candidata idónea para trabeculectomía ojo derecho', 'Programar cirugía y solicitar exámenes preoperatorios', TRUE),
(10, 6, 4, '2026-02-10 16:00:00', 'Control por trauma ocular previo', 'Visión estable, sin dolor', 'Sin evidencia de recesión angular traumática', 'Alta por trauma y control anual', TRUE),
(11, 7, 5, '2026-03-01 08:30:00', 'Consulta por prurito y secreción matutina', 'Ojo rojo bilateral y sensación de cuerpo extraño', 'Conjuntivitis alérgica estacional activa', 'Antihistamínico tópico y compresas frías', TRUE),
(12, 8, 3, '2026-01-18 09:30:00', 'Control de glaucoma primario con contraindicación a betabloqueadores', 'Tolerancia adecuada a inhibidor de anhidrasa carbónica', 'PIO en meta con brimonidina y dorzolamida', 'Mantener régimen y cita en 4 meses', TRUE),
(13, 9, 2, '2025-11-12 14:00:00', 'Valoración de agudeza visual y fondo de ojo', 'Miodesopsias esporádicas', 'Vítreo transparente, retina aplicada 360 grados', 'Educación en signos de alarma', TRUE),
(14, 10, 1, '2026-02-28 10:00:00', 'Remisión por excavación papilar sospechosa 0.7', 'Asintomático general', 'Sospecha de glaucoma primario normotensional', 'Solicitar OCT de nervio óptico y paquimetría', TRUE),
(15, 11, 6, '2026-03-15 15:30:00', 'Examen optométrico para certificado escolar', 'Baja agudeza visual de lejos', 'Miopía simple escolar bilateral', 'Prescripción de lentes monofocales', TRUE),
(16, 12, 1, '2026-01-30 11:00:00', 'Control anual de glaucoma de ángulo abierto', 'Sin quejas visuales agudas', 'Enfermedad estable sin progresión detectada', 'Continuar con Latanoprost nocturno', TRUE),
(17, 13, 2, '2026-02-15 08:30:00', 'Seguimiento postquirúrgico de facoemulsificación', 'Excelente recuperación visual', 'Pseudofaquia bilateral bien centrada, PIO normal', 'Control anual preventivo', TRUE),
(18, 14, 5, '2026-03-20 16:30:00', 'Consulta oftalmológica general', 'Cansancio ocular tras uso prolongado de pantallas', 'Astenopía acomodativa y queratitis punctata leve', 'Higiene visual y lubricante ocular', FALSE),
(19, 15, 3, '2026-03-25 09:00:00', 'Chequeo especializado por antecedentes familiares de ceguera', 'Preocupación por pérdida visual en su familia', 'Examen basal normal, PIO limítrofe 21 mmHg OD', 'Seguimiento preventivo con curva de PIO', FALSE);

-- 12. Catálogo de Diagnósticos
INSERT INTO diagnoses (id, code, name, is_glaucoma_type, description) VALUES
(1, 'H40.1', 'Glaucoma primario de ángulo abierto', TRUE, 'Neuropatía óptica progresiva con ángulo iridocorneal abierto'),
(2, 'H40.2', 'Glaucoma primario de ángulo cerrado', TRUE, 'Aumento rápido o crónico de PIO por aposición o sinequias del iris'),
(3, 'H40.0', 'Sospecha de glaucoma e Hipertensión Ocular', TRUE, 'PIO persistentemente > 21 mmHg sin daño campimétrico evidente'),
(4, 'H40.5', 'Glaucoma secundario a otros trastornos oculares', TRUE, 'Glaucoma inducido por traumatismo, uveítis o neovascularización'),
(5, 'H25.0', 'Catarata senil incipiente', FALSE, 'Opacificación del cristalino asociada a la edad'),
(6, 'H52.1', 'Miopía', FALSE, 'Error de refracción donde los rayos convergen delante de la retina'),
(7, 'H52.2', 'Astigmatismo', FALSE, 'Curvatura corneal asimétrica'),
(8, 'H52.4', 'Presbicia', FALSE, 'Pérdida fisiológica de la acomodación visual cercana'),
(9, 'H10.1', 'Conjuntivitis alérgica aguda', FALSE, 'Inflamación de la conjuntiva mediada por alérgenos'),
(10, 'H04.1', 'Síndrome de disfunción lagrimal (Ojo seco)', FALSE, 'Deficiencia cualitativa o cuantitativa de la película lagrimal');

-- 13. Diagnósticos de la Consulta
INSERT INTO visit_diagnoses (id, visit_id, diagnosis_id, is_primary, notes) VALUES
(1, 1, 1, TRUE, 'Glaucoma primario ángulo abierto bilateral descompensado'),
(2, 2, 1, TRUE, 'Glaucoma primario compensado tras ajuste'),
(3, 3, 3, TRUE, 'Hipertensión ocular bilateral en estudio'),
(4, 4, 3, TRUE, 'Confirmada hipertensión ocular con paquimetría normal/gruesa'),
(5, 5, 2, TRUE, 'Ataque agudo de glaucoma por cierre angular'),
(6, 6, 2, TRUE, 'Glaucoma de ángulo cerrado post-iridotomía periférica'),
(7, 7, 8, TRUE, 'Presbicia fisiológica'),
(8, 7, 10, FALSE, 'Ojo seco evaporativo asociado'),
(9, 8, 1, TRUE, 'Glaucoma primario estadio severo refractario'),
(10, 9, 1, TRUE, 'Evaluación quirúrgica de glaucoma'),
(11, 10, 4, TRUE, 'Antecedente de trauma contuso sin glaucoma secundario actual'),
(12, 11, 9, TRUE, 'Conjuntivitis alérgica aguda en ambos ojos'),
(13, 12, 1, TRUE, 'Glaucoma controlado con monoterapia alternativa'),
(14, 14, 3, TRUE, 'Sospecha de neuropatía óptica glaucomatosa'),
(15, 15, 6, TRUE, 'Miopía moderada bilateral'),
(16, 16, 1, TRUE, 'Glaucoma estable bajo tratamiento crónico'),
(17, 17, 5, FALSE, 'Pseudofaquia bilateral satisfactoria'),
(18, 19, 3, TRUE, 'Hipertensión ocular limítrofe');

-- 14. Mediciones de Presión Intraocular (PIO)
-- Valores normales (10-21 mmHg) y elevados (> 20 mmHg) para consultas y filtros
INSERT INTO intraocular_pressures (id, visit_id, eye, pressure, measurement_time, method, notes) VALUES
(1, 1, 'OD', 24.50, '09:15:00', 'GOLDMANN', 'PIO elevada por encima de meta objetivo'),
(2, 1, 'OI', 22.00, '09:16:00', 'GOLDMANN', 'Elevación moderada'),
(3, 2, 'OD', 14.00, '10:45:00', 'GOLDMANN', 'Excelente respuesta a ajuste de dosis'),
(4, 2, 'OI', 13.50, '10:46:00', 'GOLDMANN', 'Presión meta alcanzada'),
(5, 3, 'OD', 23.00, '11:15:00', 'GOLDMANN', 'PIO confirmada en tonometría de aplanación'),
(6, 3, 'OI', 22.50, '11:16:00', 'GOLDMANN', 'Bilateral simétrica'),
(7, 4, 'OD', 21.00, '14:45:00', 'GOLDMANN', 'Discreta mejoría'),
(8, 4, 'OI', 20.00, '14:46:00', 'GOLDMANN', 'Límite superior normal'),
(9, 5, 'OD', 48.00, '08:40:00', 'GOLDMANN', 'Urgencia oftalmológica aguda'),
(10, 5, 'OI', 18.00, '08:42:00', 'GOLDMANN', 'Ojo adelfo con cámara estrecha'),
(11, 6, 'OD', 16.00, '09:15:00', 'GOLDMANN', 'Descenso marcado post-iridotomía láser'),
(12, 6, 'OI', 15.00, '09:16:00', 'GOLDMANN', 'Normal'),
(13, 8, 'OD', 26.00, '10:20:00', 'GOLDMANN', 'Descompensación severa con daño terminal'),
(14, 8, 'OI', 25.00, '10:21:00', 'GOLDMANN', 'Fuera de rango meta de seguridad'),
(15, 9, 'OD', 25.50, '11:45:00', 'GOLDMANN', 'Persistencia de hipertensión ocular prequirúrgica'),
(16, 9, 'OI', 23.00, '11:46:00', 'GOLDMANN', 'Requiere control estrecho'),
(17, 12, 'OD', 16.50, '09:45:00', 'GOLDMANN', 'Controlada adecuadamente'),
(18, 12, 'OI', 15.50, '09:46:00', 'GOLDMANN', 'En meta terapéutica'),
(19, 14, 'OD', 19.00, '10:15:00', 'GOLDMANN', 'Normotensional limítrofe'),
(20, 14, 'OI', 18.50, '10:16:00', 'GOLDMANN', 'Normotensional'),
(21, 16, 'OD', 15.00, '11:15:00', 'GOLDMANN', 'Estable'),
(22, 16, 'OI', 14.50, '11:16:00', 'GOLDMANN', 'Estable'),
(23, 19, 'OD', 21.50, '09:20:00', 'GOLDMANN', 'Hipertensión ocular incipiente'),
(24, 19, 'OI', 20.00, '09:21:00', 'GOLDMANN', 'Límite normal');

-- 15. Exámenes de Paquimetría Corneal (CCT)
INSERT INTO pachymetry_exams (id, visit_id, eye, corneal_thickness, method, exam_date) VALUES
(1, 1, 'OD', 525.00, 'ULTRASONICA', '2026-01-10 09:30:00'),
(2, 1, 'OI', 530.00, 'ULTRASONICA', '2026-01-10 09:32:00'),
(3, 4, 'OD', 585.00, 'ULTRASONICA', '2026-02-18 14:50:00'),
(4, 4, 'OI', 590.00, 'ULTRASONICA', '2026-02-18 14:52:00'),
(5, 5, 'OD', 510.00, 'ULTRASONICA', '2026-02-05 08:50:00'),
(6, 5, 'OI', 515.00, 'ULTRASONICA', '2026-02-05 08:52:00'),
(7, 8, 'OD', 495.00, 'ULTRASONICA', '2026-01-25 10:30:00'),
(8, 8, 'OI', 500.00, 'ULTRASONICA', '2026-01-25 10:32:00'),
(9, 14, 'OD', 505.00, 'ULTRASONICA', '2026-02-28 10:20:00'),
(10, 14, 'OI', 510.00, 'ULTRASONICA', '2026-02-28 10:22:00');

-- 16. Exámenes de Gonioscopía
INSERT INTO gonioscopy_exams (id, visit_id, eye, angle_grade, pigmentation, findings, exam_date) VALUES
(1, 1, 'OD', 'GRADO IV', 'MODERADA', 'Ángulo abierto amplio, se visualiza espolón escleral y malla trabecular', '2026-01-10 09:40:00'),
(2, 1, 'OI', 'GRADO IV', 'MODERADA', 'Ángulo abierto completo sin sinequias', '2026-01-10 09:42:00'),
(3, 3, 'OD', 'GRADO III', 'LEVE', 'Ángulo abierto grado III sin depósitos pigmentarios anormales', '2026-01-15 11:30:00'),
(4, 3, 'OI', 'GRADO III', 'LEVE', 'Ángulo abierto simétrico', '2026-01-15 11:32:00'),
(5, 5, 'OD', 'GRADO 0', 'LEVE', 'Cierre angular completo por aposición iridocorneal', '2026-02-05 08:45:00'),
(6, 5, 'OI', 'GRADO I', 'LEVE', 'Ángulo sumamente estrecho con alto riesgo oclusivo', '2026-02-05 08:47:00'),
(7, 6, 'OD', 'GRADO II', 'LEVE', 'Apertura parcial post-iridotomía, trabéculo visible', '2026-02-06 09:20:00'),
(8, 8, 'OD', 'GRADO IV', 'SEVERA', 'Ángulo abierto con severa hiperpigmentación trabecular', '2026-01-25 10:40:00');

-- 17. Exámenes de Tomografía de Coherencia Óptica (OCT)
INSERT INTO oct_exams (id, visit_id, eye, rnfl_average, rnfl_superior, rnfl_inferior, cup_to_disc_ratio, interpretation, is_validated, exam_date) VALUES
(1, 1, 'OD', 74.50, 80.00, 68.00, 0.72, 'Pérdida moderada de capa de fibras nerviosas en polo inferior', TRUE, '2026-01-10 10:00:00'),
(2, 1, 'OI', 79.00, 85.00, 72.00, 0.65, 'Adelgazamiento leve a moderado de CFNR', TRUE, '2026-01-10 10:05:00'),
(3, 4, 'OD', 96.00, 115.00, 118.00, 0.40, 'Espesor de CFNR dentro de límites normales para la edad', TRUE, '2026-02-18 15:10:00'),
(4, 4, 'OI', 98.00, 116.00, 120.00, 0.38, 'Nervio óptico sano sin signos de neuropatía', TRUE, '2026-02-18 15:15:00'),
(5, 8, 'OD', 52.00, 55.00, 48.00, 0.88, 'Atrofia severa difusa de CFNR compatible con glaucoma terminal', TRUE, '2026-01-25 11:00:00'),
(6, 8, 'OI', 58.00, 62.00, 54.00, 0.82, 'Daño estructural avanzado en nervio óptico', TRUE, '2026-01-25 11:05:00'),
(7, 14, 'OD', 70.00, 75.00, 65.00, 0.75, 'Muesca focal inferior en reborde neurorretiniano', TRUE, '2026-02-28 10:40:00'),
(8, 14, 'OI', 82.00, 90.00, 78.00, 0.60, 'Asimetría papilar significativa con ojo contralateral', TRUE, '2026-02-28 10:45:00');

-- 18. Exámenes de Campo Visual (Campimetría)
INSERT INTO visual_field_exams (id, visit_id, eye, strategy, mean_deviation_md, pattern_std_deviation_psd, visual_field_index_vfi, false_positives_pct, false_negatives_pct, reliability, interpretation, exam_date) VALUES
(1, 1, 'OD', 'SITA-Standard 24-2', -6.50, 5.20, 84.00, 2.00, 3.00, 'CONFIABLE', 'Escotoma arcuato superior que respeta la fijación central', '2026-01-10 10:20:00'),
(2, 1, 'OI', 'SITA-Standard 24-2', -3.20, 3.10, 92.00, 1.00, 2.00, 'CONFIABLE', 'Escalón nasal incipiente en hemicampo superior', '2026-01-10 10:35:00'),
(3, 4, 'OD', 'SITA-Standard 24-2', -0.80, 1.40, 99.00, 1.00, 1.00, 'CONFIABLE', 'Campo visual dentro de límites normales', '2026-02-18 15:30:00'),
(4, 4, 'OI', 'SITA-Standard 24-2', -0.60, 1.30, 99.00, 0.00, 1.00, 'CONFIABLE', 'Campo visual normal bilateral', '2026-02-18 15:45:00'),
(5, 8, 'OD', 'SITA-Standard 24-2', -18.50, 9.80, 52.00, 4.00, 6.00, 'CONFIABLE', 'Isla de visión tubular remanente menor a 10 grados', '2026-01-25 11:20:00'),
(6, 8, 'OI', 'SITA-Standard 24-2', -14.20, 8.40, 64.00, 3.00, 5.00, 'CONFIABLE', 'Escotomas coalescentes densos altitudinales', '2026-01-25 11:35:00'),
(7, 14, 'OD', 'SITA-Standard 24-2', -4.80, 4.10, 88.00, 2.00, 3.00, 'CONFIABLE', 'Defecto reproducible compatible con daño en OCT', '2026-02-28 11:00:00'),
(8, 14, 'OI', 'SITA-Standard 24-2', -1.20, 1.60, 97.00, 1.00, 2.00, 'CONFIABLE', 'Sin defectos campimétricos relevantes', '2026-02-28 11:15:00');

-- 19. Catálogo de Medicamentos
INSERT INTO medications (id, name, generic_name, concentration, presentation, is_active) VALUES
(1, 'Xalatan', 'Latanoprost', '0.005%', 'Frasco gotero x 2.5 ml', TRUE),
(2, 'Timoptol', 'Maleato de Timolol', '0.5%', 'Frasco gotero x 5 ml', TRUE),
(3, 'Alphagan P', 'Tartrato de Brimonidina', '0.15%', 'Frasco gotero x 5 ml', TRUE),
(4, 'Trusopt', 'Clorhidrato de Dorzolamida', '2%', 'Frasco gotero x 5 ml', TRUE),
(5, 'Cosopt', 'Dorzolamida + Timolol', '2% / 0.5%', 'Frasco gotero x 5 ml', TRUE),
(6, 'Travatan', 'Travoprost', '0.004%', 'Frasco gotero x 2.5 ml', TRUE),
(7, 'Lumigan', 'Bimatoprost', '0.01%', 'Frasco gotero x 3 ml', TRUE),
(8, 'Diamox', 'Acetazolamida oral', '250 mg', 'Caja x 20 tabletas', TRUE),
(9, 'Prednefrin Forte', 'Acetato de Prednisolona', '1%', 'Frasco gotero x 5 ml', TRUE),
(10, 'Systane Ultra', 'Polietilenglicol + Propilenglicol', '0.4% / 0.3%', 'Frasco gotero x 10 ml', TRUE);

-- 20. Tratamientos Médicos Prescritos
INSERT INTO treatments (id, visit_id, medication_id, eye, dosage, frequency, start_date, end_date, is_active, notes) VALUES
(1, 1, 1, 'AMBOS', '1 gota', 'Cada 24 horas en la noche (9:00 PM)', '2026-01-10', '2026-07-10', TRUE, 'Aplicar con puntualidad nocturna'),
(2, 1, 2, 'AMBOS', '1 gota', 'Cada 12 horas (8:00 AM y 8:00 PM)', '2026-01-10', '2026-07-10', TRUE, 'Oclusión puntual tras instilar'),
(3, 4, 1, 'AMBOS', '1 gota', 'Cada 24 horas en la noche', '2026-02-18', '2026-08-18', TRUE, 'Monoterapia de primera línea para HTO'),
(4, 5, 8, 'AMBOS', '250 mg vía oral', 'Cada 8 horas por 3 días', '2026-02-05', '2026-02-08', FALSE, 'Hipotensor sistémico de rescate agudo'),
(5, 5, 9, 'OD', '1 gota', 'Cada 4 horas por 7 días', '2026-02-05', '2026-02-12', FALSE, 'Antiinflamatorio post-ataque agudo'),
(6, 6, 9, 'OD', '1 gota', 'Cada 6 horas', '2026-02-06', '2026-02-13', FALSE, 'Control de reactividad post-láser'),
(7, 7, 10, 'AMBOS', '1 gota', 'Cada 6 horas según necesidad', '2026-02-20', '2026-08-20', TRUE, 'Lágrimas artificiales'),
(8, 8, 5, 'AMBOS', '1 gota', 'Cada 12 horas', '2026-01-25', '2026-07-25', TRUE, 'Terapia combinada fija'),
(9, 8, 3, 'AMBOS', '1 gota', 'Cada 12 horas', '2026-01-25', '2026-07-25', TRUE, 'Tercer agente hipotensor'),
(10, 11, 10, 'AMBOS', '1 gota', 'Cada 8 horas', '2026-03-01', '2026-04-01', TRUE, 'Alivio de síntomas alérgicos'),
(11, 12, 3, 'AMBOS', '1 gota', 'Cada 12 horas', '2026-01-18', '2026-07-18', TRUE, 'Paciente asmático (sin betabloqueador)'),
(12, 12, 4, 'AMBOS', '1 gota', 'Cada 8 horas', '2026-01-18', '2026-07-18', TRUE, 'Coadyuvante'),
(13, 16, 1, 'AMBOS', '1 gota', 'Cada 24 horas noche', '2026-01-30', '2027-01-30', TRUE, 'Mantenimiento anual');

-- 21. Procedimientos y Cirugías Realizadas
INSERT INTO procedures (id, visit_id, name, eye, procedure_date, complications, results) VALUES
(1, 5, 'Iridotomía Periférica con Láser Nd:YAG', 'OD', '2026-02-05 09:30:00', 'Leve hifema transitorio resuelto espontáneamente', 'Permeabilidad de ventana iridiana confirmada, descenso inmediato de PIO'),
(2, 6, 'Iridotomía Profiláctica con Láser Nd:YAG', 'OI', '2026-02-06 10:00:00', 'Ninguna', 'Apertura satisfactoria del iris periférico en ojo contralateral'),
(3, 9, 'Trabeculectomía con Mitomicina C', 'OD', '2026-03-10 07:30:00', 'Ninguna', 'Bulla de filtración difusa y normotensa formada adecuadamente'),
(4, 10, 'Lavado de Cámara Anterior y Sutura Corneal', 'OD', '2023-04-15 14:00:00', 'Ninguna', 'Cierre hermético post-trauma previo');

-- 22. Registros Maestros de Glaucoma (1 por Paciente con Glaucoma confirmado/sospecha)
INSERT INTO glaucoma_records (id, patient_id, target_iop_od, target_iop_oi, clinical_stage, diagnosis_date, notes) VALUES
(1, 1, 14.00, 14.00, 'MODERADO', '2025-01-15', 'Glaucoma primario de ángulo abierto; meta estricta para evitar avance'),
(2, 2, 16.00, 16.00, 'SOSPECHA', '2026-02-18', 'Hipertensión ocular con paquimetría corneal gruesa'),
(3, 3, 15.00, 15.00, 'MODERADO', '2026-02-05', 'Glaucoma por cierre angular resuelto con iridotomía bilateral'),
(4, 5, 12.00, 12.00, 'TERMINAL', '2024-03-10', 'Glaucoma avanzado terminal, daño campimétrico residual tubular'),
(5, 8, 14.00, 14.00, 'AVANZADO', '2025-08-14', 'Manejo especial por intolerancia a betabloqueadores'),
(6, 10, 15.00, 15.00, 'INICIAL', '2026-02-28', 'Diagnóstico temprano normotensional');

-- 23. Controles Evolutivos de Glaucoma
INSERT INTO glaucoma_controls (id, glaucoma_record_id, visit_id, control_date, is_progression_detected, adherence_score, notes) VALUES
(1, 1, 1, '2026-01-10', TRUE, 'REGULAR', 'El paciente omitía dosis nocturnas por olvido; se refuerza educación'),
(2, 1, 2, '2026-03-12', FALSE, 'EXCELENTE', 'Excelente adherencia lograda con alarma en celular; PIO en meta'),
(3, 2, 4, '2026-02-18', FALSE, 'BUENA', 'Buen cumplimiento de gotas de inicio'),
(4, 3, 6, '2026-02-06', FALSE, 'EXCELENTE', 'Control postquirúrgico láser satisfactorio'),
(5, 4, 8, '2026-01-25', TRUE, 'BUENA', 'Progresión estructural y funcional constatada, se define cirugía'),
(6, 4, 9, '2026-03-05', TRUE, 'BUENA', 'Programación de cirugía de rescate trabeculectomía');

-- 24. Documentos Clínicos y Adjuntos
INSERT INTO clinical_documents (id, clinical_history_id, title, file_type, file_path, uploaded_at, deleted_by) VALUES
(1, 1, 'Campimetría Humphrey 24-2 OD Enero 2026', 'application/pdf', '/storage/docs/2026/01/vf_1001_od.pdf', '2026-01-10 10:45:00', NULL),
(2, 1, 'OCT Nervio Óptico Cirrus Enero 2026', 'application/pdf', '/storage/docs/2026/01/oct_1001.pdf', '2026-01-10 10:50:00', NULL),
(3, 3, 'Fotografía de Polo Anterior con Lámpara de Hendidura', 'image/jpeg', '/storage/docs/2026/02/slitlamp_1003.jpg', '2026-02-05 09:00:00', NULL),
(4, 5, 'Consentimiento Informado para Trabeculectomía', 'application/pdf', '/storage/docs/2026/03/consent_trab_1005.pdf', '2026-03-05 12:00:00', NULL),
(5, 8, 'Reporte de Curva Tensional de 24 Horas', 'application/pdf', '/storage/docs/2026/01/diurnal_curve_1008.pdf', '2026-01-18 10:00:00', NULL);

-- 25. Auditoría Inicial
INSERT INTO audit_logs (id, table_name, record_id, action, old_values, new_values, performed_by, changed_at) VALUES
(1, 'patients', 1, 'INSERT', NULL, '{"first_name": "Juan Carlos", "last_name": "Gómez Pérez"}', 'SYSTEM', '2025-01-15 08:30:00'),
(2, 'patients', 3, 'INSERT', NULL, '{"first_name": "Carlos Alberto", "last_name": "Gómez Mendoza"}', 'SYSTEM', '2025-03-05 10:00:00'),
(3, 'medical_visits', 5, 'INSERT', NULL, '{"reason": "Urgencia dolor ocular agudo"}', 'SYSTEM', '2026-02-05 08:30:00');

SELECT 'Datos semilla insertados exitosamente en oftalmologia_glaucoma_db' AS estado;
