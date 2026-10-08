# 3. Diccionario de Datos del Sistema

El siguiente catálogo detalla la estructura física de las tablas, tipos de datos, restricciones de nulidad, llaves y descripciones de cada atributo para la base de datos `oftalmologia_glaucoma_db`.

---

## 3.1. Tablas Geográficas y de Identificación

### 1. `departments`
Almacena las divisiones político-administrativas de primer nivel.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador único del departamento |
| `name` | VARCHAR(100) | NO | UNIQUE | - | Nombre del departamento (ej. Santander, Antioquia) |

### 2. `cities`
Municipios y ciudades asociadas a departamentos.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador único del municipio |
| `department_id` | INT | NO | FK | - | Referencia a `departments(id)` |
| `name` | VARCHAR(100) | NO | - | - | Nombre del municipio (ej. Bucaramanga, Floridablanca) |

### 3. `document_types`
Tipos legales de documento de identidad.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del tipo de documento |
| `code` | VARCHAR(10) | NO | UNIQUE | - | Código oficial (CC, TI, CE, PAS, RC) |
| `name` | VARCHAR(50) | NO | - | - | Nombre completo del tipo de documento |

---

## 3.2. Especialidades y Profesionales de Salud

### 4. `specialties`
Catálogo de especialidades y subespecialidades oftalmológicas.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador de especialidad |
| `name` | VARCHAR(100) | NO | UNIQUE | - | Nombre (ej. Oftalmología General, Glaucoma, Córnea) |
| `description` | TEXT | SI | - | NULL | Descripción del área de atención |

### 5. `healthcare_professionals`
Médicos oftalmólogos, optómetras y especialistas tratantes.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del profesional |
| `document_type_id` | INT | NO | FK | - | Referencia a `document_types(id)` |
| `document_number` | VARCHAR(30) | NO | UNIQUE | - | Cédula o documento de identificación |
| `first_name` | VARCHAR(100) | NO | - | - | Nombres del profesional |
| `last_name` | VARCHAR(100) | NO | - | - | Apellidos del profesional |
| `medical_license` | VARCHAR(50) | NO | UNIQUE | - | Registro médico o tarjeta profesional |
| `specialty_id` | INT | NO | FK | - | Referencia a `specialties(id)` |
| `email` | VARCHAR(150) | NO | UNIQUE | - | Correo electrónico institucional |
| `phone` | VARCHAR(30) | SI | - | NULL | Teléfono de contacto |
| `is_active` | BOOLEAN | NO | - | TRUE | Estado activo para asignación de citas |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de creación del registro |

---

## 3.3. Pacientes y Entidades Desacopladas (4FN)

