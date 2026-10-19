# 3. Diccionario de Datos del Sistema

El siguiente catálogo detalla la estructura física de las 37 tablas (32 base + 5 de respaldo), tipos de datos, restricciones de nulidad, llaves y descripciones de cada atributo para la base de datos `oftalmologia_glaucoma_db`.

---

## 3.1. Tablas Geográficas, Identificación y Pacientes (4FN)

### 1. `departments`
Divisiones político-administrativas de primer nivel.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del departamento |
| `name` | VARCHAR(100) | NO | UNIQUE | - | Nombre del departamento (Santander, Antioquia) |

### 2. `cities`
Municipios y ciudades de cada departamento.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del municipio |
| `department_id` | INT | NO | FK | - | Departamento al que pertenece |
| `name` | VARCHAR(100) | NO | - | - | Nombre del municipio (Bucaramanga, Floridablanca) |

### 3. `document_types`
Tipos legales de documento de identidad.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del tipo de documento |
| `code` | VARCHAR(10) | NO | UNIQUE | - | Código oficial (CC, TI, CE, PAS, RC) |
| `name` | VARCHAR(50) | NO | - | - | Nombre completo del tipo de documento |

### 4. `persons`
Super-tipo de identidad y datos demográficos base compartidos.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único de la persona |
| `document_type_id` | INT | NO | FK | - | Tipo de documento |
| `document_number` | VARCHAR(30) | NO | UNIQUE | - | Número de identificación legal |
| `first_name` | VARCHAR(100) | NO | - | - | Nombres |
| `last_name` | VARCHAR(100) | NO | - | - | Apellidos |
| `birth_date` | DATE | NO | - | - | Fecha de nacimiento |
| `gender` | ENUM('M','F','OTRO') | NO | - | - | Sexo biológico |
| `city_id` | INT | NO | FK | - | Ciudad de residencia |
| `address` | VARCHAR(255) | SI | - | - | Dirección de residencia |
| `phone` | VARCHAR(30) | SI | - | - | Teléfono de contacto |
| `email` | VARCHAR(150) | SI | UNIQUE | - | Correo electrónico |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de creación |
| `updated_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Última modificación |

### 5. `patients`
Sub-tipo clínico de pacientes atendidos (1:1 con persons).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único del paciente |
| `person_id` | BIGINT | NO | FK UNIQUE | - | Persona asociada (1:0..1) |
| `blood_type` | ENUM('O+','O-','A+','A-','B+','B-','AB+','AB-') | SI | - | - | Grupo sanguíneo y factor Rh |
| `health_insurance` | VARCHAR(100) | SI | - | - | Entidad Promotora de Salud (EPS / Aseguradora) |
| `affiliation_type` | ENUM('COTIZANTE','BENEFICIARIO','PARTICULAR','SUBSIDIADO') | NO | - | 'COTIZANTE' | Tipo de afiliación |
| `occupation` | VARCHAR(100) | SI | - | - | Ocupación o profesión |
| `emergency_contact_name` | VARCHAR(100) | SI | - | - | Nombre del contacto de emergencia |
| `emergency_contact_phone` | VARCHAR(30) | SI | - | - | Teléfono del contacto de emergencia |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de registro |
| `updated_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Última modificación |

### 6. `patient_allergies`
Alergias del paciente. Tabla separada por 4FN (paciente ↠ alergia).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `patient_id` | BIGINT | NO | FK | - | Paciente |
| `allergen` | VARCHAR(150) | NO | - | - | Sustancia causante (Penicilina, Sulfas) |
| `reaction` | VARCHAR(255) | SI | - | - | Reacción clínica manifestada |
| `severity` | ENUM('LEVE','MODERADA','SEVERA') | NO | - | 'MODERADA' | Severidad de la reacción |

### 7. `patient_family_histories`
Antecedentes familiares. Tabla separada por 4FN (paciente ↠ antecedente familiar).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `patient_id` | BIGINT | NO | FK | - | Paciente |
| `condition_name` | VARCHAR(150) | NO | - | - | Patología (glaucoma de ángulo abierto, DM2) |
| `relationship` | VARCHAR(50) | NO | - | - | Parentesco (padre, madre, hermano) |
| `notes` | TEXT | SI | - | - | Notas clínicas |

