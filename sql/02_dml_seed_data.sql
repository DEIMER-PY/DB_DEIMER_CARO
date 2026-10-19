-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 02_dml_seed_data.sql
-- DESCRIPCIÓN: Inserción de datos semilla clínicamente coherentes y exhaustivos (4FN/5FN)
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE audit_logs;
TRUNCATE TABLE clinical_documents;
TRUNCATE TABLE glaucoma_controls;
TRUNCATE TABLE glaucoma_records;
TRUNCATE TABLE procedures;
TRUNCATE TABLE procedure_types;
TRUNCATE TABLE treatments;
TRUNCATE TABLE medications;
TRUNCATE TABLE medication_classes;
TRUNCATE TABLE visual_field_exams;
TRUNCATE TABLE oct_exams;
TRUNCATE TABLE gonioscopy_exams;
TRUNCATE TABLE biomicroscopy_exams;
TRUNCATE TABLE pachymetry_exams;
TRUNCATE TABLE intraocular_pressures;
TRUNCATE TABLE visual_acuity_exams;
TRUNCATE TABLE visit_diagnoses;
TRUNCATE TABLE diagnoses;
TRUNCATE TABLE medical_visits;
TRUNCATE TABLE appointments;
TRUNCATE TABLE clinical_histories;
TRUNCATE TABLE glaucoma_risk_factors;
TRUNCATE TABLE patient_antecedents;
TRUNCATE TABLE patient_family_histories;
TRUNCATE TABLE patient_allergies;
TRUNCATE TABLE patients;
TRUNCATE TABLE healthcare_professionals;
TRUNCATE TABLE specialties;
TRUNCATE TABLE persons;
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

-- 4. Personas Naturales (Super-tipo generalizador 3FN/BCNF)
-- IDs 1 a 15: Pacientes
-- IDs 16 a 21: Profesionales de la salud
INSERT INTO persons (id, document_type_id, document_number, first_name, last_name, birth_date, gender, city_id, address, phone, email) VALUES
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
(15, 3, 'CE987654', 'John David', 'Smith Miller', '1968-07-04', 'M', 7, 'Cll 93 # 11-40 Parque 93', '3105556688', 'john.smith@expat.com'),
(16, 1, '1098765432', 'Deimer', 'Caro', '1985-05-10', 'M', 1, 'Cra 28 # 50-10 Cabecera', '3157894512', 'deimer.caro@oftalmologia.com'),
(17, 1, '1095432187', 'Roberto', 'Silva Gómez', '1978-08-20', 'M', 1, 'Cll 45 # 29-15 Sotomayor', '3104561234', 'roberto.silva@oftalmologia.com'),
(18, 1, '63456789', 'Elena', 'Vega Rincón', '1982-11-14', 'F', 1, 'Cra 33 # 48-10 San Pío', '3189876543', 'elena.vega@glaucomaclinic.com'),
(19, 1, '1098712345', 'Carlos', 'Mendoza Duarte', '1980-03-25', 'M', 2, 'Cll 31 # 26-05 Cañaveral', '3123456789', 'carlos.mendoza@oftalmologia.com'),
(20, 1, '37890123', 'Sofía', 'Gómez Serrano', '1976-09-30', 'F', 1, 'Cra 25 # 34-12 Centro', '3161239874', 'sofia.gomez@oftalmologia.com'),
(21, 1, '1098654321', 'Javier', 'Hernández Plata', '1984-01-18', 'M', 1, 'Cll 52 # 31-20 Conucos', '3176543210', 'javier.hernandez@retinaclinic.com');

-- 5. Especialidades Médicas
INSERT INTO specialties (id, name, description) VALUES
(1, 'Oftalmología', 'Atención médica y quirúrgica general de los ojos'),
(2, 'Glaucoma', 'Subespecialidad dedicada al diagnóstico y manejo del glaucoma y neuropatías ópticas'),
(3, 'Córnea y Segmento Anterior', 'Especialista en superficie ocular, trasplante corneal y cirugía refractiva'),
(4, 'Retina y Vítreo', 'Diagnóstico y cirugía de patologías de polo posterior'),
(5, 'Neuroftalmología', 'Trastornos visuales relacionados con el sistema nervioso central'),
(6, 'Optometría', 'Exámenes refractivos, agudeza visual y adaptación de lentes');

-- 6. Profesionales de la Salud (Sub-tipo de persons)
INSERT INTO healthcare_professionals (id, person_id, medical_license, specialty_id, is_active) VALUES
(1, 16, 'MP-OFT-2026-001', 2, TRUE),
(2, 17, 'MP-OFT-2018-044', 1, TRUE),
(3, 18, 'MP-GLA-2015-089', 2, TRUE),
(4, 19, 'MP-COR-2020-112', 3, TRUE),
(5, 20, 'MP-OFT-2016-077', 1, TRUE),
(6, 21, 'MP-RET-2019-204', 4, TRUE);

-- 7. Pacientes (Sub-tipo de persons con datos clínicos)
INSERT INTO patients (id, person_id, blood_type, health_insurance, affiliation_type, occupation, emergency_contact_name, emergency_contact_phone) VALUES
(1, 1, 'O+', 'Sanitas', 'COTIZANTE', 'Contador Público', 'María Gómez', '3151119988'),
(2, 2, 'A+', 'Sura', 'COTIZANTE', 'Docente Universitaria', 'Pedro Rodríguez', '3162229988'),
(3, 3, 'O+', 'Nueva EPS', 'PARTICULAR', 'Pensionado', 'Elena Gómez', '3173339988'),
(4, 4, 'B+', 'Compensar', 'BENEFICIARIO', 'Ingeniera Civil', 'Luis Martínez', '3184449988'),
(5, 5, 'AB+', 'Salud Total', 'SUBSIDIADO', 'Ama de Casa', 'Carmen Gómez', '3105559988'),
(6, 6, 'O+', 'Sanitas', 'COTIZANTE', 'Comerciante', 'Rosa Sánchez', '3116669988'),
(7, 7, 'A-', 'Sura', 'COTIZANTE', 'Abogada', 'Jorge Torres', '3127779988'),
(8, 8, 'O+', 'Nueva EPS', 'SUBSIDIADO', 'Agricultor', 'Luz Ramírez', '3138889988'),
(9, 9, 'B-', 'Sanitas', 'COTIZANTE', 'Bióloga', 'Mario Navarro', '3149999988'),
(10, 10, 'A+', 'Compensar', 'COTIZANTE', 'Arquitecto', 'Claudia Álvarez', '3150009988'),
(11, 11, 'O+', 'Sura', 'BENEFICIARIO', 'Estudiante', 'Andrés Vargas', '3161119988'),
(12, 12, 'AB-', 'Nueva EPS', 'COTIZANTE', 'Psicóloga', 'Martín Herrera', '3172229988'),
(13, 13, 'O+', 'Salud Total', 'SUBSIDIADO', 'Pensionada', 'Carlos Villamizar', '3183339988'),
(14, 14, 'A+', 'Sanitas', 'COTIZANTE', 'Diseñador Gráfico', 'Paola García', '3194449988'),
(15, 15, 'O-', 'Seguros Bolívar', 'PARTICULAR', 'Consultor Financiero', 'Sarah Smith', '3105559988');