### 6. `patients`
Datos demográficos principales del paciente.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único del paciente |
| `document_type_id` | INT | NO | FK | - | Referencia a `document_types(id)` |
| `document_number` | VARCHAR(30) | NO | UNIQUE | - | Número de documento |
| `first_name` | VARCHAR(100) | NO | - | - | Nombres del paciente |
| `last_name` | VARCHAR(100) | NO | - | - | Apellidos del paciente |
| `birth_date` | DATE | NO | - | - | Fecha de nacimiento |
| `gender` | ENUM('M','F','OTRO') | NO | - | - | Sexo / género biológico |
| `city_id` | INT | NO | FK | - | Referencia a `cities(id)` |
| `address` | VARCHAR(255) | SI | - | NULL | Dirección de residencia |
| `phone` | VARCHAR(30) | SI | - | NULL | Teléfono de contacto |
| `email` | VARCHAR(150) | SI | UNIQUE | NULL | Correo electrónico del paciente |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de registro inicial |
| `updated_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de última modificación |

### 7. `patient_allergies` (Desacoplado por 4FN)
Alergias farmacológicas o ambientales del paciente.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `patient_id` | BIGINT | NO | FK | - | Referencia a `patients(id)` |
| `allergen` | VARCHAR(150) | NO | - | - | Sustancia causante (ej. Penicilina, Sulfas, Látex) |
| `reaction` | VARCHAR(255) | SI | - | NULL | Reacción clínica manifestada |
| `severity` | ENUM('LEVE','MODERADA','SEVERA') | NO | - | 'MODERADA' | Severidad de la reacción alérgica |

### 8. `patient_family_histories` (Desacoplado por 4FN)
Antecedentes familiares patológicos relevantes para glaucoma.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del antecedente familiar |
| `patient_id` | BIGINT | NO | FK | - | Referencia a `patients(id)` |
| `condition_name` | VARCHAR(150) | NO | - | - | Patología (ej. Glaucoma de ángulo abierto, DM2) |
| `relationship` | VARCHAR(50) | NO | - | - | Parentesco (Padre, Madre, Hermano, Abuelo) |
| `notes` | TEXT | SI | - | NULL | Notas adicionales de interés clínico |

### 9. `patient_antecedents` (Desacoplado por 4FN)
Antecedentes personales patológicos, quirúrgicos u oftalmológicos previos.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único |
| `patient_id` | BIGINT | NO | FK | - | Referencia a `patients(id)` |
| `antecedent_type` | ENUM('PATOLOGICO','QUIRURGICO','TRAUMATICO','FARMACOLOGICO') | NO | - | 'PATOLOGICO' | Categoría del antecedente |
| `description` | TEXT | NO | - | - | Detalle (ej. Cirugía refractiva LASIK, Hipertensión arterial) |
| `year_diagnosed` | YEAR | SI | - | NULL | Año aproximado de diagnóstico/ocurrencia |

---

## 3.4. Historia Clínica y Atención Médica

### 10. `clinical_histories`
Expediente unificado 1:1 por cada paciente.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de historia clínica |
| `patient_id` | BIGINT | NO | FK, UNIQUE | - | Referencia a `patients(id)` (1 a 1) |
| `history_number` | VARCHAR(50) | NO | UNIQUE | - | Código único institucional (ej. HC-1098765432) |
| `status` | ENUM('ACTIVA','ARCHIVADA','INACTIVA') | NO | - | 'ACTIVA' | Estado operativo del expediente |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de apertura de la historia clínica |

### 11. `medical_visits`
Consultas clínicas presenciales o de control.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la consulta |
| `clinical_history_id` | BIGINT | NO | FK | - | Referencia a `clinical_histories(id)` |
| `professional_id` | BIGINT | NO | FK | - | Médico tratante `healthcare_professionals(id)` |
| `visit_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha y hora de la atención |
| `reason` | TEXT | NO | - | - | Motivo de consulta |
| `symptoms` | TEXT | SI | - | NULL | Descripción de sintomatología actual |
| `assessment` | TEXT | NO | - | - | Juicio clínico o evaluación oftalmológica |
| `plan` | TEXT | NO | - | - | Plan terapéutico o conducta a seguir |
| `is_closed` | BOOLEAN | NO | - | FALSE | Indicador de consulta cerrada y no editable |
| `created_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Auditoría de creación |
| `updated_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Auditoría de actualización |

---

## 3.5. Diagnósticos

### 12. `diagnoses`
Catálogo de diagnósticos estandarizados (CIE-10).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador del diagnóstico |
| `code` | VARCHAR(20) | NO | UNIQUE | - | Código CIE-10 (ej. H40.1, H40.2, H25.9) |
| `name` | VARCHAR(200) | NO | - | - | Nombre clínico de la patología |
| `is_glaucoma_type` | BOOLEAN | NO | - | FALSE | Bandera que clasifica si corresponde a glaucoma |
| `description` | TEXT | SI | - | NULL | Criterios diagnósticos o notas |

### 13. `visit_diagnoses`
Relación muchos a muchos entre consultas y diagnósticos asociados.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador único del registro asociativo |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `diagnosis_id` | INT | NO | FK | - | Referencia a `diagnoses(id)` |
| `is_primary` | BOOLEAN | NO | - | FALSE | Diagnóstico principal de la consulta |
| `notes` | VARCHAR(255) | SI | - | NULL | Observaciones particulares del caso |

---

## 3.6. Exámenes Oftalmológicos y Paraclínicos

### 14. `intraocular_pressures`
Mediciones de presión intraocular (tonometría).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de la medición |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado: Derecho (OD) o Izquierdo (OI) |
| `pressure` | DECIMAL(5,2) | NO | - | - | Presión en mmHg (Restricción CHECK: >0 y <=80) |
| `measurement_time` | TIME | SI | - | NULL | Hora exacta de la tonometría |
| `method` | ENUM('GOLDMANN','AIRE','PERKINS','ICARE') | NO | - | 'GOLDMANN' | Método o tonómetro utilizado |
| `notes` | VARCHAR(255) | SI | - | NULL | Observaciones de la toma |

### 15. `pachymetry_exams`
Espesor corneal central (CCT) en micrómetros.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del examen |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado (OD u OI) |
| `corneal_thickness` | DECIMAL(6,2) | NO | - | - | Espesor corneal en µm (CHECK: >0) |
| `method` | VARCHAR(50) | NO | - | 'ULTRASONICA' | Técnica (Ultrasónica, Óptica) |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

