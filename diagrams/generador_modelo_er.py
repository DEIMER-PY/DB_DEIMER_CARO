# -*- coding: utf-8 -*-
"""Genera el modelo entidad-relación (HTML) de oftalmologia_glaucoma_db a partir del DDL real.

Uso (desde la raíz del proyecto):
    python diagrams/generador_modelo_er.py diagrams/modelo_entidad_relacion.html diagrams/plantilla_modelo_er.html

Si cambia sql/01_ddl_schema.sql, actualice aquí las tablas (T) y las llaves foráneas (FKS) y vuelva a ejecutarlo.
"""
import html, math, sys

E = lambda s: html.escape(str(s), quote=True)

# ----------------------------------------------------------------------------- módulos
MODS = {
    'm1': ('Pacientes y ubicación', '#1F4E78'),
    'm2': ('Profesionales de salud', '#6C3483'),
    'm3': ('Historia clínica y consultas', '#9A6300'),
    'm4': ('Exámenes oftalmológicos', '#117A65'),
    'm5': ('Tratamientos y procedimientos', '#A93226'),
    'm6': ('Seguimiento de glaucoma', '#2874A6'),
    'm7': ('Auditoría y respaldo', '#566573'),
}

# ----------------------------------------------------------------------------- tablas
def C(name, typ, null=False, key='', ref='', default='', desc=''):
    return dict(name=name, type=typ, null=null, key=key, ref=ref, default=default, desc=desc)

CT = 'CURRENT_TIMESTAMP'
ID = lambda t='BIGINT', d='Identificador único': C('id', t + ' AUTO_INCREMENT', key='PK', desc=d)
EYE2 = "ENUM('OD','OI')"
EYE3 = "ENUM('OD','OI','AMBOS')"
VISIT = C('visit_id', 'BIGINT', key='FK', ref='medical_visits.id', desc='Consulta en la que se registró')

T = {}
def table(name, mod, desc, cols, cons=(), tag=''):
    T[name] = dict(name=name, mod=mod, desc=desc, cols=cols, cons=list(cons), tag=tag)

# MÓDULO 1: Pacientes y ubicación
table('departments', 'm1', 'Divisiones político-administrativas de primer nivel.', [
    ID('INT', 'Identificador del departamento'),
    C('name', 'VARCHAR(100)', key='UK', desc='Nombre del departamento (Santander, Antioquia)')],
    ['UNIQUE uq_department_name (name)'], 'catálogo')

table('cities', 'm1', 'Municipios y ciudades de cada departamento.', [
    ID('INT', 'Identificador del municipio'),
    C('department_id', 'INT', key='FK', ref='departments.id', desc='Departamento al que pertenece'),
    C('name', 'VARCHAR(100)', desc='Nombre del municipio (Bucaramanga, Floridablanca)')],
    ['UNIQUE uq_city_department (department_id, name)'], 'catálogo')

table('document_types', 'm1', 'Tipos legales de documento de identidad.', [
    ID('INT', 'Identificador del tipo de documento'),
    C('code', 'VARCHAR(10)', key='UK', desc='Código oficial (CC, TI, CE, PAS, RC)'),
    C('name', 'VARCHAR(50)', desc='Nombre completo del tipo de documento')],
    ['UNIQUE uq_document_type_code (code)'], 'catálogo')

table('persons', 'm1', 'Super-tipo de identidad y datos demográficos base compartidos.', [
    ID('BIGINT', 'Identificador único de la persona'),
    C('document_type_id', 'INT', key='FK', ref='document_types.id', desc='Tipo de documento'),
    C('document_number', 'VARCHAR(30)', key='UK', desc='Número de identificación legal'),
    C('first_name', 'VARCHAR(100)', desc='Nombres'),
    C('last_name', 'VARCHAR(100)', desc='Apellidos'),
    C('birth_date', 'DATE', desc='Fecha de nacimiento'),
    C('gender', "ENUM('M','F','OTRO')", desc='Sexo biológico'),
    C('city_id', 'INT', key='FK', ref='cities.id', desc='Ciudad de residencia'),
    C('address', 'VARCHAR(255)', True, desc='Dirección de residencia'),
    C('phone', 'VARCHAR(30)', True, desc='Teléfono de contacto'),
    C('email', 'VARCHAR(150)', True, key='UK', desc='Correo electrónico'),
    C('created_at', 'DATETIME', default=CT, desc='Fecha de creación'),
    C('updated_at', 'DATETIME', default=CT + ' ON UPDATE', desc='Última modificación')],
    ['UNIQUE uq_person_document (document_number)', 'UNIQUE uq_person_email (email)',
     'INDEX idx_persons_name (last_name, first_name)'])

table('patients', 'm1', 'Sub-tipo clínico de pacientes atendidos (1:1 con persons).', [
    ID('BIGINT', 'Identificador único del paciente'),
    C('person_id', 'BIGINT', key='FK UK', ref='persons.id', desc='Persona asociada (1:0..1)'),
    C('blood_type', "ENUM('O+','O-','A+','A-','B+','B-','AB+','AB-')", True, desc='Grupo sanguíneo y factor Rh'),
    C('health_insurance', 'VARCHAR(100)', True, desc='Entidad Promotora de Salud (EPS / Aseguradora)'),
    C('affiliation_type', "ENUM('COTIZANTE','BENEFICIARIO','PARTICULAR','SUBSIDIADO')", default="'COTIZANTE'", desc='Tipo de afiliación'),
    C('occupation', 'VARCHAR(100)', True, desc='Ocupación o profesión'),
    C('emergency_contact_name', 'VARCHAR(100)', True, desc='Nombre del contacto de emergencia'),
    C('emergency_contact_phone', 'VARCHAR(30)', True, desc='Teléfono del contacto de emergencia'),
    C('created_at', 'DATETIME', default=CT, desc='Fecha de registro'),
    C('updated_at', 'DATETIME', default=CT + ' ON UPDATE', desc='Última modificación')],
    ['UNIQUE uq_patient_person (person_id)'])

table('patient_allergies', 'm1', 'Alergias del paciente. Tabla separada por 4FN (paciente ↠ alergia).', [
    ID('BIGINT'),
    C('patient_id', 'BIGINT', key='FK', ref='patients.id', desc='Paciente'),
    C('allergen', 'VARCHAR(150)', desc='Sustancia causante (Penicilina, Sulfas)'),
    C('reaction', 'VARCHAR(255)', True, desc='Reacción clínica manifestada'),
    C('severity', "ENUM('LEVE','MODERADA','SEVERA')", default="'MODERADA'", desc='Severidad de la reacción')],
    ['UNIQUE uq_patient_allergen (patient_id, allergen)'], 'entidad débil · 4FN')

table('patient_family_histories', 'm1', 'Antecedentes familiares. Tabla separada por 4FN (paciente ↠ antecedente familiar).', [
    ID('BIGINT'),
    C('patient_id', 'BIGINT', key='FK', ref='patients.id', desc='Paciente'),
    C('condition_name', 'VARCHAR(150)', desc='Patología (glaucoma de ángulo abierto, DM2)'),
    C('relationship', 'VARCHAR(50)', desc='Parentesco (padre, madre, hermano)'),
    C('notes', 'TEXT', True, desc='Notas clínicas')], [], 'entidad débil · 4FN')

table('patient_antecedents', 'm1', 'Antecedentes personales. Tabla separada por 4FN (paciente ↠ antecedente personal).', [
    ID('BIGINT'),
    C('patient_id', 'BIGINT', key='FK', ref='patients.id', desc='Paciente'),
    C('antecedent_type', "ENUM('PATOLOGICO','QUIRURGICO','TRAUMATICO','FARMACOLOGICO')", default="'PATOLOGICO'", desc='Categoría del antecedente'),
    C('description', 'TEXT', desc='Detalle (LASIK, hipertensión arterial)'),
    C('year_diagnosed', 'YEAR', True, desc='Año aproximado de diagnóstico')], [], 'entidad débil · 4FN')

table('glaucoma_risk_factors', 'm1', 'Factores de riesgo específicos para glaucoma (aislados en 4FN).', [
    ID('BIGINT'),
    C('patient_id', 'BIGINT', key='FK', ref='patients.id', desc='Paciente evaluado'),
    C('risk_factor', "ENUM('CCT_DELGADO','MIOPIA_ALTA','ANTECEDENTE_FAMILIAR_1ER_GRADO','HIPOTENSION_NOCTURNA','VASOESPASMO_MIGRAÑA','HEMORRAGIA_DISCO','SINDROME_PSEUDOEXFOLIATIVO','SINDROME_DISPERSION_PIGMENTARIA')", desc='Factor de riesgo estandarizado'),
    C('notes', 'VARCHAR(255)', True, desc='Observaciones del factor de riesgo')],
    ['UNIQUE uq_patient_risk_factor (patient_id, risk_factor)'], 'entidad débil · 4FN')