-- 8. Alergias del Paciente (Normalización 4FN)
INSERT INTO patient_allergies (id, patient_id, allergen, reaction, severity) VALUES
(1, 1, 'Penicilina', 'Rash cutáneo y prurito intenso', 'MODERADA'),
(2, 1, 'Sulfas', 'Edema facial y urticaria', 'SEVERA'),
(3, 2, 'Látex', 'Dermatitis por contacto', 'LEVE'),
(4, 3, 'Dipirona', 'Broncoespasmo', 'SEVERA'),
(5, 5, 'Polen', 'Rinitis alérgica y conjuntivitis', 'LEVE'),
(6, 8, 'Betabloqueadores tópicos', 'Bradicardia sintomática y broncoespasmo', 'SEVERA'),
(7, 10, 'AINEs', 'Gastritis erosiva y angioedema', 'MODERADA'),
(8, 13, 'Penicilina', 'Choque anafiláctico previo', 'SEVERA');

-- 9. Antecedentes Familiares (Normalización 4FN - Independiente de Alergias)
INSERT INTO patient_family_histories (id, patient_id, condition_name, relationship, notes) VALUES
(1, 1, 'Glaucoma Primario de Ángulo Abierto', 'Madre', 'Pérdida severa de campo visual en ojo izquierdo'),
(2, 1, 'Diabetes Mellitus Tipo 2', 'Padre', 'Diagnosticado a los 50 años'),
(3, 2, 'Glaucoma Neovascular', 'Hermano', 'Secundario a retinopatía diabética'),
(4, 3, 'Glaucoma de Ángulo Cerrado', 'Madre', 'Requirió iridotomía periférica bilateral'),
(5, 5, 'Ceguera bilateral por Glaucoma', 'Abuelo materno', 'Diagnóstico tardío'),
(6, 8, 'Hipertensión Arterial', 'Padre', 'Infarto agudo de miocardio a los 62 años'),
(7, 10, 'Glaucoma Primario de Ángulo Abierto', 'Tía paterna', 'Tratamiento crónico con análogos de prostaglandinas'),
(8, 12, 'Desprendimiento de Retina', 'Hermano', 'Miopía alta asociada');

-- 10. Antecedentes Personales (Normalización 4FN)
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

-- 11. Factores de Riesgo de Glaucoma (Normalización 4FN)
INSERT INTO glaucoma_risk_factors (id, patient_id, risk_factor, notes) VALUES
(1, 1, 'ANTECEDENTE_FAMILIAR_1ER_GRADO', 'Madre con GPAA severo'),
(2, 1, 'CCT_DELGADO', 'Paquimetría central inferior a 520 micras'),
(3, 2, 'HIPOTENSION_NOCTURNA', 'Monitoreo MAPA confirma dips tensionales nocturnos'),
(4, 3, 'VASOESPASMO_MIGRAÑA', 'Migraña clásica con aura y fenómeno de Raynaud'),
(5, 5, 'MIOPIA_ALTA', 'Miopía axial superior a 26 mm bilateral'),
(6, 8, 'HEMORRAGIA_DISCO', 'Hemorragia en astilla inferotemporal observada en 2025'),
(7, 10, 'SINDROME_PSEUDOEXFOLIATIVO', 'Depósitos de material blanco en borde pupilar y cápsula anterior'),
(8, 12, 'SINDROME_DISPERSION_PIGMENTARIA', 'Husillo de Krukenberg en endotelio y transiluminación en hendiduras');

-- 12. Historias Clínicas (1 a 1 con Pacientes)
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
(10, 10, 'HC-2026-0010', 'ACTIVA', '2025-10-17 11:15:00');

-- 13. Agendamiento de Citas Clínicas
INSERT INTO appointments (id, patient_id, professional_id, appointment_date, appointment_type, status, reason) VALUES
(1, 1, 1, '2026-01-10 08:30:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Control periódico y evaluación de PIO'),
(2, 1, 1, '2026-03-12 10:00:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Seguimiento tras ajuste terapéutico'),
(3, 2, 3, '2026-01-15 09:30:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Control de glaucoma avanzado'),
(4, 3, 1, '2026-01-20 11:00:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Manejo de glaucoma por corticoides'),
(5, 4, 2, '2026-02-01 08:00:00', 'PRIMERA_VEZ', 'ATENDIDA', 'Examen oftalmológico de rutina'),
(6, 5, 1, '2026-02-05 14:30:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Sospecha de progresión campimétrica'),
(7, 6, 4, '2026-02-12 16:00:00', 'PRIMERA_VEZ', 'ATENDIDA', 'Valoración post-trauma contuso'),
(8, 7, 5, '2026-02-18 09:00:00', 'PRIMERA_VEZ', 'ATENDIDA', 'Tamizaje visual por fatiga ocular'),
(9, 8, 3, '2026-02-25 10:30:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Control de PIO no controlada'),
(10, 10, 1, '2026-03-05 11:30:00', 'CONTROL_GLAUCOMA', 'ATENDIDA', 'Sospecha de glaucoma pseudoexfoliativo');