### 8. `patient_antecedents`
Antecedentes personales. Tabla separada por 4FN (paciente ↠ antecedente personal).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `patient_id` | BIGINT | NO | FK | - | Paciente |
| `antecedent_type` | ENUM('PATOLOGICO','QUIRURGICO','TRAUMATICO','FARMACOLOGICO') | NO | - | 'PATOLOGICO' | Categoría del antecedente |
| `description` | TEXT | NO | - | - | Detalle (LASIK, hipertensión arterial) |
| `year_diagnosed` | YEAR | SI | - | - | Año aproximado de diagnóstico |

### 9. `glaucoma_risk_factors`
Factores de riesgo específicos para glaucoma (aislados en 4FN).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `patient_id` | BIGINT | NO | FK | - | Paciente evaluado |
| `risk_factor` | ENUM('CCT_DELGADO','MIOPIA_ALTA','ANTECEDENTE_FAMILIAR_1ER_GRADO','HIPOTENSION_NOCTURNA','VASOESPASMO_MIGRAÑA','HEMORRAGIA_DISCO','SINDROME_PSEUDOEXFOLIATIVO','SINDROME_DISPERSION_PIGMENTARIA') | NO | - | - | Factor de riesgo estandarizado |
| `notes` | VARCHAR(255) | SI | - | - | Observaciones del factor de riesgo |

## 3.2. Especialidades, Profesionales de Salud y Citas

### 10. `specialties`
Especialidades y subespecialidades oftalmológicas.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador de especialidad |
| `name` | VARCHAR(100) | NO | UNIQUE | - | Nombre (Glaucoma, Córnea, Retina) |
| `description` | TEXT | SI | - | - | Descripción del área |

### 11. `healthcare_professionals`
Oftalmólogos, optómetras y especialistas tratantes (sub-tipo de persons).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del profesional |
| `person_id` | BIGINT | NO | FK UNIQUE | - | Persona asociada (1:0..1) |
| `medical_license` | VARCHAR(50) | NO | UNIQUE | - | Registro médico profesional |
| `specialty_id` | INT | NO | FK | - | Especialidad que ejerce |
| `is_active` | BOOLEAN | NO | - | TRUE | Disponible para atender |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de registro |

### 12. `appointments`
Agendamiento y programación de citas oftalmológicas.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la cita |
| `patient_id` | BIGINT | NO | FK | - | Paciente citado |
| `professional_id` | BIGINT | NO | FK | - | Profesional asignado |
| `appointment_date` | DATETIME | NO | - | - | Fecha y hora programada |
| `appointment_type` | ENUM('PRIMERA_VEZ','CONTROL_GLAUCOMA','POST_QUIRURGICO','LECTURA_EXAMENES','URGENCIA') | NO | - | 'CONTROL_GLAUCOMA' | Tipo de cita |
| `status` | ENUM('PROGRAMADA','CONFIRMADA','ATENDIDA','CANCELADA','NO_ASISTIO') | NO | - | 'PROGRAMADA' | Estado de la cita |
| `reason` | VARCHAR(255) | SI | - | - | Motivo de la cita |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de agendamiento |

## 3.3. Historia Clínica y Atención Médica

### 13. `clinical_histories`
Expediente único del paciente (relación 1:1).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la historia |
| `patient_id` | BIGINT | NO | FK UNIQUE | - | Paciente dueño del expediente (1:1) |
| `history_number` | VARCHAR(50) | NO | UNIQUE | - | Código institucional (HC-2026-0001) |
| `status` | ENUM('ACTIVA','ARCHIVADA','INACTIVA') | NO | - | 'ACTIVA' | Estado del expediente |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de apertura |

### 14. `medical_visits`
Consulta clínica realizada; eje de exámenes, diagnósticos y tratamientos.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la consulta |
| `clinical_history_id` | BIGINT | NO | FK | - | Historia clínica |
| `professional_id` | BIGINT | NO | FK | - | Médico tratante |
| `visit_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha y hora de la atención |
| `reason` | TEXT | NO | - | - | Motivo de consulta |
| `symptoms` | TEXT | SI | - | - | Sintomatología actual |
| `assessment` | TEXT | NO | - | - | Evaluación oftalmológica |
| `plan` | TEXT | NO | - | - | Plan terapéutico |
| `is_closed` | BOOLEAN | NO | - | FALSE | Consulta cerrada, no editable |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Creación del registro |
| `updated_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Última modificación |