# MÓDULO 2: Profesionales de salud y agendamiento
table('specialties', 'm2', 'Especialidades y subespecialidades oftalmológicas.', [
    ID('INT', 'Identificador de especialidad'),
    C('name', 'VARCHAR(100)', key='UK', desc='Nombre (Glaucoma, Córnea, Retina)'),
    C('description', 'TEXT', True, desc='Descripción del área')],
    ['UNIQUE uq_specialty_name (name)'], 'catálogo')

table('healthcare_professionals', 'm2', 'Oftalmólogos, optómetras y especialistas tratantes (sub-tipo de persons).', [
    ID('BIGINT', 'Identificador del profesional'),
    C('person_id', 'BIGINT', key='FK UK', ref='persons.id', desc='Persona asociada (1:0..1)'),
    C('medical_license', 'VARCHAR(50)', key='UK', desc='Registro médico profesional'),
    C('specialty_id', 'INT', key='FK', ref='specialties.id', desc='Especialidad que ejerce'),
    C('is_active', 'BOOLEAN', default='TRUE', desc='Disponible para atender'),
    C('created_at', 'DATETIME', default=CT, desc='Fecha de registro')],
    ['UNIQUE uq_prof_person (person_id)', 'UNIQUE uq_prof_license (medical_license)'])

table('appointments', 'm2', 'Agendamiento y programación de citas oftalmológicas.', [
    ID('BIGINT', 'Identificador de la cita'),
    C('patient_id', 'BIGINT', key='FK', ref='patients.id', desc='Paciente citado'),
    C('professional_id', 'BIGINT', key='FK', ref='healthcare_professionals.id', desc='Profesional asignado'),
    C('appointment_date', 'DATETIME', desc='Fecha y hora programada'),
    C('appointment_type', "ENUM('PRIMERA_VEZ','CONTROL_GLAUCOMA','POST_QUIRURGICO','LECTURA_EXAMENES','URGENCIA')", default="'CONTROL_GLAUCOMA'", desc='Tipo de cita'),
    C('status', "ENUM('PROGRAMADA','CONFIRMADA','ATENDIDA','CANCELADA','NO_ASISTIO')", default="'PROGRAMADA'", desc='Estado de la cita'),
    C('reason', 'VARCHAR(255)', True, desc='Motivo de la cita'),
    C('created_at', 'DATETIME', default=CT, desc='Fecha de agendamiento')],
    ['INDEX idx_appointments_date (appointment_date)'])

# MÓDULO 3: Historia clínica y consultas
table('clinical_histories', 'm3', 'Expediente único del paciente (relación 1:1).', [
    ID('BIGINT', 'Identificador de la historia'),
    C('patient_id', 'BIGINT', key='FK UK', ref='patients.id', desc='Paciente dueño del expediente (1:1)'),
    C('history_number', 'VARCHAR(50)', key='UK', desc='Código institucional (HC-2026-0001)'),
    C('status', "ENUM('ACTIVA','ARCHIVADA','INACTIVA')", default="'ACTIVA'", desc='Estado del expediente'),
    C('created_at', 'DATETIME', default=CT, desc='Fecha de apertura')],
    ['UNIQUE uq_history_patient (patient_id)', 'UNIQUE uq_history_number (history_number)'])

table('medical_visits', 'm3', 'Consulta clínica realizada; eje de exámenes, diagnósticos y tratamientos.', [
    ID('BIGINT', 'Identificador de la consulta'),
    C('clinical_history_id', 'BIGINT', key='FK', ref='clinical_histories.id', desc='Historia clínica'),
    C('professional_id', 'BIGINT', key='FK', ref='healthcare_professionals.id', desc='Médico tratante'),
    C('visit_date', 'DATETIME', default=CT, desc='Fecha y hora de la atención'),
    C('reason', 'TEXT', desc='Motivo de consulta'),
    C('symptoms', 'TEXT', True, desc='Sintomatología actual'),
    C('assessment', 'TEXT', desc='Evaluación oftalmológica'),
    C('plan', 'TEXT', desc='Plan terapéutico'),
    C('is_closed', 'BOOLEAN', default='FALSE', desc='Consulta cerrada, no editable'),
    C('created_at', 'DATETIME', default=CT, desc='Creación del registro'),
    C('updated_at', 'DATETIME', default=CT + ' ON UPDATE', desc='Última modificación')],
    ['INDEX idx_visits_date (visit_date)'])

table('diagnoses', 'm3', 'Catálogo de diagnósticos CIE-10.', [
    ID('INT', 'Identificador del diagnóstico'),
    C('code', 'VARCHAR(20)', key='UK', desc='Código CIE-10 (H40.1, H40.2)'),
    C('name', 'VARCHAR(200)', desc='Nombre clínico'),
    C('is_glaucoma_type', 'BOOLEAN', default='FALSE', desc='Indica si es un tipo de glaucoma'),
    C('description', 'TEXT', True, desc='Criterios diagnósticos')],
    ['UNIQUE uq_diagnosis_code (code)'], 'catálogo')

table('visit_diagnoses', 'm3', 'Diagnósticos de cada consulta. Resuelve la relación N:M consulta–diagnóstico.', [
    ID('BIGINT'),
    C('visit_id', 'BIGINT', key='FK', ref='medical_visits.id', desc='Consulta'),
    C('diagnosis_id', 'INT', key='FK', ref='diagnoses.id', desc='Diagnóstico asignado'),
    C('is_primary', 'BOOLEAN', default='FALSE', desc='Diagnóstico principal'),
    C('notes', 'VARCHAR(255)', True, desc='Observaciones del caso')],
    ['UNIQUE uq_visit_diag (visit_id, diagnosis_id)'], 'resuelve N:M «diagnostica»')

table('clinical_documents', 'm3', 'Archivos adjuntos: retinografías, PDF de perimetría, firmas.', [
    ID('BIGINT', 'Identificador del archivo'),
    C('clinical_history_id', 'BIGINT', key='FK', ref='clinical_histories.id', desc='Historia clínica'),
    C('title', 'VARCHAR(150)', desc='Nombre del documento'),
    C('file_type', 'VARCHAR(50)', desc='Tipo MIME (application/pdf)'),
    C('file_path', 'VARCHAR(255)', desc='Ruta de almacenamiento'),
    C('uploaded_at', 'DATETIME', default=CT, desc='Fecha de carga'),
    C('deleted_by', 'VARCHAR(100)', True, desc='Usuario que lo eliminó')])