-- 14. Consultas Médicas
INSERT INTO medical_visits (id, clinical_history_id, professional_id, visit_date, reason, symptoms, assessment, plan, is_closed) VALUES
(1, 1, 1, '2026-01-10 09:00:00', 'Control periódico de glaucoma y ajuste de medicación', 'Visión borrosa ocasional matutina', 'Glaucoma Primario de Ángulo Abierto estable en OD, leve sospecha de progresión en OI', 'Se solicita OCT de papila y campo visual 24-2. Ajustar tratamiento tópico.', TRUE),
(2, 1, 1, '2026-03-12 10:30:00', 'Seguimiento post-ajuste farmacológico', 'Asintomático, buena tolerancia a colirios', 'Presión intraocular dentro de metas en ambos ojos. Tolerancia adecuada a Latanoprost', 'Continuar misma pauta médica. Control en 6 meses con nueva tonometría.', TRUE),
(3, 2, 3, '2026-01-15 10:00:00', 'Pérdida progresiva de campo visual en ojo izquierdo', 'Escotomas periféricos en sector nasal', 'Glaucoma Primario de Ángulo Abierto en estadio avanzado OI, moderado OD', 'Adicionar inhibidor de anhidrasa carbónica. Programar SLT si persiste PIO > 18.', TRUE),
(4, 2, 3, '2026-02-20 11:30:00', 'Control evolutivo y revisión de perimetría', 'Sin cambios visuales subjetivos', 'Defecto perimétrico estable respecto al previo. PIO meta alcanzada bilateralmente', 'Mantener terapia dual con Latanoprost y Dorzolamida/Timolol.', TRUE),
(5, 3, 1, '2026-01-20 11:30:00', 'Hipertensión ocular severa refractaria a monoterapia', 'Cefalea retroocular y halos de colores', 'Glaucoma inducido por corticoides con PIO > 28 mmHg en ambos ojos', 'Suspender corticoides inmediatamente. Iniciar terapia triple hipotensora.', TRUE),
(6, 3, 1, '2026-02-15 09:30:00', 'Control de PIO tras desmonte de corticoide', 'Cefalea resuelta', 'Descenso marcado de PIO tras desmonte de corticoide. Nervio óptico sin daño adicional', 'Monitoreo estricto cada 3 meses.', TRUE),
(7, 4, 2, '2026-02-01 08:30:00', 'Examen oftalmológico de rutina por cefalea tensional', 'Fatiga visual al trabajar en computador', 'Emetropía, fondo de ojo normal, PIO limítrofe fisiológica sin daño de fibras', 'Pautas de ergonomía visual. Control en 1 año.', TRUE),
(8, 5, 1, '2026-02-05 15:00:00', 'Sospecha de glaucoma en paciente con alta miopía', 'Dificultad de adaptación a la oscuridad', 'Glaucoma primario de ángulo abierto en ojo con miopía magna. Excavación papilar 0.75', 'Iniciar análogo de prostaglandinas. Realizar curva de PIO.', TRUE),
(9, 5, 1, '2026-03-18 14:00:00', 'Control post-inicio de análogo de prostaglandina', 'Hiperemia conjuntival leve autolimitada', 'Respuesta hipotensora adecuada en ambos ojos. Disminución del 28% respecto a basal', 'Continuar Bimatoprost nocturno.', TRUE),
(10, 6, 4, '2026-02-12 16:30:00', 'Valoración post-traumatismo en ojo derecho', 'Dolor leve y fotofobia transitoria', 'Ángulo abierto sin recesión angular traumática. PIO normal simétrica', 'Antiinflamatorio tópico de corta duración.', TRUE),
(11, 7, 5, '2026-02-18 09:30:00', 'Tamizaje visual laboral', 'Sensación de arenilla ocular', 'Ojo seco evaporativo leve. Presión intraocular normal de 14 mmHg bilateral', 'Lágrimas artificiales lubricantes.', TRUE),
(12, 8, 3, '2026-02-25 11:00:00', 'Control de glaucoma con antecedente de asma severo', 'Discreta disminución de visión nocturna', 'Glaucoma crónico. Contraindicación absoluta para betabloqueadores por asma', 'Tratamiento exclusivo con Prostaglandina + Alfa agonista.', TRUE),
(13, 8, 3, '2026-03-22 08:30:00', 'Revisión de tolerancia farmacológica', 'Excelente tolerancia sin crisis broncoespástica', 'PIO controlada en 15 mmHg en ambos ojos.', 'Mantener esquema actual.', TRUE),
(14, 9, 2, '2026-03-01 10:15:00', 'Evaluación refractiva y fondo de ojo', 'Miopía leve conocida', 'Nervios ópticos con simetría y excavación fisiológica 0.3.', 'Fórmula de lentes actualizada.', TRUE),
(15, 10, 1, '2026-03-05 12:00:00', 'Valoración de síndrome pseudoexfoliativo', 'Asintomático, remitido por hallazgo en lámpara de hendidura', 'Glaucoma pseudoexfoliativo incipiente con material fibrilar en reborde pupilar', 'Monitoreo trimestral e inicio de Latanoprost por PIO asimétrica elevada.', TRUE);