### 16. `gonioscopy_exams`
Evaluación del ángulo iridocorneal para clasificación de glaucoma de ángulo abierto/cerrado.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del examen |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado (OD u OI) |
| `angle_grade` | ENUM('GRADO 0','GRADO I','GRADO II','GRADO III','GRADO IV') | NO | - | - | Grado según escala de Shaffer |
| `pigmentation` | ENUM('LEVE','MODERADA','SEVERA') | NO | - | 'LEVE' | Pigmentación trabecular |
| `findings` | TEXT | SI | - | NULL | Sinequias anteriores, neovascularización, etc. |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

### 17. `oct_exams`
Tomografía de coherencia óptica del nervio óptico y capa de fibras nerviosas.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del OCT |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado (OD u OI) |
| `rnfl_average` | DECIMAL(6,2) | NO | - | - | Espesor promedio de RNFL en µm |
| `rnfl_superior` | DECIMAL(6,2) | SI | - | NULL | Espesor de fibras cuadrante superior |
| `rnfl_inferior` | DECIMAL(6,2) | SI | - | NULL | Espesor de fibras cuadrante inferior |
| `cup_to_disc_ratio` | DECIMAL(4,2) | SI | - | NULL | Relación excavación/disco (0.00 a 1.00) |
| `interpretation` | TEXT | SI | - | NULL | Juicio clínico del estudio |
| `is_validated` | BOOLEAN | NO | - | FALSE | Indicador de validación por especialista |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del estudio |

### 18. `visual_field_exams`
Campimetría computarizada para evaluación de campo visual.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del campo visual |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `eye` | ENUM('OD','OI') | NO | - | - | Ojo evaluado (OD u OI) |
| `strategy` | VARCHAR(50) | NO | - | 'SITA-Standard 24-2' | Estrategia perimétrica |
| `mean_deviation_md` | DECIMAL(6,2) | NO | - | - | Desviación media (dB) |
| `pattern_std_deviation_psd`| DECIMAL(6,2) | NO | - | - | Desviación estándar del patrón (dB) |
| `visual_field_index_vfi` | DECIMAL(5,2) | NO | - | - | Índice VFI en % (CHECK: entre 0 y 100) |
| `false_positives_pct` | DECIMAL(5,2) | SI | - | NULL | Porcentaje de falsos positivos |
| `false_negatives_pct` | DECIMAL(5,2) | SI | - | NULL | Porcentaje de falsos negativos |
| `reliability` | ENUM('CONFIABLE','NO CONFIABLE') | NO | - | 'CONFIABLE' | Criterio de confiabilidad |
| `interpretation` | TEXT | SI | - | NULL | Descripción del defecto campimétrico |
| `exam_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha del examen |

---

## 3.7. Farmacología y Tratamientos

### 19. `medications`
Catálogo de medicamentos tópicos y sistémicos.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | INT AUTO_INCREMENT | NO | PK | - | Identificador de medicamento |
| `name` | VARCHAR(150) | NO | UNIQUE | - | Nombre comercial |
| `generic_name` | VARCHAR(150) | NO | - | - | Denominación Común Internacional (DCI) |
| `concentration` | VARCHAR(50) | NO | - | - | Concentración (ej. 0.005%, 0.5%, 2%) |
| `presentation` | VARCHAR(100) | NO | - | 'Frasco gotero x 2.5 ml' | Presentación farmacéutica |
| `is_active` | BOOLEAN | NO | - | TRUE | Estado del medicamento en catálogo |

### 20. `treatments`
Prescripción médica asociada a una atención.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador de prescripción |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `medication_id` | INT | NO | FK | - | Referencia a `medications(id)` |
| `eye` | ENUM('OD','OI','AMBOS') | NO | - | 'AMBOS' | Ojo al cual se aplica la terapia |
| `dosage` | VARCHAR(100) | NO | - | - | Dosis (ej. 1 gota) |
| `frequency` | VARCHAR(100) | NO | - | - | Frecuencia (ej. Cada 12 horas, cada 24 h en la noche) |
| `start_date` | DATE | NO | - | - | Fecha de inicio del tratamiento |
| `end_date` | DATE | SI | - | NULL | Fecha de finalización (CHECK: end_date >= start_date) |
| `is_active` | BOOLEAN | NO | - | TRUE | Indicador de tratamiento vigente |
| `notes` | TEXT | SI | - | NULL | Indicaciones especiales o efectos adversos |

### 21. `procedures`
Procedimientos quirúrgicos o láser realizados al paciente.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del procedimiento |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `name` | VARCHAR(150) | NO | - | - | Nombre (Trabeculoplastia SLT, Iridotomía YAG, Trabeculectomía) |
| `eye` | ENUM('OD','OI','AMBOS') | NO | - | - | Ojo intervenido |
| `procedure_date` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha y hora del procedimiento |
| `complications` | TEXT | SI | - | NULL | Complicaciones intra o postoperatorias |
| `results` | TEXT | SI | - | NULL | Resultados clínicos inmediatos |

---

## 3.8. Seguimiento Específico de Glaucoma

### 22. `glaucoma_records`
Expediente de seguimiento y caracterización de glaucoma por paciente.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del registro de glaucoma |
| `patient_id` | BIGINT | NO | FK, UNIQUE | - | Referencia a `patients(id)` |
| `target_iop_od` | DECIMAL(5,2) | NO | - | - | Presión intraocular objetivo para OD (mmHg) |
| `target_iop_oi` | DECIMAL(5,2) | NO | - | - | Presión intraocular objetivo para OI (mmHg) |
| `clinical_stage` | ENUM('SOSPECHA','INICIAL','MODERADO','AVANZADO','TERMINAL') | NO | - | 'SOSPECHA' | Estadio clínico del glaucoma |
| `diagnosis_date` | DATE | NO | - | - | Fecha de confirmación diagnóstica |
| `notes` | TEXT | SI | - | NULL | Factores de riesgo cardiovascular/corneal |

### 23. `glaucoma_controls`
Controles periódicos de progresión y adherencia terapéutica.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del control de glaucoma |
| `glaucoma_record_id` | BIGINT | NO | FK | - | Referencia a `glaucoma_records(id)` |
| `visit_id` | BIGINT | NO | FK | - | Referencia a `medical_visits(id)` |
| `control_date` | DATE | NO | - | - | Fecha del control |
| `is_progression_detected`| BOOLEAN | NO | - | FALSE | Indicador de progresión estructural o funcional |
| `adherence_score` | ENUM('EXCELENTE','BUENA','REGULAR','MALA') | NO | - | 'BUENA' | Nivel de adherencia al tratamiento en gotas |
| `notes` | TEXT | SI | - | NULL | Ajustes requeridos al tratamiento |

---

## 3.9. Documentos y Auditoría

### 24. `clinical_documents`
Archivos adjuntos (imágenes retinográficas, PDF de perimetría, firmas digitales).
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del archivo |
| `clinical_history_id` | BIGINT | NO | FK | - | Referencia a `clinical_histories(id)` |
| `title` | VARCHAR(150) | NO | - | - | Nombre o descripción del documento |
| `file_type` | VARCHAR(50) | NO | - | - | Tipo MIME (application/pdf, image/jpeg) |
| `file_path` | VARCHAR(255) | NO | - | - | Ruta en el sistema de almacenamiento |
| `uploaded_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Fecha de carga del documento |
| `deleted_by` | VARCHAR(100) | SI | - | NULL | Usuario que marcó el documento como eliminado |