### 15. `diagnoses`
Catálogo de diagnósticos CIE-10.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del diagnóstico |
| `code` | VARCHAR(20) | NO | UNIQUE | - | Código CIE-10 (H40.1, H40.2) |
| `name` | VARCHAR(200) | NO | - | - | Nombre clínico |
| `is_glaucoma_type` | BOOLEAN | NO | - | FALSE | Indica si es un tipo de glaucoma |
| `description` | TEXT | SI | - | - | Criterios diagnósticos |

### 16. `visit_diagnoses`
Diagnósticos de cada consulta. Resuelve la relación N:M consulta–diagnóstico.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `visit_id` | BIGINT | NO | FK | - | Consulta |
| `diagnosis_id` | INT | NO | FK | - | Diagnóstico asignado |
| `is_primary` | BOOLEAN | NO | - | FALSE | Diagnóstico principal |
| `notes` | VARCHAR(255) | SI | - | - | Observaciones del caso |

### 17. `clinical_documents`
Archivos adjuntos: retinografías, PDF de perimetría, firmas.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del archivo |
| `clinical_history_id` | BIGINT | NO | FK | - | Historia clínica |
| `title` | VARCHAR(150) | NO | - | - | Nombre del documento |
| `file_type` | VARCHAR(50) | NO | - | - | Tipo MIME (application/pdf) |
| `file_path` | VARCHAR(255) | NO | - | - | Ruta de almacenamiento |
| `uploaded_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de carga |
| `deleted_by` | VARCHAR(100) | SI | - | - | Usuario que lo eliminó |

## 3.4. Exámenes Oftalmológicos y Paraclínicos

### 18. `intraocular_pressures`
Tonometría: presión intraocular por ojo, en mmHg.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la medición |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado: derecho (OD) o izquierdo (OI) |
| `pressure` | DECIMAL(5,2) | NO | - | - | Presión en mmHg |
| `measurement_time` | TIME | SI | - | - | Hora de la toma (curva diurna) |
| `method` | ENUM('GOLDMANN','AIRE','PERKINS','ICARE') | NO | - | 'GOLDMANN' | Tonómetro utilizado |
| `notes` | VARCHAR(255) | SI | - | - | Observaciones |

### 19. `pachymetry_exams`
Paquimetría: espesor corneal central (CCT) en µm.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del examen |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado |
| `corneal_thickness` | DECIMAL(6,2) | NO | - | - | Espesor corneal en µm |
| `method` | VARCHAR(50) | NO | - | 'ULTRASONICA' | Técnica (ultrasónica, óptica) |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

### 20. `gonioscopy_exams`
Gonioscopía: grado del ángulo iridocorneal (escala de Shaffer).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del examen |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado |
| `angle_grade` | ENUM('GRADO 0','GRADO I','GRADO II','GRADO III','GRADO IV') | NO | - | - | Grado de Shaffer |
| `pigmentation` | ENUM('LEVE','MODERADA','SEVERA') | NO | - | 'LEVE' | Pigmentación trabecular |
| `findings` | TEXT | SI | - | - | Sinequias, neovascularización |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

### 21. `oct_exams`
Tomografía de coherencia óptica: capa de fibras nerviosas (RNFL) y excavación.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del OCT |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado |
| `rnfl_average` | DECIMAL(6,2) | NO | - | - | Espesor promedio RNFL (µm) |
| `rnfl_superior` | DECIMAL(6,2) | SI | - | - | RNFL cuadrante superior |
| `rnfl_inferior` | DECIMAL(6,2) | SI | - | - | RNFL cuadrante inferior |
| `cup_to_disc_ratio` | DECIMAL(4,2) | SI | - | - | Relación excavación/disco |
| `interpretation` | TEXT | SI | - | - | Juicio clínico |
| `is_validated` | BOOLEAN | NO | - | FALSE | Validado por especialista |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del estudio |

### 22. `visual_field_exams`
Campimetría computarizada: índices MD, PSD y VFI.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del campo visual |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado |
| `strategy` | VARCHAR(50) | NO | - | 'SITA-Standard 24-2' | Estrategia perimétrica |
| `mean_deviation_md` | DECIMAL(6,2) | NO | - | - | Desviación media (dB) |
| `pattern_std_deviation_psd` | DECIMAL(6,2) | NO | - | - | Desviación estándar del patrón (dB) |
| `visual_field_index_vfi` | DECIMAL(5,2) | NO | - | - | Índice de campo visual (%) |
| `false_positives_pct` | DECIMAL(5,2) | SI | - | - | Falsos positivos (%) |
| `false_negatives_pct` | DECIMAL(5,2) | SI | - | - | Falsos negativos (%) |
| `reliability` | ENUM('CONFIABLE','NO CONFIABLE') | NO | - | 'CONFIABLE' | Confiabilidad del examen |
| `interpretation` | TEXT | SI | - | - | Defecto campimétrico |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

### 23. `visual_acuity_exams`
Agudeza visual lejana/cercana y refracción clínica.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del examen de agudeza |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado |
| `sphere` | DECIMAL(4,2) | SI | - | - | Esfera refracción (dioptrías) |
| `cylinder` | DECIMAL(4,2) | SI | - | - | Cilindro refracción (dioptrías) |
| `axis` | INT | SI | - | - | Eje del astigmatismo (0-180 grados) |
| `uncorrected_va` | VARCHAR(20) | NO | - | - | Agudeza visual sin corrección (Snellen 20/XX) |
| `corrected_va` | VARCHAR(20) | NO | - | - | Agudeza visual con corrección |
| `pinhole_va` | VARCHAR(20) | SI | - | - | Agudeza visual con agujero estenopeico |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

### 24. `biomicroscopy_exams`
Biomicroscopía en lámpara de hendidura: profundidad y estructuras.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la biomicroscopía |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado |
| `cornea_status` | VARCHAR(100) | NO | - | 'TRANSPARENTE' | Estado de la córnea |
| `anterior_chamber_depth` | ENUM('VAN_HERICK_I','VAN_HERICK_II','VAN_HERICK_III','VAN_HERICK_IV') | NO | - | 'VAN_HERICK_IV' | Profundidad de cámara periférica (Van Herick) |
| `iris_status` | VARCHAR(100) | NO | - | 'NORMAL' | Estado del iris |
| `lens_status` | ENUM('TRANSPARENTE','CATARATA_NUCLEAR','CATARATA_CORTICAL','CATARATA_SUBCAPSULAR','PSEUDOFAQUICO','AFAQUICO') | NO | - | 'TRANSPARENTE' | Estado del cristalino |
| `pseudoexfoliation_present` | BOOLEAN | NO | - | FALSE | Presencia de material pseudoexfoliativo |
| `pigment_dispersion_present` | BOOLEAN | NO | - | FALSE | Presencia de dispersión pigmentaria |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

## 3.5. Farmacología, Tratamientos y Procedimientos

### 25. `medication_classes`
Catálogo de familias farmacológicas para glaucoma (3FN).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador de la clase farmacológica |
| `name` | VARCHAR(100) | NO | UNIQUE | - | Nombre de la familia farmacológica |
| `mechanism_of_action` | TEXT | SI | - | - | Mecanismo de acción hipotensora |

### 26. `medications`
Catálogo de medicamentos hipotensores oculares.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del medicamento |
| `medication_class_id` | INT | NO | FK | - | Clase farmacológica (3FN) |
| `name` | VARCHAR(150) | NO | UNIQUE | - | Nombre comercial |
| `generic_name` | VARCHAR(150) | NO | - | - | Denominación común internacional |
| `concentration` | VARCHAR(50) | NO | - | - | Concentración (0.005%, 0.5%) |
| `presentation` | VARCHAR(100) | NO | - | 'Frasco gotero x 2.5 ml' | Presentación farmacéutica |
| `is_active` | BOOLEAN | NO | - | TRUE | Vigente en el catálogo |

### 27. `treatments`
Prescripción farmacológica emitida en una consulta.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la prescripción |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `medication_id` | INT | NO | FK | - | Medicamento prescrito |
| `eye` | ENUM('OD','OI','AMBOS') | NO | - | 'AMBOS' | Ojo tratado |
| `dosage` | VARCHAR(100) | NO | - | - | Dosis (1 gota) |
| `frequency` | VARCHAR(100) | NO | - | - | Frecuencia (cada 12 horas) |
| `start_date` | DATE | NO | - | - | Inicio del tratamiento |
| `end_date` | DATE | SI | - | - | Fin del tratamiento |
| `is_active` | BOOLEAN | NO | - | TRUE | Tratamiento vigente |
| `notes` | TEXT | SI | - | - | Indicaciones o efectos adversos |

### 28. `procedure_types`
Catálogo de procedimientos quirúrgicos y láser CUPS (3FN).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del tipo de procedimiento |
| `code` | VARCHAR(20) | NO | UNIQUE | - | Código oficial o CUPS |
| `name` | VARCHAR(150) | NO | - | - | Nombre del procedimiento |
| `category` | ENUM('LASER','QUIRURGICO','DIAGNOSTICO') | NO | - | 'QUIRURGICO' | Categoría del procedimiento |
| `description` | TEXT | SI | - | - | Descripción técnica |

### 29. `procedures`
Procedimientos láser o quirúrgicos realizados (SLT, trabeculectomía).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del procedimiento |
| `visit_id` | BIGINT | NO | FK | - | Consulta en la que se registró |
| `procedure_type_id` | INT | NO | FK | - | Tipo de procedimiento realizado (3FN) |
| `eye` | ENUM('OD','OI','AMBOS') | NO | - | - | Ojo intervenido |
| `procedure_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha y hora |
| `complications` | TEXT | SI | - | - | Complicaciones |
| `results` | TEXT | SI | - | - | Resultados inmediatos |