-- 15. Diagnósticos CIE-10
INSERT INTO diagnoses (id, code, name, is_glaucoma_type, description) VALUES
(1, 'H40.1', 'Glaucoma primario de ángulo abierto', TRUE, 'Neuropatía óptica progresiva con ángulo iridocorneal abierto'),
(2, 'H40.2', 'Glaucoma primario de ángulo cerrado', TRUE, 'Aumento de PIO secundario a aposición u oclusión iridocorneal'),
(3, 'H40.0', 'Sospecha de glaucoma / Hipertensión ocular', TRUE, 'PIO elevada o papila sospechosa sin daño campimétrico concluyente'),
(4, 'H40.5', 'Glaucoma secundario a otros trastornos del ojo', TRUE, 'Glaucoma asociado a trauma, inflamación o pseudoexfoliación'),
(5, 'H40.6', 'Glaucoma inducido por fármacos', TRUE, 'Aumento tensional inducido por administración de corticoides'),
(6, 'H40.8', 'Otros glaucomas especificados (Pigmentario)', TRUE, 'Glaucoma secundario a síndrome de dispersión pigmentaria'),
(7, 'H52.1', 'Miopía', FALSE, 'Defecto de refracción donde los rayos convergen delante de la retina'),
(8, 'H52.2', 'Astigmatismo', FALSE, 'Defecto refractivo por curvatura corneal no homogénea'),
(9, 'H52.4', 'Presbicia', FALSE, 'Pérdida fisiológica progresiva de la acomodación del cristalino'),
(10, 'H04.1', 'Ojo seco (Síndrome de disfunción lagrimal)', FALSE, 'Trastorno de la película lagrimal que causa daño en la superficie ocular'),
(11, 'H25.1', 'Catarata senil nuclear', FALSE, 'Opacificación del núcleo del cristalino ligada al envejecimiento'),
(12, 'H40.3', 'Glaucoma secundario a traumatismo ocular', TRUE, 'Hipertensión ocular consecutiva a contusión o recesión angular');

-- 16. Diagnósticos de la Consulta
INSERT INTO visit_diagnoses (id, visit_id, diagnosis_id, is_primary, notes) VALUES
(1, 1, 1, TRUE, 'Glaucoma primario de ángulo abierto bilateral en estadio moderado'),
(2, 2, 1, TRUE, 'GPAA estable bajo terapia farmacológica'),
(3, 3, 1, TRUE, 'GPAA avanzado en ojo izquierdo con compromiso pericentral'),
(4, 4, 1, TRUE, 'Control favorable de GPAA avanzado'),
(5, 5, 5, TRUE, 'Hipertensión ocular severa inducida por corticoterapia tópica'),
(6, 6, 5, TRUE, 'Resolución progresiva de respuesta hipertensiva corticoidea'),
(7, 7, 10, TRUE, 'Fatiga acomodativa y queratoconjuntivitis seca leve'),
(8, 8, 1, TRUE, 'Glaucoma en ojo con alta miopía'),
(9, 8, 7, FALSE, 'Miopía degenerativa / magna bilateral'),
(10, 9, 1, TRUE, 'Glaucoma y miopía controlados'),
(11, 10, 12, TRUE, 'Traumatismo cerrado ocular sin daño glaucomatoso'),
(12, 11, 10, TRUE, 'Ojo seco moderado por uso excesivo de pantallas'),
(13, 12, 1, TRUE, 'Glaucoma en paciente con asma bronquial activa'),
(14, 14, 7, TRUE, 'Miopía simple de bajo grado'),
(15, 15, 4, TRUE, 'Glaucoma pseudoexfoliativo incipiente');

-- 17. Exámenes de Agudeza Visual y Refracción
INSERT INTO visual_acuity_exams (id, visit_id, eye, sphere, cylinder, axis, uncorrected_va, corrected_va, pinhole_va, exam_date) VALUES
(1, 1, 'OD', -0.50, -0.75, 170, '20/30', '20/20', '20/20', '2026-01-10 09:15:00'),
(2, 1, 'OI', -0.75, -1.00, 10, '20/40', '20/25', '20/20', '2026-01-10 09:15:00'),
(3, 3, 'OD', 0.00, -0.50, 90, '20/25', '20/20', '20/20', '2026-01-15 10:10:00'),
(4, 3, 'OI', +0.50, -1.25, 85, '20/60', '20/40', '20/30', '2026-01-15 10:10:00'),
(5, 5, 'OD', -1.25, 0.00, NULL, '20/40', '20/20', '20/20', '2026-01-20 11:40:00'),
(6, 5, 'OI', -1.50, -0.50, 15, '20/50', '20/25', '20/20', '2026-01-20 11:40:00'),
(7, 8, 'OD', -6.50, -1.50, 165, '20/200', '20/30', '20/25', '2026-02-05 15:10:00'),
(8, 8, 'OI', -7.00, -2.00, 15, '20/200', '20/40', '20/30', '2026-02-05 15:10:00'),
(9, 15, 'OD', +0.75, -0.75, 180, '20/30', '20/20', '20/20', '2026-03-05 12:10:00'),
(10, 15, 'OI', +1.00, -1.00, 5, '20/40', '20/25', '20/20', '2026-03-05 12:10:00');

-- 18. Mediciones de Presión Intraocular (PIO)
INSERT INTO intraocular_pressures (id, visit_id, eye, pressure, measurement_time, method, notes) VALUES
(1, 1, 'OD', 22.50, '09:15:00', 'GOLDMANN', 'Tonometría antes de ajuste terapéutico'),
(2, 1, 'OI', 25.00, '09:15:00', 'GOLDMANN', 'Presión elevada respecto a la meta establecida'),
(3, 2, 'OD', 14.00, '10:45:00', 'GOLDMANN', 'Excelente control post-tratamiento'),
(4, 2, 'OI', 13.50, '10:45:00', 'GOLDMANN', 'Descenso marcado de 11.5 mmHg'),
(5, 3, 'OD', 19.00, '10:15:00', 'GOLDMANN', 'PIO limítrofe'),
(6, 3, 'OI', 28.50, '10:15:00', 'GOLDMANN', 'Descompensación severa de PIO con daño campimétrico'),
(7, 4, 'OD', 14.50, '11:45:00', 'GOLDMANN', 'Control adecuado'),
(8, 4, 'OI', 15.00, '11:45:00', 'GOLDMANN', 'Descenso del 47% con terapia dual'),
(9, 5, 'OD', 31.00, '11:45:00', 'GOLDMANN', 'Pico tensional por corticoesteroides'),
(10, 5, 'OI', 33.50, '11:45:00', 'GOLDMANN', 'Hipertensión ocular severa'),
(11, 6, 'OD', 16.00, '09:45:00', 'GOLDMANN', 'Normalización tras desmonte de corticoide'),
(12, 6, 'OI', 16.50, '09:45:00', 'GOLDMANN', 'Normalización completa'),
(13, 7, 'OD', 13.00, '08:45:00', 'AIRE', 'Presión fisiológica'),
(14, 7, 'OI', 13.50, '08:45:00', 'AIRE', 'Presión fisiológica'),
(15, 8, 'OD', 24.00, '15:15:00', 'PERKINS', 'Elevada en paciente con miopía degenerativa'),
(16, 8, 'OI', 26.50, '15:15:00', 'PERKINS', 'Riesgo alto de daño glaucomatoso progresivo'),
(17, 9, 'OD', 15.50, '14:15:00', 'GOLDMANN', 'Buena respuesta hipotensora'),
(18, 9, 'OI', 16.00, '14:15:00', 'GOLDMANN', 'Controlada'),
(19, 10, 'OD', 15.00, '16:45:00', 'ICARE', 'Sin elevación tras contusión ocular'),
(20, 10, 'OI', 14.50, '16:45:00', 'ICARE', 'Ojo adelfo simétrico'),
(21, 15, 'OD', 23.50, '12:15:00', 'GOLDMANN', 'Asimetría marcada con PIO alta en ojo con pseudoexfoliación'),
(22, 15, 'OI', 16.00, '12:15:00', 'GOLDMANN', 'Normotenso');