# MÓDULO 4: Exámenes oftalmológicos
table('intraocular_pressures', 'm4', 'Tonometría: presión intraocular por ojo, en mmHg.', [
    ID('BIGINT', 'Identificador de la medición'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado: derecho (OD) o izquierdo (OI)'),
    C('pressure', 'DECIMAL(5,2)', desc='Presión en mmHg'),
    C('measurement_time', 'TIME', True, desc='Hora de la toma (curva diurna)'),
    C('method', "ENUM('GOLDMANN','AIRE','PERKINS','ICARE')", default="'GOLDMANN'", desc='Tonómetro utilizado'),
    C('notes', 'VARCHAR(255)', True, desc='Observaciones')],
    ['CHECK chk_iop_pressure (pressure > 0 AND pressure <= 80)', "CHECK chk_iop_eye (eye IN ('OD','OI'))",
     'INDEX idx_iop_eye_pressure (eye, pressure)'], 'entidad débil')

table('pachymetry_exams', 'm4', 'Paquimetría: espesor corneal central (CCT) en µm.', [
    ID('BIGINT', 'Identificador del examen'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado'),
    C('corneal_thickness', 'DECIMAL(6,2)', desc='Espesor corneal en µm'),
    C('method', 'VARCHAR(50)', default="'ULTRASONICA'", desc='Técnica (ultrasónica, óptica)'),
    C('exam_date', 'DATETIME', default=CT, desc='Fecha del examen')],
    ['CHECK chk_pachy_thickness (corneal_thickness > 0 AND corneal_thickness <= 1000)',
     "CHECK chk_pachy_eye (eye IN ('OD','OI'))"], 'entidad débil')

table('gonioscopy_exams', 'm4', 'Gonioscopía: grado del ángulo iridocorneal (escala de Shaffer).', [
    ID('BIGINT', 'Identificador del examen'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado'),
    C('angle_grade', "ENUM('GRADO 0','GRADO I','GRADO II','GRADO III','GRADO IV')", desc='Grado de Shaffer'),
    C('pigmentation', "ENUM('LEVE','MODERADA','SEVERA')", default="'LEVE'", desc='Pigmentación trabecular'),
    C('findings', 'TEXT', True, desc='Sinequias, neovascularización'),
    C('exam_date', 'DATETIME', default=CT, desc='Fecha del examen')],
    ["CHECK chk_gonio_eye (eye IN ('OD','OI'))"], 'entidad débil')

table('oct_exams', 'm4', 'Tomografía de coherencia óptica: capa de fibras nerviosas (RNFL) y excavación.', [
    ID('BIGINT', 'Identificador del OCT'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado'),
    C('rnfl_average', 'DECIMAL(6,2)', desc='Espesor promedio RNFL (µm)'),
    C('rnfl_superior', 'DECIMAL(6,2)', True, desc='RNFL cuadrante superior'),
    C('rnfl_inferior', 'DECIMAL(6,2)', True, desc='RNFL cuadrante inferior'),
    C('cup_to_disc_ratio', 'DECIMAL(4,2)', True, desc='Relación excavación/disco'),
    C('interpretation', 'TEXT', True, desc='Juicio clínico'),
    C('is_validated', 'BOOLEAN', default='FALSE', desc='Validado por especialista'),
    C('exam_date', 'DATETIME', default=CT, desc='Fecha del estudio')],
    ["CHECK chk_oct_eye (eye IN ('OD','OI'))", 'CHECK chk_oct_rnfl (rnfl_average BETWEEN 0 AND 300)',
     'CHECK chk_oct_cup_disc (cup_to_disc_ratio IS NULL OR cup_to_disc_ratio BETWEEN 0 AND 1)',
     'INDEX idx_oct_exam_date (exam_date)'], 'entidad débil')

table('visual_field_exams', 'm4', 'Campimetría computarizada: índices MD, PSD y VFI.', [
    ID('BIGINT', 'Identificador del campo visual'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado'),
    C('strategy', 'VARCHAR(50)', default="'SITA-Standard 24-2'", desc='Estrategia perimétrica'),
    C('mean_deviation_md', 'DECIMAL(6,2)', desc='Desviación media (dB)'),
    C('pattern_std_deviation_psd', 'DECIMAL(6,2)', desc='Desviación estándar del patrón (dB)'),
    C('visual_field_index_vfi', 'DECIMAL(5,2)', desc='Índice de campo visual (%)'),
    C('false_positives_pct', 'DECIMAL(5,2)', True, desc='Falsos positivos (%)'),
    C('false_negatives_pct', 'DECIMAL(5,2)', True, desc='Falsos negativos (%)'),
    C('reliability', "ENUM('CONFIABLE','NO CONFIABLE')", default="'CONFIABLE'", desc='Confiabilidad del examen'),
    C('interpretation', 'TEXT', True, desc='Defecto campimétrico'),
    C('exam_date', 'DATETIME', default=CT, desc='Fecha del examen')],
    ["CHECK chk_vf_eye (eye IN ('OD','OI'))", 'CHECK chk_vf_vfi (visual_field_index_vfi BETWEEN 0 AND 100)',
     'INDEX idx_vf_exam_date (exam_date)'], 'entidad débil')

table('visual_acuity_exams', 'm4', 'Agudeza visual lejana/cercana y refracción clínica.', [
    ID('BIGINT', 'Identificador del examen de agudeza'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado'),
    C('sphere', 'DECIMAL(4,2)', True, desc='Esfera refracción (dioptrías)'),
    C('cylinder', 'DECIMAL(4,2)', True, desc='Cilindro refracción (dioptrías)'),
    C('axis', 'INT', True, desc='Eje del astigmatismo (0-180 grados)'),
    C('uncorrected_va', 'VARCHAR(20)', desc='Agudeza visual sin corrección (Snellen 20/XX)'),
    C('corrected_va', 'VARCHAR(20)', desc='Agudeza visual con corrección'),
    C('pinhole_va', 'VARCHAR(20)', True, desc='Agudeza visual con agujero estenopeico'),
    C('exam_date', 'DATETIME', default=CT, desc='Fecha del examen')],
    ["CHECK chk_va_eye (eye IN ('OD','OI'))", 'CHECK chk_va_axis (axis IS NULL OR (axis >= 0 AND axis <= 180))'], 'entidad débil')

table('biomicroscopy_exams', 'm4', 'Biomicroscopía en lámpara de hendidura: profundidad y estructuras.', [
    ID('BIGINT', 'Identificador de la biomicroscopía'), VISIT,
    C('eye', EYE2, desc='Ojo evaluado'),
    C('cornea_status', 'VARCHAR(100)', default="'TRANSPARENTE'", desc='Estado de la córnea'),
    C('anterior_chamber_depth', "ENUM('VAN_HERICK_I','VAN_HERICK_II','VAN_HERICK_III','VAN_HERICK_IV')", default="'VAN_HERICK_IV'", desc='Profundidad de cámara periférica (Van Herick)'),
    C('iris_status', 'VARCHAR(100)', default="'NORMAL'", desc='Estado del iris'),
    C('lens_status', "ENUM('TRANSPARENTE','CATARATA_NUCLEAR','CATARATA_CORTICAL','CATARATA_SUBCAPSULAR','PSEUDOFAQUICO','AFAQUICO')", default="'TRANSPARENTE'", desc='Estado del cristalino'),
    C('pseudoexfoliation_present', 'BOOLEAN', default='FALSE', desc='Presencia de material pseudoexfoliativo'),
    C('pigment_dispersion_present', 'BOOLEAN', default='FALSE', desc='Presencia de dispersión pigmentaria'),
    C('exam_date', 'DATETIME', default=CT, desc='Fecha del examen')],
    ["CHECK chk_biomicro_eye (eye IN ('OD','OI'))"], 'entidad débil')

# MÓDULO 5: Tratamientos y procedimientos
table('medication_classes', 'm5', 'Catálogo de familias farmacológicas para glaucoma (3FN).', [
    ID('INT', 'Identificador de la clase farmacológica'),
    C('name', 'VARCHAR(100)', key='UK', desc='Nombre de la familia farmacológica'),
    C('mechanism_of_action', 'TEXT', True, desc='Mecanismo de acción hipotensora')],
    ['UNIQUE uq_med_class_name (name)'], 'catálogo')

table('medications', 'm5', 'Catálogo de medicamentos hipotensores oculares.', [
    ID('INT', 'Identificador del medicamento'),
    C('medication_class_id', 'INT', key='FK', ref='medication_classes.id', desc='Clase farmacológica (3FN)'),
    C('name', 'VARCHAR(150)', key='UK', desc='Nombre comercial'),
    C('generic_name', 'VARCHAR(150)', desc='Denominación común internacional'),
    C('concentration', 'VARCHAR(50)', desc='Concentración (0.005%, 0.5%)'),
    C('presentation', 'VARCHAR(100)', default="'Frasco gotero x 2.5 ml'", desc='Presentación farmacéutica'),
    C('is_active', 'BOOLEAN', default='TRUE', desc='Vigente en el catálogo')],
    ['UNIQUE uq_medication_name (name)'], 'catálogo')

table('treatments', 'm5', 'Prescripción farmacológica emitida en una consulta.', [
    ID('BIGINT', 'Identificador de la prescripción'), VISIT,
    C('medication_id', 'INT', key='FK', ref='medications.id', desc='Medicamento prescrito'),
    C('eye', EYE3, default="'AMBOS'", desc='Ojo tratado'),
    C('dosage', 'VARCHAR(100)', desc='Dosis (1 gota)'),
    C('frequency', 'VARCHAR(100)', desc='Frecuencia (cada 12 horas)'),
    C('start_date', 'DATE', desc='Inicio del tratamiento'),
    C('end_date', 'DATE', True, desc='Fin del tratamiento'),
    C('is_active', 'BOOLEAN', default='TRUE', desc='Tratamiento vigente'),
    C('notes', 'TEXT', True, desc='Indicaciones o efectos adversos')],
    ['CHECK chk_treatment_dates (end_date IS NULL OR end_date >= start_date)',
     'INDEX idx_treatments_active (is_active)'])

table('procedure_types', 'm5', 'Catálogo de procedimientos quirúrgicos y láser CUPS (3FN).', [
    ID('INT', 'Identificador del tipo de procedimiento'),
    C('code', 'VARCHAR(20)', key='UK', desc='Código oficial o CUPS'),
    C('name', 'VARCHAR(150)', desc='Nombre del procedimiento'),
    C('category', "ENUM('LASER','QUIRURGICO','DIAGNOSTICO')", default="'QUIRURGICO'", desc='Categoría del procedimiento'),
    C('description', 'TEXT', True, desc='Descripción técnica')],
    ['UNIQUE uq_procedure_type_code (code)'], 'catálogo')

table('procedures', 'm5', 'Procedimientos láser o quirúrgicos realizados (SLT, trabeculectomía).', [
    ID('BIGINT', 'Identificador del procedimiento'), VISIT,
    C('procedure_type_id', 'INT', key='FK', ref='procedure_types.id', desc='Tipo de procedimiento realizado (3FN)'),
    C('eye', EYE3, desc='Ojo intervenido'),
    C('procedure_date', 'DATETIME', default=CT, desc='Fecha y hora'),
    C('complications', 'TEXT', True, desc='Complicaciones'),
    C('results', 'TEXT', True, desc='Resultados inmediatos')])

# MÓDULO 6: Seguimiento de glaucoma
table('glaucoma_records', 'm6', 'Ficha de glaucoma del paciente: PIO objetivo y estadio.', [
    ID('BIGINT', 'Identificador de la ficha'),
    C('patient_id', 'BIGINT', key='FK UK', ref='patients.id', desc='Paciente (máximo una ficha)'),
    C('target_iop_od', 'DECIMAL(5,2)', desc='PIO objetivo ojo derecho (mmHg)'),
    C('target_iop_oi', 'DECIMAL(5,2)', desc='PIO objetivo ojo izquierdo (mmHg)'),
    C('clinical_stage', "ENUM('SOSPECHA','INICIAL','MODERADO','AVANZADO','TERMINAL')", default="'SOSPECHA'", desc='Estadio clínico'),
    C('diagnosis_date', 'DATE', desc='Fecha de confirmación'),
    C('notes', 'TEXT', True, desc='Factores de riesgo')],
    ['UNIQUE uq_glaucoma_patient (patient_id)', 'CHECK chk_target_iop_od (target_iop_od > 0 AND target_iop_od <= 50)',
     'CHECK chk_target_iop_oi (target_iop_oi > 0 AND target_iop_oi <= 50)'])

table('glaucoma_controls', 'm6', 'Control periódico de progresión y adherencia.', [
    ID('BIGINT', 'Identificador del control'),
    C('glaucoma_record_id', 'BIGINT', key='FK', ref='glaucoma_records.id', desc='Ficha de glaucoma'),
    C('visit_id', 'BIGINT', key='FK', ref='medical_visits.id', desc='Consulta del control'),
    C('control_date', 'DATE', desc='Fecha del control'),
    C('is_progression_detected', 'BOOLEAN', default='FALSE', desc='Progresión estructural o funcional'),
    C('adherence_score', "ENUM('EXCELENTE','BUENA','REGULAR','MALA')", default="'BUENA'", desc='Adherencia a las gotas'),
    C('notes', 'TEXT', True, desc='Ajustes al tratamiento')])

# MÓDULO 7: Auditoría y respaldo
table('audit_logs', 'm7', 'Bitácora inmutable que llenan los triggers. Se relaciona con cualquier tabla por (table_name, record_id), sin FK.', [
    ID('BIGINT', 'Identificador del evento'),
    C('table_name', 'VARCHAR(100)', desc='Tabla afectada'),
    C('record_id', 'BIGINT', desc='id del registro afectado'),
    C('action', "ENUM('INSERT','UPDATE','DELETE','ALERT')", desc='Operación ejecutada'),
    C('old_values', 'JSON', True, desc='Estado anterior'),
    C('new_values', 'JSON', True, desc='Estado posterior'),
    C('performed_by', 'VARCHAR(100)', default="'SYSTEM'", desc='Usuario o proceso'),
    C('changed_at', 'DATETIME', default=CT, desc='Momento del cambio')],
    ['INDEX idx_audit_table_date (table_name, changed_at)'], 'auditoría')

BACKUPS = [('persons_backup', 'persons', 'trg_bd_persons_backup'),
           ('patients_backup', 'patients', 'trg_bd_patients_backup'),
           ('medical_visits_backup', 'medical_visits', 'trg_bd_visits_backup'),
           ('treatments_backup', 'treatments', 'trg_bd_treatments_backup'),
           ('oct_exams_backup', 'oct_exams', 'trg_bd_oct_delete_backup')]

for bname, src, trg in BACKUPS:
    cols = []
    for c in T[src]['cols']:
        k = ' '.join(x for x in c['key'].split() if x != 'FK')
        cols.append(dict(c, key=k, ref='', desc=c['desc']))
    table(bname, 'm7', f'Copia de {src} antes de un DELETE (trigger {trg}). Se crea con CREATE TABLE … LIKE, que no copia las FK.',
          cols, [f'CREATE TABLE {bname} LIKE {src}'], 'respaldo')

# ----------------------------------------------------------------------------- relaciones (FK)
# (hija, columna FK, padre, verbo, ON DELETE)
FKS = [
    ('cities', 'department_id', 'departments', 'pertenece a', 'RESTRICT'),
    ('persons', 'document_type_id', 'document_types', 'identifica', 'RESTRICT'),
    ('persons', 'city_id', 'cities', 'reside en', 'RESTRICT'),
    ('patients', 'person_id', 'persons', 'especializa', 'RESTRICT'),
    ('patient_allergies', 'patient_id', 'patients', 'presenta', 'CASCADE'),
    ('patient_family_histories', 'patient_id', 'patients', 'reporta', 'CASCADE'),
    ('patient_antecedents', 'patient_id', 'patients', 'registra', 'CASCADE'),
    ('glaucoma_risk_factors', 'patient_id', 'patients', 'pondera', 'CASCADE'),
    ('healthcare_professionals', 'person_id', 'persons', 'identifica', 'RESTRICT'),
    ('healthcare_professionals', 'specialty_id', 'specialties', 'ejerce', 'RESTRICT'),
    ('appointments', 'patient_id', 'patients', 'agenda', 'CASCADE'),
    ('appointments', 'professional_id', 'healthcare_professionals', 'atiende', 'RESTRICT'),
    ('clinical_histories', 'patient_id', 'patients', 'tiene', 'RESTRICT'),
    ('medical_visits', 'clinical_history_id', 'clinical_histories', 'acumula', 'RESTRICT'),
    ('medical_visits', 'professional_id', 'healthcare_professionals', 'atiende', 'RESTRICT'),
    ('visit_diagnoses', 'visit_id', 'medical_visits', 'diagnostica', 'CASCADE'),
    ('visit_diagnoses', 'diagnosis_id', 'diagnoses', 'diagnostica', 'RESTRICT'),
    ('clinical_documents', 'clinical_history_id', 'clinical_histories', 'adjunta', 'CASCADE'),
    ('intraocular_pressures', 'visit_id', 'medical_visits', 'mide', 'CASCADE'),
    ('pachymetry_exams', 'visit_id', 'medical_visits', 'evalúa', 'CASCADE'),
    ('gonioscopy_exams', 'visit_id', 'medical_visits', 'inspecciona', 'CASCADE'),
    ('oct_exams', 'visit_id', 'medical_visits', 'escanea', 'CASCADE'),
    ('visual_field_exams', 'visit_id', 'medical_visits', 'cuantifica', 'CASCADE'),
    ('visual_acuity_exams', 'visit_id', 'medical_visits', 'determina', 'CASCADE'),
    ('biomicroscopy_exams', 'visit_id', 'medical_visits', 'examina', 'CASCADE'),
    ('medications', 'medication_class_id', 'medication_classes', 'clasifica', 'RESTRICT'),
    ('treatments', 'visit_id', 'medical_visits', 'prescribe', 'CASCADE'),
    ('treatments', 'medication_id', 'medications', 'suministra', 'RESTRICT'),
    ('procedures', 'visit_id', 'medical_visits', 'realiza', 'CASCADE'),
    ('procedures', 'procedure_type_id', 'procedure_types', 'tipifica', 'RESTRICT'),
    ('glaucoma_records', 'patient_id', 'patients', 'posee', 'RESTRICT'),
    ('glaucoma_controls', 'glaucoma_record_id', 'glaucoma_records', 'monitorea', 'CASCADE'),
    ('glaucoma_controls', 'visit_id', 'medical_visits', 'asocia', 'CASCADE'),
]

def col_of(t, c):
    return next(x for x in T[t]['cols'] if x['name'] == c)
def is_unique_fk(t, c):
    return 'UK' in col_of(t, c)['key'].split()
for ch, c, p, v, od in FKS:
    T[ch]['cons'].append(f'FOREIGN KEY ({c}) REFERENCES {p}(id) ON UPDATE CASCADE ON DELETE {od}')
assert len(FKS) == 33

# ----------------------------------------------------------------------------- utilidades SVG
CW = 7.25  # ancho aproximado de un carácter mono a 12px

def short_type(t):
    if t.startswith('ENUM'):
        return 'ENUM'
    return t.replace(' AUTO_INCREMENT', '')

def badges(c):
    ks = c['key'].split()
    if 'PK' in ks and 'FK' in ks: return 'PF'
    if 'PK' in ks: return 'PK'
    if 'FK' in ks: return 'FK'
    if 'UK' in ks: return 'UK'
    return ''

class Bounds:
    def __init__(s): s.x0 = s.y0 = 1e9; s.x1 = s.y1 = -1e9
    def add(s, x0, y0, x1, y1):
        s.x0 = min(s.x0, x0); s.y0 = min(s.y0, y0); s.x1 = max(s.x1, x1); s.y1 = max(s.y1, y1)

def svg_wrap(body, b, label, pad=36):
    w = math.ceil(b.x1 - b.x0 + 2 * pad); h = math.ceil(b.y1 - b.y0 + 2 * pad)
    tx = pad - b.x0; ty = pad - b.y0
    return (f"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 {w} {h}' width='{w}' height='{h}' role='img' aria-label='{E(label)}'>"
            f"<g transform='translate({tx:.1f},{ty:.1f})'>{body}</g></svg>"), w

# ----------------------------------------------------------------------------- DER (pata de gallo)
ROW = 19; HEAD = 30; PADX = 10

def der_box_width(t, stub):
    cols = T[t]['cols'][:1] if stub else T[t]['cols']
    m = len(t) * 7.9 + 2 * PADX
    for c in cols:
        m = max(m, 2 * PADX + 24 + len(c['name']) * CW + 18 + len(short_type(c['type'])) * CW)
    return math.ceil(m)

DER_LAYOUT = {
    'm1': [['departments'], ['document_types', 'cities'], ['persons'], ['patients'],
           ['patient_allergies', 'patient_family_histories', 'patient_antecedents', 'glaucoma_risk_factors']],
    'm2': [['persons', 'specialties'], ['healthcare_professionals'], ['appointments'], ['patients']],
    'm3': [['patients', 'healthcare_professionals'], ['clinical_histories'], ['medical_visits', 'clinical_documents'],
           ['visit_diagnoses'], ['diagnoses']],
    'm4': [['intraocular_pressures', 'pachymetry_exams', 'gonioscopy_exams'], ['medical_visits'],
           ['oct_exams', 'visual_field_exams'], ['visual_acuity_exams', 'biomicroscopy_exams']],
    'm5': [['medication_classes', 'procedure_types'], ['medications'], ['treatments', 'procedures'], ['medical_visits']],
    'm6': [['patients'], ['glaucoma_records', 'glaucoma_controls'], ['medical_visits']],
    'm7': [['audit_logs'], ['persons_backup', 'patients_backup', 'medical_visits_backup'], ['treatments_backup', 'oct_exams_backup']],
}

DER_DY = {
    ('m1', 'departments'): 154, ('m1', 'cities'): 40,
    ('m2', 'specialties'): 114, ('m2', 'appointments'): 40,
    ('m3', 'healthcare_professionals'): 150, ('m3', 'clinical_documents'): 30, ('m3', 'diagnoses'): 38,
    ('m4', 'medical_visits'): 120, ('m5', 'medical_visits'): 60, ('m5', 'medications'): 38,
    ('m6', 'medical_visits'): 170
}

def render_der(mod):
    cols = DER_LAYOUT[mod]
    stub = lambda t: T[t]['mod'] != mod
    colw = [max(der_box_width(t, stub(t)) for t in c) for c in cols]
    where = {t: i for i, c in enumerate(cols) for t in c}
    edges = [f for f in FKS if f[0] in where and T[f[0]]['mod'] == mod]
    def gap_of(e):
        ci, pi = where[e[0]], where[e[2]]
        if pi > ci: return ci
        if pi < ci: return ci - 1
        return ci
    gaps = {}
    for e in edges: gaps.setdefault(gap_of(e), []).append(e)
    gapw = [70 + 16 * len(gaps.get(i, [])) for i in range(len(cols))]
    xs = []; x = 0
    for i, w in enumerate(colw):
        xs.append(x); x += w + gapw[i]
    pos = {}
    for i, c in enumerate(cols):
        y = 0
        for t in c:
            y += DER_DY.get((mod, t), 0)
            n = 1 if stub(t) else len(T[t]['cols'])
            h = HEAD + n * ROW + 8
            pos[t] = (xs[i], y, colw[i], h)
            y += h + 40
    b = Bounds(); out = []
    rowy = lambda t, cname: pos[t][1] + HEAD + ([c['name'] for c in T[t]['cols']].index(cname)) * ROW + ROW / 2 + 2
    gi = {}; marks = []
    for e in sorted(edges, key=lambda e: (gap_of(e), rowy(e[0], e[1]))):
        ch, c, p, verb, od = e
        g = gap_of(e); k = gi.get(g, 0); gi[g] = k + 1
        chx, _, chw, _ = pos[ch]; px, _, pw, _ = pos[p]
        yc = rowy(ch, c); yp = rowy(p, 'id')
        ci, pi = where[ch], where[p]
        if pi > ci:
            x0, s0 = chx + chw, 1; x1, s1 = px, -1
            cx = xs[ci] + colw[ci] + 30 + k * 16
        elif pi < ci:
            x0, s0 = chx, -1; x1, s1 = px + pw, 1
            cx = xs[ci] - 30 - k * 16
        else:
            x0, s0 = chx + chw, 1; x1, s1 = px + pw, 1
            cx = xs[ci] + colw[ci] + 30 + k * 16
        d = f'M{x0:.1f},{yc:.1f} H{cx:.1f} V{yp:.1f} H{x1:.1f}'
        uniq = is_unique_fk(ch, c)
        card = '1 : 0..1' if uniq else '1 : N'
        out.append(f"<path class='edge nonid' d='{d}'><title>{E(ch)}.{E(c)} → {E(p)}.id ({E(verb)}) · {card} · ON DELETE {od}</title></path>")
        marks.append(f"<line class='mk' x1='{x1 + s1 * 9:.1f}' y1='{yp - 6:.1f}' x2='{x1 + s1 * 9:.1f}' y2='{yp + 6:.1f}'/>"
                     f"<line class='mk' x1='{x1 + s1 * 14:.1f}' y1='{yp - 6:.1f}' x2='{x1 + s1 * 14:.1f}' y2='{yp + 6:.1f}'/>")
        if uniq:
            marks.append(f"<line class='mk' x1='{x0 + s0 * 9:.1f}' y1='{yc - 6:.1f}' x2='{x0 + s0 * 9:.1f}' y2='{yc + 6:.1f}'/>"
                         f"<circle class='mkc' cx='{x0 + s0 * 18:.1f}' cy='{yc:.1f}' r='4.2'/>")
        else:
            marks.append(f"<path class='mk' d='M{x0:.1f},{yc - 6:.1f} L{x0 + s0 * 12:.1f},{yc:.1f} L{x0:.1f},{yc + 6:.1f}'/>"
                         f"<circle class='mkc' cx='{x0 + s0 * 18:.1f}' cy='{yc:.1f}' r='4.2'/>")
        b.add(min(x0, cx, x1) - 4, min(yc, yp) - 8, max(x0, cx, x1) + 4, max(yc, yp) + 8)
    out += marks
    for t, (x, y, w, h) in pos.items():
        color = MODS[T[t]['mod']][1]
        st = stub(t)
        rows = T[t]['cols'][:1] if st else T[t]['cols']
        g = [f"<g class='ent' data-t='{E(t)}'><title>{E(t)} — {E(T[t]['desc'])}{' (módulo ' + T[t]['mod'][1] + ')' if st else ''}&#10;Clic: ver sus atributos en el explorador</title>"]
        g.append(f"<rect class='box{' stub' if st else ''}' x='{x}' y='{y}' width='{w}' height='{h}' rx='6'/>")
        if st:
            g.append(f"<rect x='{x}' y='{y}' width='{w}' height='{HEAD}' rx='6' fill='{color}' fill-opacity='0.14'/>")
            g.append(f"<text class='fg ttl' x='{x + PADX}' y='{y + 20}' font-size='14'>{E(t)}</text>")
        else:
            g.append(f"<rect x='{x}' y='{y}' width='{w}' height='{HEAD}' rx='6' fill='{color}'/>"
                     f"<rect x='{x}' y='{y + HEAD - 6}' width='{w}' height='6' fill='{color}'/>")
            g.append(f"<text class='ttl' x='{x + PADX}' y='{y + 20}' font-size='14' fill='#FFFFFF'>{E(t)}</text>")
        g.append('</g>')
        for i, c in enumerate(rows):
            ry = y + HEAD + i * ROW
            if i % 2 == 1:
                g.append(f"<rect class='alt' x='{x + 1}' y='{ry}' width='{w - 2}' height='{ROW}'/>")
            bd = badges(c)
            ty = ry + 14
            if bd:
                cls = 'pk' if bd in ('PK', 'PF') else ('fk' if bd == 'FK' else 'mu')
                g.append(f"<text class='{cls}' x='{x + PADX}' y='{ty}' font-size='10' font-weight='700'>{bd}</text>")
            ncls = 'pk' if bd in ('PK', 'PF') else ('fk' if bd == 'FK' else 'fg')
            extra = " text-decoration='underline'" if bd in ('PK', 'PF') else ''
            nm = c['name'] + ('' if not c['null'] else '?')
            g.append(f"<text class='{ncls}' x='{x + PADX + 24}' y='{ty}' font-size='12'{extra}>{E(c['name'])}"
                     f"{'<tspan class="mu">?</tspan>' if c['null'] else ''}<title>{E(c['type'])}{' NULL' if c['null'] else ' NOT NULL'}{(' DEFAULT ' + c['default']) if c['default'] else ''}</title></text>")
            g.append(f"<text class='mu' x='{x + w - PADX}' y='{ty}' font-size='11' text-anchor='end'>{E(short_type(c['type']))}</text>")
        out.append(''.join(g))
        b.add(x, y, x + w, y + h)
    svg, w = svg_wrap(''.join(out), b, f'DER — {MODS[mod][0]}', pad=24)
    return svg, w, len([t for t in pos if not stub(t)])

# ----------------------------------------------------------------------------- Modelo conceptual (Chen)
CHEN = {
    'm1': dict(ents={'departments': (0, 760), 'cities': (0, 500), 'document_types': (0, 100),
                     'persons': (520, 300), 'patients': (1080, 300),
                     'patient_allergies': (1600, 100), 'patient_family_histories': (1600, 300),
                     'patient_antecedents': (1600, 500), 'glaucoma_risk_factors': (1600, 700)},
               rels=[('pertenece a', 'cities', 'N', 'departments', '1', None, None),
                     ('documenta', 'document_types', '1', 'persons', 'N', None, None),
                     ('reside en', 'cities', '1', 'persons', 'N', None, None),
                     ('especializa', 'persons', '1', 'patients', '0..1', None, None),
                     ('presenta', 'patients', '1', 'patient_allergies', 'N', None, None),
                     ('reporta', 'patients', '1', 'patient_family_histories', 'N', None, None),
                     ('registra', 'patients', '1', 'patient_antecedents', 'N', None, None),
                     ('pondera', 'patients', '1', 'glaucoma_risk_factors', 'N', None, None)]),
    'm2': dict(ents={'persons': (0, 150), 'specialties': (520, 0), 'healthcare_professionals': (520, 300),
                     'appointments': (1080, 300), 'patients': (1080, 0)},
               rels=[('ejerce', 'healthcare_professionals', 'N', 'specialties', '1', None, None),
                     ('identifica', 'persons', '1', 'healthcare_professionals', '0..1', None, None),
                     ('agenda', 'patients', '1', 'appointments', 'N', None, None),
                     ('atiende', 'healthcare_professionals', '1', 'appointments', 'N', None, None)]),
    'm3': dict(ents={'patients': (0, 0), 'clinical_histories': (520, 0), 'clinical_documents': (1040, 0),
                     'healthcare_professionals': (0, 300), 'medical_visits': (520, 300), 'diagnoses': (1040, 300)},
               rels=[('tiene', 'patients', '1', 'clinical_histories', '1', None, None),
                     ('adjunta', 'clinical_histories', '1', 'clinical_documents', 'N', None, None),
                     ('acumula', 'clinical_histories', '1', 'medical_visits', 'N', None, None),
                     ('atiende', 'healthcare_professionals', '1', 'medical_visits', 'N', None, None),
                     ('diagnostica', 'medical_visits', 'N', 'diagnoses', 'M', None, ['is_primary', 'notes'])]),
    'm4': dict(ents={'medical_visits': (520, 350), 'intraocular_pressures': (0, 60), 'pachymetry_exams': (0, 350),
                     'gonioscopy_exams': (0, 640), 'oct_exams': (1040, 60), 'visual_field_exams': (1040, 350),
                     'visual_acuity_exams': (520, 80), 'biomicroscopy_exams': (1040, 640)},
               rels=[('mide', 'medical_visits', '1', 'intraocular_pressures', 'N', None, None),
                     ('evalúa', 'medical_visits', '1', 'pachymetry_exams', 'N', None, None),
                     ('inspecciona', 'medical_visits', '1', 'gonioscopy_exams', 'N', None, None),
                     ('escanea', 'medical_visits', '1', 'oct_exams', 'N', None, None),
                     ('cuantifica', 'medical_visits', '1', 'visual_field_exams', 'N', None, None),
                     ('determina', 'medical_visits', '1', 'visual_acuity_exams', 'N', None, None),
                     ('examina', 'medical_visits', '1', 'biomicroscopy_exams', 'N', None, None)]),
    'm5': dict(ents={'medication_classes': (0, 0), 'medications': (520, 0), 'treatments': (1040, 0),
                     'procedure_types': (0, 350), 'procedures': (520, 350), 'medical_visits': (1040, 350)},
               rels=[('clasifica', 'medication_classes', '1', 'medications', 'N', None, None),
                     ('suministra', 'medications', '1', 'treatments', 'N', None, None),
                     ('prescribe', 'medical_visits', '1', 'treatments', 'N', None, None),
                     ('tipifica', 'procedure_types', '1', 'procedures', 'N', None, None),
                     ('realiza', 'medical_visits', '1', 'procedures', 'N', None, None)]),
    'm6': dict(ents={'patients': (0, 0), 'glaucoma_records': (520, 0), 'glaucoma_controls': (520, 300), 'medical_visits': (1040, 300)},
               rels=[('posee', 'patients', '1', 'glaucoma_records', '0..1', None, None),
                     ('monitorea', 'glaucoma_records', '1', 'glaucoma_controls', 'N', None, None),
                     ('asocia', 'medical_visits', '1', 'glaucoma_controls', 'N', None, None)]),
}
WEAK = {t for t in T if T[t]['tag'].startswith('entidad débil')}

def ent_w(name): return max(130, len(name) * 8 + 30)

def clip_rect(cx, cy, hw, hh, dx, dy):
    tx = hw / abs(dx) if dx else 1e9; ty = hh / abs(dy) if dy else 1e9
    t = min(tx, ty); return cx + dx * t, cy + dy * t

def clip_diamond(cx, cy, hw, hh, dx, dy):
    t = 1 / (abs(dx) / hw + abs(dy) / hh); return cx + dx * t, cy + dy * t

def render_chen(mod):
    spec = CHEN[mod]; ents = spec['ents']
    b = Bounds(); lines = []; shapes = []; cards = []
    for verb, A, ca, B, cb, dpos, attrs in spec['rels']:
        (ax, ay), (bx, by) = ents[A], ents[B]
        dx_, dy_ = dpos or ((ax + bx) / 2, (ay + by) / 2)
        hw = max(50, len(verb) * 7.2 / 2 + 26); hh = 27
        for (ex, ey), name, card in (((ax, ay), A, ca), ((bx, by), B, cb)):
            ux, uy = dx_ - ex, dy_ - ey; L = math.hypot(ux, uy); ux /= L; uy /= L
            sx, sy = clip_rect(ex, ey, ent_w(name) / 2, 21, ux, uy)
            tx, ty = clip_diamond(dx_, dy_, hw, hh, -ux, -uy)
            lines.append(f"<line class='cl' x1='{sx:.1f}' y1='{sy:.1f}' x2='{tx:.1f}' y2='{ty:.1f}'/>")
            nx, ny = -uy, ux
            if ny > 0.01 or (abs(ny) <= 0.01 and nx < 0): nx, ny = -nx, -ny
            lx, ly = sx + ux * 22 + nx * 13, sy + uy * 22 + ny * 13 + 4
            cards.append(f"<text class='fg cd' x='{lx:.1f}' y='{ly:.1f}' font-size='12' font-weight='700' text-anchor='middle'>{card}</text>")
            b.add(lx - 14, ly - 12, lx + 14, ly + 4)
        if attrs:
            ax_, ay_ = dx_, dy_ + 100
            aw = max(len(a) for a in attrs) * 7 + 28; ah = 20 + 15 * len(attrs)
            lines.append(f"<line class='dot' x1='{dx_}' y1='{dy_ + hh}' x2='{ax_}' y2='{ay_ - ah / 2}'/>")
            shapes.append(f"<rect class='attr' x='{ax_ - aw / 2:.1f}' y='{ay_ - ah / 2:.1f}' width='{aw:.1f}' height='{ah}' rx='10'/>")
            for i, a in enumerate(attrs):
                shapes.append(f"<text class='mu' x='{ax_}' y='{ay_ - ah / 2 + 22 + 15 * i:.1f}' font-size='11' text-anchor='middle'>{E(a)}</text>")
            b.add(ax_ - aw / 2, ay_ - ah / 2, ax_ + aw / 2, ay_ + ah / 2)
        diamond = (f"<polygon class='rel' points='{dx_},{dy_ - hh} {dx_ + hw:.1f},{dy_} {dx_},{dy_ + hh} {dx_ - hw:.1f},{dy_}'/>"
                   f"<text class='fg' x='{dx_}' y='{dy_ + 4}' font-size='12' text-anchor='middle'>{E(verb)}</text>")
        assoc = [t for t in T if {p for ch, c, p, v, od in FKS if ch == t} == {A, B}] if attrs else []
        if assoc:
            t = assoc[0]
            diamond = (f"<g class='ent' data-t='{E(t)}'><title>{E(t)} — {E(T[t]['desc'])}&#10;Atributos: "
                       f"{E(', '.join(c['name'] for c in T[t]['cols']))}&#10;Clic: ver en el explorador</title>{diamond}</g>")
        shapes.append(diamond)
        b.add(dx_ - hw, dy_ - hh, dx_ + hw, dy_ + hh)
    for name, (ex, ey) in ents.items():
        w = ent_w(name); own = T[name]['mod'] == mod; color = MODS[T[name]['mod']][1]
        attrs = ', '.join(c['name'] for c in T[name]['cols'])
        g = [f"<g class='ent' data-t='{E(name)}'><title>{E(name)} — {E(T[name]['desc'])}{'' if own else ' (módulo ' + T[name]['mod'][1] + ')'}&#10;Atributos: {E(attrs)}&#10;Clic: ver en el explorador</title>",
             f"<rect class='sf' x='{ex - w / 2:.1f}' y='{ey - 21}' width='{w}' height='42'/>"]
        if own:
            g.append(f"<rect x='{ex - w / 2:.1f}' y='{ey - 21}' width='{w}' height='42' fill='{color}' fill-opacity='0.16' stroke='{color}' stroke-width='2'/>")
            if name in WEAK:
                g.append(f"<rect x='{ex - w / 2 + 4:.1f}' y='{ey - 17}' width='{w - 8}' height='34' fill='none' stroke='{color}' stroke-width='1.2'/>")
        else:
            g.append(f"<rect x='{ex - w / 2:.1f}' y='{ey - 21}' width='{w}' height='42' fill='{color}' fill-opacity='0.06' stroke='{color}' stroke-width='1.4' stroke-dasharray='6 4'/>")
        g.append(f"<text class='fg' x='{ex}' y='{ey + 4.5}' font-size='13' font-weight='600' text-anchor='middle'>{E(name)}</text></g>")
        shapes.append(''.join(g)); b.add(ex - w / 2, ey - 21, ex + w / 2, ey + 21)
    svg, w = svg_wrap(''.join(lines + shapes + cards), b, f'Modelo conceptual — {MODS[mod][0]}', pad=40)
    return svg, w

def render_chen_m7():
    b = Bounds(); out = []; color = MODS['m7'][1]
    def ent(name, x, y, own=True, label=None):
        label = label or name; w = ent_w(label)
        if own:
            out.append(f"<g class='ent' data-t='{E(name)}'><title>{E(name)} — {E(T[name]['desc'])}&#10;Clic: ver en el explorador</title><rect class='sf' x='{x - w / 2:.1f}' y='{y - 21}' width='{w}' height='42'/>"
                       f"<rect x='{x - w / 2:.1f}' y='{y - 21}' width='{w}' height='42' fill='{color}' fill-opacity='0.16' stroke='{color}' stroke-width='2'/>"
                       f"<text class='fg' x='{x}' y='{y + 4.5}' font-size='13' font-weight='600' text-anchor='middle'>{E(label)}</text></g>")
        else:
            c2 = MODS[T[name]['mod']][1] if name in T else color
            out.append(f"<g><rect class='sf' x='{x - w / 2:.1f}' y='{y - 21}' width='{w}' height='42'/>"
                       f"<rect x='{x - w / 2:.1f}' y='{y - 21}' width='{w}' height='42' fill='{c2}' fill-opacity='0.06' stroke='{c2}' stroke-width='1.4' stroke-dasharray='6 4'/>"
                       f"<text class='fg' x='{x}' y='{y + 4.5}' font-size='13' font-weight='600' text-anchor='middle'>{E(label)}</text></g>")
        b.add(x - w / 2, y - 21, x + w / 2, y + 21)
        return w
    def link(x0, x1, y, text):
        out.insert(0, f"<line class='dot' x1='{x0}' y1='{y}' x2='{x1}' y2='{y}'/>")
        out.append(f"<text class='mu cd' x='{(x0 + x1) / 2}' y='{y - 7}' font-size='11' text-anchor='middle'>{E(text)}</text>")
    wa = ent('audit_logs', 620, 0); ws = ent('audit_logs', 0, 0, own=False, label='cualquier tabla auditada')
    link(ws / 2, 620 - wa / 2, 0, 'triggers AFTER INSERT / UPDATE / DELETE')
    for i, (bn, src, trg) in enumerate(BACKUPS):
        y = 130 + i * 90
        w1 = ent(src, 0, y, own=False); w2 = ent(bn, 620, y)
        link(w1 / 2, 620 - w2 / 2, y, f'{trg} (BEFORE DELETE)')
    svg, w = svg_wrap(''.join(out), b, 'Modelo conceptual — Auditoría y respaldo', pad=40)
    return svg, w

# ----------------------------------------------------------------------------- vista relacional
def render_rel(mod):
    cards = []
    for t in [x for x in T if T[x]['mod'] == mod]:
        d = T[t]
        parts = []
        for col in d['cols']:
            ks = col['key'].split()
            if 'PK' in ks: parts.append(f'<span class="pk">{E(col["name"])}</span>')
            elif 'FK' in ks: parts.append(f'<span class="fk">{E(col["name"])}</span>')
            else: parts.append(E(col['name']))
        rows = []
        for col in d['cols']:
            kk = ''.join(f'<span class="k k-{k.lower()}">{k}</span>' for k in col['key'].split())
            rows.append(f'<tr><td class="mono">{E(col["name"])}</td><td class="mono t">{E(col["type"])}</td>'
                        f'<td>{"Sí" if col["null"] else "No"}</td><td>{kk}</td><td class="mono r">{E(col["ref"])}</td>'
                        f'<td class="mono t">{E(col["default"])}</td><td class="dsc">{E(col["desc"])}</td></tr>')
        tag = f'<span class="tag">{E(d["tag"])}</span>' if d['tag'] else ''
        cons = ''.join(f'<li class="mono">{E(x)}</li>' for x in d['cons'])
        cards.append(f'<article class="tcard" id="t-{t}"><header><h4>{E(t)}</h4><span class="hdr">{tag}<button type="button" class="xlink" data-t="{t}">Explorar →</button></span></header>'
                     f'<p class="desc">{E(d["desc"])}</p>'
                     f'<code class="rn"><b>{E(t)}</b>({ ", ".join(parts) })</code>'
                     '<div class="scroll"><table><thead><tr><th>Atributo</th><th>Tipo</th><th>Nulo</th><th>Clave</th><th>Referencia</th><th>Default</th><th>Descripción</th></tr></thead>'
                     f'<tbody>{"".join(rows)}</tbody></table></div>'
                     + (f'<ul class="cons">{cons}</ul>' if cons else '') + '</article>')
    return f'<div class="cards">{"".join(cards)}</div>'

# ----------------------------------------------------------------------------- mapa general
def render_map():
    W, H0 = 420, 0
    out = []
    def box(m, x, y, w, h):
        name, color = MODS[m]; ts = [t for t in T if T[t]['mod'] == m]
        s = [f"<rect class='sf' x='{x}' y='{y}' width='{w}' height='{h}' rx='10'/>",
             f"<rect x='{x}' y='{y}' width='{w}' height='{h}' rx='10' fill='{color}' fill-opacity='0.07' stroke='{color}' stroke-width='2'/>",
             f"<rect x='{x}' y='{y}' width='{w}' height='36' rx='10' fill='{color}'/><rect x='{x}' y='{y + 26}' width='{w}' height='10' fill='{color}'/>",
             f"<text class='ttl' x='{x + 14}' y='{y + 24}' fill='#FFFFFF' font-size='16'>{m[1]}. {E(name)}</text>",
             f"<text x='{x + w - 14}' y='{y + 24}' fill='#FFFFFF' font-size='12' text-anchor='end'>{len(ts)} tablas</text>"]
        ncol = 2 if w < 1000 else 4; cw = (w - 28) / ncol
        for i, t in enumerate(ts):
            s.append(f"<text class='fg' x='{x + 14 + (i % ncol) * cw:.1f}' y='{y + 58 + (i // ncol) * 21}' font-size='12'>{E(t)}</text>")
        out.append(''.join(s))
    def rows_h(m, ncol=2):
        n = len([t for t in T if T[t]['mod'] == m]); return 70 + math.ceil(n / ncol) * 21
    h1 = max(rows_h(m) for m in ('m2', 'm1', 'm6')); h2 = max(rows_h(m) for m in ('m4', 'm3', 'm5'))
    y2 = 40 + h1 + 120
    pos = {'m2': (40, 40), 'm1': (640, 40), 'm6': (1240, 40), 'm4': (40, y2), 'm3': (640, y2), 'm5': (1240, y2)}
    hs = {'m2': h1, 'm1': h1, 'm6': h1, 'm4': h2, 'm3': h2, 'm5': h2}
    y3 = y2 + h2 + 120; h3 = rows_h('m7', 4)
    def lbl(x, y, lines, anchor='middle'):
        for i, l in enumerate(lines):
            out.append(f"<text class='mu cd' x='{x}' y='{y + i * 14}' font-size='11' text-anchor='{anchor}'>{E(l)}</text>")
    cy1 = 40 + h1 / 2; cy2 = y2 + h2 / 2
    out.append(f"<line class='cl' x1='460' y1='{cy1}' x2='640' y2='{cy1}' stroke-width='2'/>")
    lbl(550, cy1 - 26, ['persons →', 'healthcare_professionals'])
    out.append(f"<line class='cl' x1='1060' y1='{cy1}' x2='1240' y2='{cy1}' stroke-width='2'/>")
    lbl(1150, cy1 - 26, ['patients →', 'glaucoma_records'])
    out.append(f"<line class='cl' x1='850' y1='{40 + h1}' x2='850' y2='{y2}' stroke-width='2'/>")
    lbl(860, 40 + h1 + 64, ['patients → clinical_histories'], 'start')
    out.append(f"<line class='cl' x1='460' y1='{40 + h1}' x2='640' y2='{y2}' stroke-width='2'/>")
    lbl(505, 40 + h1 + 30, ['healthcare_professionals'], 'end'); lbl(505, 40 + h1 + 44, ['→ medical_visits'], 'end')
    out.append(f"<line class='cl' x1='1240' y1='{40 + h1}' x2='1060' y2='{y2}' stroke-width='2'/>")
    lbl(1195, 40 + h1 + 30, ['medical_visits →'], 'start'); lbl(1195, 40 + h1 + 44, ['glaucoma_controls'], 'start')
    out.append(f"<line class='cl' x1='460' y1='{cy2}' x2='640' y2='{cy2}' stroke-width='2'/>")
    lbl(550, cy2 - 40, ['medical_visits →', '7 exámenes', '(OD / OI)'])
    out.append(f"<line class='cl' x1='1060' y1='{cy2}' x2='1240' y2='{cy2}' stroke-width='2'/>")
    lbl(1150, cy2 - 26, ['medical_visits →', 'treatments, procedures'])
    out.append(f"<line class='dot' x1='850' y1='{y2 + h2}' x2='850' y2='{y3}' stroke-width='2'/>")
    lbl(860, y2 + h2 + 64, ['triggers → audit_logs y tablas *_backup (sin FK)'], 'start')
    for m, (x, y) in pos.items(): box(m, x, y, W, hs[m])
    box('m7', 40, y3, 1620, h3)
    Hh = y3 + h3 + 40
    return (f"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1700 {Hh:.0f}' width='1700' height='{Hh:.0f}' role='img' aria-label='Mapa general de módulos'>"
            + ''.join(out) + "</svg>")

def render_fk_table():
    rows = []
    for i, (ch, col, p, v, od) in enumerate(FKS, 1):
        uniq = is_unique_fk(ch, col)
        card = '1 : 1' if (uniq and ch in ('clinical_histories', 'patients', 'healthcare_professionals', 'glaucoma_records')) else ('1 : 0..1' if uniq else '1 : N')
        rows.append(f'<tr><td class="num">{i}</td><td class="mono"><button type="button" class="xlink" data-t="{p}">{E(p)}</button></td><td>{E(v)}</td><td class="mono"><button type="button" class="xlink" data-t="{ch}">{E(ch)}</button>.<span class="fkc">{E(col)}</span></td>'
                    f'<td class="mono">{card}</td><td class="mono t">{od}</td><td><span class="mdot" style="--mc:{MODS[T[ch]["mod"]][1]}"></span>{T[ch]["mod"][1]}</td></tr>')
    return ('<div class="panel"><h3>Las 33 relaciones por llave foránea</h3>'
            '<p class="desc">Cada fila es una FOREIGN KEY del DDL. Todas usan ON UPDATE CASCADE. ON DELETE CASCADE se usa cuando el registro hijo no tiene sentido sin su padre.</p>'
            '<div class="scroll"><table><thead><tr><th>#</th><th>Tabla padre (1)</th><th>Relación</th><th>Tabla hija · columna FK</th><th>Cardinalidad</th><th>ON DELETE</th><th>Módulo</th></tr></thead>'
            f'<tbody>{"".join(rows)}</tbody></table></div></div>')

# ----------------------------------------------------------------------------- datos del explorador
def explorer_json():
    import json
    def kind(t):
        tag = T[t]['tag']
        if tag == 'catálogo': return 'catalogo'
        if tag.startswith('entidad débil'): return 'debil'
        if tag.startswith('resuelve N:M'): return 'asociativa'
        if tag == 'auditoría': return 'auditoria'
        if tag == 'respaldo': return 'respaldo'
        return 'fuerte'
    def card(ch, c):
        if is_unique_fk(ch, c):
            return '1 : 1' if ch in ('clinical_histories', 'patients', 'healthcare_professionals', 'glaucoma_records') else '1 : 0..1'
        return '1 : N'
    tables = []
    for name, d in T.items():
        tables.append(dict(
            name=name, mod=d['mod'], desc=d['desc'], tag=d['tag'], kind=kind(name),
            cols=[dict(name=c['name'], type=c['type'], base=c['type'].replace(' AUTO_INCREMENT', '').split('(')[0],
                       null=c['null'], keys=c['key'].split(), ref=c['ref'], default=c['default'], desc=c['desc']) for c in d['cols']],
            refs=[dict(col=c, to=p, verb=v, card=card(ch, c), od=od) for ch, c, p, v, od in FKS if ch == name],
            refBy=[dict(frm=ch, col=c, verb=v, card=card(ch, c), od=od) for ch, c, p, v, od in FKS if p == name]))
    data = dict(mods={k: dict(name=n, color=c) for k, (n, c) in MODS.items()}, tables=tables)
    return json.dumps(data, ensure_ascii=False).replace('</', '<\\/')

# ----------------------------------------------------------------------------- página
def chips():
    return ''.join(f'<button type="button" class="chip" data-mod="{m}" style="--mc:{c}"><span class="dotc"></span>{m[1]}. {E(n)}</button>'
                   for m, (n, c) in MODS.items())

def head_h3(m, n):
    name, color = MODS[m]
    return f'<h3 style="--mc:{color}"><span class="mn">{m[1]}</span>{E(name)}<span class="cnt">{n} tablas</span></h3>'

def main(out_path):
    chen, rel, der = [], [], []
    for m in MODS:
        n = len([t for t in T if T[t]['mod'] == m])
        s, w = render_chen(m) if m in CHEN else render_chen_m7()
        chen.append(f'<section class="pane" data-kind="chen" data-mod="{m}" hidden>{head_h3(m, n)}<div class="diagram">{s}</div></section>')
        rel.append(f'<section class="pane" data-kind="rel" data-mod="{m}" hidden>{head_h3(m, n)}{render_rel(m)}</section>')
        s, w, _ = render_der(m)
        der.append(f'<section class="pane" data-kind="der" data-mod="{m}" hidden>{head_h3(m, n)}<div class="diagram">{s}</div></section>')
    tpl = open(sys.argv[2], encoding='utf-8').read()
    page = (tpl.replace('{{CHIPS}}', chips()).replace('{{MAP}}', render_map()).replace('{{FKTABLE}}', render_fk_table())
               .replace('{{DATA}}', explorer_json()).replace('{{CHEN}}', ''.join(chen)).replace('{{REL}}', ''.join(rel)).replace('{{DER}}', ''.join(der)))
    open(out_path, 'w', encoding='utf-8', newline='\n').write(page)
    print('tablas:', len(T), 'FK:', len(FKS), 'bytes:', len(page.encode()))

if __name__ == '__main__':
    main(sys.argv[1])