## 3.6. Ficha y Monitoreo Continuo de Glaucoma

### 30. `glaucoma_records`
Ficha de glaucoma del paciente: PIO objetivo y estadio.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la ficha |
| `patient_id` | BIGINT | NO | FK UNIQUE | - | Paciente (máximo una ficha) |
| `target_iop_od` | DECIMAL(5,2) | NO | - | - | PIO objetivo ojo derecho (mmHg) |
| `target_iop_oi` | DECIMAL(5,2) | NO | - | - | PIO objetivo ojo izquierdo (mmHg) |
| `clinical_stage` | ENUM('SOSPECHA','INICIAL','MODERADO','AVANZADO','TERMINAL') | NO | - | 'SOSPECHA' | Estadio clínico |
| `diagnosis_date` | DATE | NO | - | - | Fecha de confirmación |
| `notes` | TEXT | SI | - | - | Factores de riesgo |

### 31. `glaucoma_controls`
Control periódico de progresión y adherencia.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del control |
| `glaucoma_record_id` | BIGINT | NO | FK | - | Ficha de glaucoma |
| `visit_id` | BIGINT | NO | FK | - | Consulta del control |
| `control_date` | DATE | NO | - | - | Fecha del control |
| `is_progression_detected` | BOOLEAN | NO | - | FALSE | Progresión estructural o funcional |
| `adherence_score` | ENUM('EXCELENTE','BUENA','REGULAR','MALA') | NO | - | 'BUENA' | Adherencia a las gotas |
| `notes` | TEXT | SI | - | - | Ajustes al tratamiento |