-- 19. Paquimetrías Corneales (CCT)
INSERT INTO pachymetry_exams (id, visit_id, eye, corneal_thickness, method, exam_date) VALUES
(1, 1, 'OD', 510.00, 'ULTRASONICA', '2026-01-10 09:45:00'),
(2, 1, 'OI', 505.00, 'ULTRASONICA', '2026-01-10 09:45:00'),
(3, 3, 'OD', 535.00, 'ULTRASONICA', '2026-01-15 10:45:00'),
(4, 3, 'OI', 525.00, 'ULTRASONICA', '2026-01-15 10:45:00'),
(5, 5, 'OD', 570.00, 'OPTICA', '2026-01-20 12:00:00'),
(6, 5, 'OI', 568.00, 'OPTICA', '2026-01-20 12:00:00'),
(7, 8, 'OD', 495.00, 'ULTRASONICA', '2026-02-05 15:45:00'),
(8, 8, 'OI', 490.00, 'ULTRASONICA', '2026-02-05 15:45:00'),
(9, 15, 'OD', 528.00, 'OPTICA', '2026-03-05 12:30:00'),
(10, 15, 'OI', 532.00, 'OPTICA', '2026-03-05 12:30:00');

-- 20. Biomicroscopías con Lámpara de Hendidura
INSERT INTO biomicroscopy_exams (id, visit_id, eye, cornea_status, anterior_chamber_depth, iris_status, lens_status, pseudoexfoliation_present, pigment_dispersion_present, exam_date) VALUES
(1, 1, 'OD', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'TRANSPARENTE', FALSE, FALSE, '2026-01-10 09:20:00'),
(2, 1, 'OI', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'TRANSPARENTE', FALSE, FALSE, '2026-01-10 09:20:00'),
(3, 3, 'OD', 'TRANSPARENTE', 'VAN_HERICK_III', 'NORMAL', 'CATARATA_NUCLEAR', FALSE, FALSE, '2026-01-15 10:20:00'),
(4, 3, 'OI', 'TRANSPARENTE', 'VAN_HERICK_II', 'NORMAL', 'CATARATA_NUCLEAR', FALSE, FALSE, '2026-01-15 10:20:00'),
(5, 5, 'OD', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'TRANSPARENTE', FALSE, FALSE, '2026-01-20 11:50:00'),
(6, 5, 'OI', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'TRANSPARENTE', FALSE, FALSE, '2026-01-20 11:50:00'),
(7, 8, 'OD', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'CATARATA_NUCLEAR', FALSE, FALSE, '2026-02-05 15:20:00'),
(8, 8, 'OI', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'CATARATA_NUCLEAR', FALSE, FALSE, '2026-02-05 15:20:00'),
(9, 15, 'OD', 'TRANSPARENTE', 'VAN_HERICK_III', 'DEFECTOS_TRANSILLUMINACION', 'CATARATA_NUCLEAR', TRUE, FALSE, '2026-03-05 12:20:00'),
(10, 15, 'OI', 'TRANSPARENTE', 'VAN_HERICK_IV', 'NORMAL', 'CATARATA_NUCLEAR', FALSE, FALSE, '2026-03-05 12:20:00');

-- 21. Gonioscopías
INSERT INTO gonioscopy_exams (id, visit_id, eye, angle_grade, pigmentation, findings, exam_date) VALUES
(1, 1, 'OD', 'GRADO IV', 'MODERADA', 'Todas las estructuras visibles: espolón escleral, malla trabecular y banda del cuerpo ciliar', '2026-01-10 09:50:00'),
(2, 1, 'OI', 'GRADO IV', 'MODERADA', 'Ángulo ampliamente abierto en 360 grados sin sinequias', '2026-01-10 09:50:00'),
(3, 3, 'OD', 'GRADO III', 'MODERADA', 'Ángulo abierto susceptible de SLT', '2026-01-15 10:50:00'),
(4, 3, 'OI', 'GRADO II', 'SEVERA', 'Estrechamiento moderado del ángulo en cuadrante superior', '2026-01-15 10:50:00'),
(5, 5, 'OD', 'GRADO IV', 'LEVE', 'Ángulo abierto grado IV según Shaffer sin sinequias', '2026-01-20 12:10:00'),
(6, 5, 'OI', 'GRADO IV', 'LEVE', 'Malla trabecular normopigmentada', '2026-01-20 12:10:00'),
(7, 8, 'OD', 'GRADO IV', 'LEVE', 'Ángulo profundo propio de miopía alta', '2026-02-05 15:50:00'),
(8, 8, 'OI', 'GRADO IV', 'LEVE', 'Ángulo abierto amplio', '2026-02-05 15:50:00'),
(9, 15, 'OD', 'GRADO III', 'SEVERA', 'Línea de Sampaolesi visible e hiperpigmentación trabecular irregular', '2026-03-05 12:35:00'),
(10, 15, 'OI', 'GRADO IV', 'LEVE', 'Ángulo abierto normal', '2026-03-05 12:35:00');