### 25. `audit_logs`
Bitácora inmutable de eventos, modificaciones y auditoría de seguridad.
| Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|---|---|---|---|---|
| `id` | BIGINT AUTO_INCREMENT | NO | PK | - | Identificador del registro de auditoría |
| `table_name` | VARCHAR(100) | NO | - | - | Tabla afectada |
| `record_id` | BIGINT | NO | - | - | ID del registro modificado o eliminado |
| `action` | ENUM('INSERT','UPDATE','DELETE','ALERT')| NO | - | - | Operación ejecutada |
| `old_values` | JSON | SI | - | NULL | Estado anterior en formato JSON |
| `new_values` | JSON | SI | - | NULL | Estado posterior en formato JSON |
| `performed_by` | VARCHAR(100) | NO | - | 'SYSTEM' | Usuario o proceso que ejecutó el cambio (los triggers lo informan) |
| `changed_at` | DATETIME | NO | - | CURRENT_TIMESTAMP | Timestamp exacto del cambio |

---

## 3.10. Tablas de Respaldo

Las cuatro tablas de respaldo se crean con `CREATE TABLE … LIKE`, por lo que tienen **exactamente las mismas columnas, tipos, `NULL`, `DEFAULT`, `PRIMARY KEY`, índices `UNIQUE` y `CHECK`** que su tabla de origen. `LIKE` **no copia las llaves foráneas**, así que no tienen relaciones. Las llenan triggers `BEFORE DELETE` con la fila que se va a borrar.

| # | Tabla | Copia de | Trigger que la llena |
|---|---|---|---|
| 26 | `patients_backup` | `patients` (13 columnas) | `trg_bd_patients_backup` |
| 27 | `medical_visits_backup` | `medical_visits` (11 columnas) | `trg_bd_visits_backup` |
| 28 | `treatments_backup` | `treatments` (10 columnas) | `trg_bd_treatments_backup` |
| 29 | `oct_exams_backup` | `oct_exams` (10 columnas) | `trg_bd_oct_delete_backup` |