## 3.7. Documentos y Auditoría de Seguridad

### 32. `audit_logs`
Bitácora inmutable que llenan los triggers. Se relaciona con cualquier tabla por (table_name, record_id), sin FK.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del evento |
| `table_name` | VARCHAR(100) | NO | - | - | Tabla afectada |
| `record_id` | BIGINT | NO | - | - | id del registro afectado |
| `action` | ENUM('INSERT','UPDATE','DELETE','ALERT') | NO | - | - | Operación ejecutada |
| `old_values` | JSON | SI | - | - | Estado anterior |
| `new_values` | JSON | SI | - | - | Estado posterior |
| `performed_by` | VARCHAR(100) | NO | - | 'SYSTEM' | Usuario o proceso |
| `changed_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Momento del cambio |

---

## 3.8. Tablas de Respaldo

Las cinco tablas de respaldo se crean con `CREATE TABLE … LIKE`, por lo que tienen **exactamente las mismas columnas, tipos, `NULL`, `DEFAULT`, `PRIMARY KEY`, índices `UNIQUE` y `CHECK`** que su tabla de origen. `LIKE` **no copia las llaves foráneas**, así que no tienen relaciones. Las llenan triggers `BEFORE DELETE` con la fila que se va a borrar.

| # | Tabla | Copia de | Trigger que la llena |
|---|---|---|---|
| 33 | `persons_backup` | `persons` (13 columnas) | `trg_bd_persons_backup` |
| 34 | `patients_backup` | `patients` (10 columnas) | `trg_bd_patients_backup` |
| 35 | `medical_visits_backup` | `medical_visits` (11 columnas) | `trg_bd_visits_backup` |
| 36 | `treatments_backup` | `treatments` (10 columnas) | `trg_bd_treatments_backup` |
| 37 | `oct_exams_backup` | `oct_exams` (10 columnas) | `trg_bd_oct_delete_backup` |