-- 22. Tomografías de Coherencia Óptica (OCT)
INSERT INTO oct_exams (id, visit_id, eye, rnfl_average, rnfl_superior, rnfl_inferior, cup_to_disc_ratio, interpretation, is_validated, exam_date) VALUES
(1, 1, 'OD', 88.50, 105.00, 108.00, 0.55, 'Grosor de CFNR conservado dentro de límites normales', TRUE, '2026-01-10 10:05:00'),
(2, 1, 'OI', 79.00, 92.00, 84.00, 0.65, 'Adelgazamiento leve a moderado de CFNR en cuadrante inferior', TRUE, '2026-01-10 10:05:00'),
(3, 3, 'OD', 75.00, 88.00, 78.00, 0.68, 'Daño moderado de capa de fibras nerviosas en ambos polos', TRUE, '2026-01-15 11:05:00'),
(4, 3, 'OI', 58.00, 64.00, 52.00, 0.85, 'Daño severo y excavación marcada subtotal', TRUE, '2026-01-15 11:05:00'),
(5, 5, 'OD', 94.00, 115.00, 120.00, 0.40, 'Nervio óptico estructuralmente intacto', TRUE, '2026-01-20 12:30:00'),
(6, 5, 'OI', 93.00, 112.00, 118.00, 0.42, 'Sin daño de CFNR por hipertensión ocular aguda', TRUE, '2026-01-20 12:30:00'),
(7, 8, 'OD', 68.00, 74.00, 70.00, 0.72, 'Disminución de CFNR en paciente con disco miópico grande', TRUE, '2026-02-05 16:05:00'),
(8, 8, 'OI', 65.00, 71.00, 67.00, 0.76, 'Pérdida concordante con daño glaucomatoso', TRUE, '2026-02-05 16:05:00'),
(9, 15, 'OD', 72.00, 84.00, 76.00, 0.70, 'Adelgazamiento significativo en polo superior e inferior', TRUE, '2026-03-05 12:50:00'),
(10, 15, 'OI', 91.00, 110.00, 115.00, 0.45, 'Simetría conservada sin signos de pérdida', TRUE, '2026-03-05 12:50:00');

-- 23. Campos Visuales (Campimetría Computarizada)
INSERT INTO visual_field_exams (id, visit_id, eye, strategy, mean_deviation_md, pattern_std_deviation_psd, visual_field_index_vfi, false_positives_pct, false_negatives_pct, reliability, interpretation, exam_date) VALUES
(1, 1, 'OD', 'SITA-Standard 24-2', -1.50, 1.80, 98.00, 2.00, 1.00, 'CONFIABLE', 'Campo visual dentro de límites normales', '2026-01-10 10:35:00'),
(2, 1, 'OI', 'SITA-Standard 24-2', -3.20, 3.40, 92.00, 3.00, 4.00, 'CONFIABLE', 'Escalón nasal incipiente en hemicampo superior', '2026-01-10 10:35:00'),
(3, 3, 'OD', 'SITA-Standard 24-2', -5.40, 4.80, 85.00, 4.00, 3.00, 'CONFIABLE', 'Escotoma paracentral superior y escalón nasal', '2026-01-15 11:35:00'),
(4, 3, 'OI', 'SITA-Standard 24-2', -14.80, 8.20, 56.00, 5.00, 6.00, 'CONFIABLE', 'Defecto arciforme bi-hemicampo con islote central residual', '2026-01-15 11:35:00'),
(5, 5, 'OD', 'SITA-Fast 24-2', -0.80, 1.40, 99.00, 1.00, 2.00, 'CONFIABLE', 'Sin defectos reproducibles de sensibilidad retiniana', '2026-01-20 12:55:00'),
(6, 5, 'OI', 'SITA-Fast 24-2', -1.10, 1.50, 99.00, 2.00, 1.00, 'CONFIABLE', 'Sensibilidad foveal y periférica normal', '2026-01-20 12:55:00'),
(7, 8, 'OD', 'SITA-Standard 24-2', -6.10, 5.20, 82.00, 4.00, 5.00, 'CONFIABLE', 'Escotoma arcuato superior que respeta fijación', '2026-02-05 16:35:00'),
(8, 8, 'OI', 'SITA-Standard 24-2', -7.50, 6.10, 78.00, 3.00, 4.00, 'CONFIABLE', 'Depresión generalizada y defecto nasal profundo', '2026-02-05 16:35:00'),
(9, 15, 'OD', 'SITA-Standard 24-2', -4.20, 4.10, 89.00, 2.00, 3.00, 'CONFIABLE', 'Escotoma en sector superior correspondiente a daño en CFNR', '2026-03-05 13:15:00'),
(10, 15, 'OI', 'SITA-Standard 24-2', -0.90, 1.60, 99.00, 1.00, 2.00, 'CONFIABLE', 'Examen normal sin defectos de campo', '2026-03-05 13:15:00');

-- 24. Catálogo de Clases Farmacológicas de Medicamentos (3FN)
INSERT INTO medication_classes (id, name, mechanism_of_action) VALUES
(1, 'Análogos de Prostaglandinas', 'Incrementan el drenaje uveoescleral del humor acuoso'),
(2, 'Beta-bloqueadores adrenérgicos', 'Disminuyen la producción de humor acuoso por el cuerpo ciliar'),
(3, 'Agonistas alfa-2 adrenérgicos', 'Mecanismo dual: reducen la producción acuosa y aumentan el flujo uveoescleral'),
(4, 'Inhibidores de Anhidrasa Carbónica', 'Inhiben la secreción activa de bicarbonato disminuyendo la producción acuosa'),
(5, 'Inhibidores de Rho-quinasa (ROCK)', 'Aumentan el drenaje trabecular relajando la malla trabecular'),
(6, 'Mióticos / Colinérgicos', 'Provocan contracción del músculo ciliar abriendo la malla trabecular'),
(7, 'Combinaciones Fijas Tópicas', 'Sinergia terapéutica con dos principios activos en un mismo frasco');

-- 25. Catálogo de Medicamentos
INSERT INTO medications (id, medication_class_id, name, generic_name, concentration, presentation, is_active) VALUES
(1, 1, 'Xalatan', 'Latanoprost', '0.005%', 'Frasco gotero x 2.5 ml', TRUE),
(2, 2, 'Timoptol', 'Timolol maleato', '0.5%', 'Frasco gotero x 5 ml', TRUE),
(3, 3, 'Alphagan P', 'Tartrato de Brimonidina', '0.15%', 'Frasco gotero x 5 ml', TRUE),
(4, 4, 'Trusopt', 'Dorzolamida clorhidrato', '2.0%', 'Frasco gotero x 5 ml', TRUE),
(5, 1, 'Travatan', 'Travoprost', '0.004%', 'Frasco gotero x 2.5 ml', TRUE),
(6, 1, 'Lumigan', 'Bimatoprost', '0.01%', 'Frasco gotero x 3 ml', TRUE),
(7, 7, 'Cosopt', 'Dorzolamida + Timolol', '2% + 0.5%', 'Frasco gotero x 5 ml', TRUE),
(8, 7, 'Combigan', 'Brimonidina + Timolol', '0.2% + 0.5%', 'Frasco gotero x 5 ml', TRUE),
(9, 4, 'Azopt', 'Brinzolamida', '1.0%', 'Frasco gotero suspensión x 5 ml', TRUE),
(10, 7, 'Simbrinza', 'Brinzolamida + Brimonidina', '1% + 0.2%', 'Frasco gotero x 5 ml', TRUE);

-- 26. Tratamientos Prescritos
INSERT INTO treatments (id, visit_id, medication_id, eye, dosage, frequency, start_date, end_date, is_active, notes) VALUES
(1, 1, 1, 'OI', '1 gota', 'Cada 24 horas por la noche', '2026-01-10', NULL, TRUE, 'Aplicar a las 21:00 horas'),
(2, 1, 2, 'OD', '1 gota', 'Cada 12 horas', '2026-01-10', '2026-03-12', FALSE, 'Reemplazado por buena respuesta general'),
(3, 3, 1, 'AMBOS', '1 gota', 'Cada 24 horas por la noche', '2026-01-15', NULL, TRUE, 'Base hipotensora primaria'),
(4, 3, 7, 'OI', '1 gota', 'Cada 12 horas', '2026-01-15', NULL, TRUE, 'Terapia combinada por daño avanzado en OI'),
(5, 5, 7, 'AMBOS', '1 gota', 'Cada 12 horas', '2026-01-20', '2026-02-15', FALSE, 'Tratamiento de ataque por pico hipertensivo'),
(6, 5, 3, 'AMBOS', '1 gota', 'Cada 8 horas', '2026-01-20', '2026-02-15', FALSE, 'Tercer agente transitorio'),
(7, 8, 6, 'AMBOS', '1 gota', 'Cada 24 horas noche', '2026-02-05', NULL, TRUE, 'Bimatoprost por alta eficacia tensional'),
(8, 10, 2, 'OD', '1 gota', 'Cada 12 horas', '2026-02-12', '2026-02-26', FALSE, 'Uso profiláctico post-traumatismo'),
(9, 12, 1, 'AMBOS', '1 gota', 'Cada 24 horas noche', '2026-02-25', NULL, TRUE, 'Evitar betabloqueador por asma'),
(10, 12, 3, 'AMBOS', '1 gota', 'Cada 12 horas', '2026-02-25', NULL, TRUE, 'Coadyuvante alfa-adrenérgico'),
(11, 15, 1, 'OD', '1 gota', 'Cada 24 horas noche', '2026-03-05', NULL, TRUE, 'Inicio temprano en ojo con pseudoexfoliación'),
(12, 2, 1, 'AMBOS', '1 gota', 'Cada 24 horas noche', '2026-03-12', '2026-09-12', TRUE, 'Continuidad de pauta médica');

-- 27. Catálogo de Tipos de Procedimientos y Cirugías (3FN)
INSERT INTO procedure_types (id, code, name, category, description) VALUES
(1, 'CUPS-124101', 'Trabeculectomía filtrante convencional', 'QUIRURGICO', 'Fístula quirúrgica escleral protegida con ampolla de filtración'),
(2, 'CUPS-124201', 'Trabeculoplastia selectiva con láser (SLT)', 'LASER', 'Fototermólisis selectiva de células pigmentadas de la malla trabecular'),
(3, 'CUPS-121201', 'Iridotomía periférica con láser Nd:YAG', 'LASER', 'Orificio en iris periférico para resolver o prevenir bloqueo pupilar'),
(4, 'CUPS-124301', 'Implante de dispositivo de drenaje (Válvula de Ahmed)', 'QUIRURGICO', 'Dispositivo restrictivo de flujo con tubo en cámara anterior'),
(5, 'CUPS-131100', 'Facoemulsificación de catarata con implante de LIO', 'QUIRURGICO', 'Extracción ultrasónica de cristalino opaco e implante de lente'),
(6, 'CUPS-124401', 'Ciclofotocoagulación transescleral con láser diodo', 'LASER', 'Ablación térmica de procesos ciliares para reducir producción acuosa'),
(7, 'CUPS-124501', 'Cirugía de glaucoma mínimamente invasiva (MIGS)', 'QUIRURGICO', 'Microimplante trabecular ab interno para derivación acuosa');

-- 28. Procedimientos Clínicos Ejecutados
INSERT INTO procedures (id, visit_id, procedure_type_id, eye, procedure_date, complications, results) VALUES
(1, 1, 2, 'OD', '2026-01-12 11:00:00', 'Ninguna', 'Tratamiento en 180 grados de trabéculo. Sin picos hipertensivos'),
(2, 3, 3, 'AMBOS', '2026-01-18 15:30:00', 'Hifema microscópico autolimitado OI', 'Iridotomías permeables y patentes a las 11 horas bilateral'),
(3, 3, 1, 'OI', '2026-02-05 08:00:00', 'Discreta atalamia transitoria día 1', 'Ampolla de filtración difusa posterior normofuncionante'),
(4, 5, 2, 'AMBOS', '2026-02-18 10:00:00', 'Ninguna', 'SLT bilateral para acelerar reducción de PIO post-corticoide'),
(5, 8, 4, 'OD', '2026-02-28 07:30:00', 'Ninguna', 'Válvula de Ahmed FP7 posicionada correctamente en cuadrante temporal superior'),
(6, 15, 3, 'OD', '2026-03-08 14:00:00', 'Ninguna', 'Iridotomía profiláctica por dispersión de material y ángulo estrecho');

-- 29. Fichas de Glaucoma
INSERT INTO glaucoma_records (id, patient_id, target_iop_od, target_iop_oi, clinical_stage, diagnosis_date, notes) VALUES
(1, 1, 15.00, 14.00, 'MODERADO', '2025-01-20', 'Meta tensional ajustada por defecto campimétrico incipiente OI'),
(2, 2, 14.00, 11.00, 'AVANZADO', '2024-11-10', 'Meta muy estricta en OI (< 12 mmHg) para frenar progresión'),
(3, 3, 16.00, 16.00, 'INICIAL', '2026-01-20', 'Glaucoma secundario a esteroides en fase de recuperación'),
(4, 5, 14.00, 13.00, 'AVANZADO', '2025-05-22', 'Riesgo elevado por elongación axial y adelgazamiento escleral'),
(5, 8, 15.00, 14.00, 'MODERADO', '2024-08-30', 'Opciones limitadas por reactividad bronquial severa'),
(6, 10, 16.00, 15.00, 'SOSPECHA', '2026-03-05', 'Monitoreo de conversión de síndrome pseudoexfoliativo a glaucoma');

-- 30. Controles Evolutivos de Glaucoma
INSERT INTO glaucoma_controls (id, glaucoma_record_id, visit_id, control_date, is_progression_detected, adherence_score, notes) VALUES
(1, 1, 1, '2026-01-10', FALSE, 'BUENA', 'Presión fuera de meta en OI, requiere ajuste'),
(2, 1, 2, '2026-03-12', FALSE, 'EXCELENTE', 'Meta alcanzada en ambos ojos tras adición terapéutica'),
(3, 2, 3, '2026-01-15', TRUE, 'REGULAR', 'Progresión funcional detectada en hemicampo superior OI'),
(4, 2, 4, '2026-02-20', FALSE, 'EXCELENTE', 'Estabilización con terapia dual'),
(5, 3, 5, '2026-01-20', FALSE, 'BUENA', 'Pico hipertensivo severo secundario a medicación externa'),
(6, 3, 6, '2026-02-15', FALSE, 'BUENA', 'Descenso marcado hacia la normalidad'),
(7, 4, 8, '2026-02-05', TRUE, 'BUENA', 'Progresión estructural y funcional en ojo miope alto'),
(8, 4, 9, '2026-03-18', FALSE, 'EXCELENTE', 'Excelente respuesta tensional con Bimatoprost');

-- 31. Documentos Clínicos y Adjuntos
INSERT INTO clinical_documents (id, clinical_history_id, title, file_type, file_path, uploaded_at) VALUES
(1, 1, 'Reporte OCT Cirrus Papilar 2026-01', 'application/pdf', '/docs/histories/1/oct_20260110.pdf', '2026-01-10 10:10:00'),
(2, 1, 'Campimetría Humphrey 24-2 2026-01', 'application/pdf', '/docs/histories/1/vf_20260110.pdf', '2026-01-10 10:40:00'),
(3, 2, 'Reporte OCT Macula y Nervio 2026-01', 'application/pdf', '/docs/histories/2/oct_20260115.pdf', '2026-01-15 11:10:00'),
(4, 2, 'Campimetría Humphrey Bilateral 2026-01', 'application/pdf', '/docs/histories/2/vf_20260115.pdf', '2026-01-15 11:40:00'),
(5, 5, 'Retinografía a Color de Papila', 'image/jpeg', '/docs/histories/5/retinografia_20260205.jpg', '2026-02-05 15:30:00'),
(6, 3, 'Consentimiento Informado SLT', 'application/pdf', '/docs/histories/3/consent_slt_20260218.pdf', '2026-02-18 09:45:00');

-- 32. Bitácora Inicial de Auditoría
INSERT INTO audit_logs (id, table_name, record_id, action, old_values, new_values, performed_by, changed_at) VALUES
(1, 'patients', 1, 'INSERT', NULL, '{"document": "1098123456", "name": "Juan Carlos Gómez Pérez"}', 'SYSTEM', '2025-01-15 08:30:00'),
(2, 'clinical_histories', 1, 'INSERT', NULL, '{"patient_id": 1, "history_number": "HC-2026-0001"}', 'SYSTEM', '2025-01-15 08:30:00'),
(3, 'medical_visits', 1, 'INSERT', NULL, '{"clinical_history_id": 1, "professional_id": 1}', 'SYSTEM', '2026-01-10 09:00:00'),
(4, 'intraocular_pressures', 2, 'INSERT', NULL, '{"eye": "OI", "pressure": 25.00}', 'SYSTEM', '2026-01-10 09:15:00'),
(5, 'intraocular_pressures', 9, 'ALERT', NULL, '{"alert": "PIO CRITICA DETECTADA", "eye": "OD", "pressure": 31.00}', 'CLINICAL_MONITOR', '2026-01-20 11:45:00'),
(6, 'intraocular_pressures', 10, 'ALERT', NULL, '{"alert": "PIO CRITICA DETECTADA", "eye": "OI", "pressure": 33.50}', 'CLINICAL_MONITOR', '2026-01-20 11:45:00'),
(7, 'treatments', 2, 'UPDATE', '{"is_active": true}', '{"is_active": false}', 'PHARMACY_AUDIT', '2026-03-12 10:30:00'),
(8, 'glaucoma_records', 1, 'UPDATE', '{"clinical_stage": "SOSPECHA"}', '{"clinical_stage": "MODERADO"}', 'CLINICAL_AUDIT', '2026-01-10 09:30:00'),
(9, 'treatments', 5, 'UPDATE', '{"is_active": true}', '{"is_active": false}', 'TREATMENT_CLOSURE', '2026-02-15 09:30:00'),
(10, 'treatments', 6, 'UPDATE', '{"is_active": true}', '{"is_active": false}', 'TREATMENT_CLOSURE', '2026-02-15 09:30:00');
