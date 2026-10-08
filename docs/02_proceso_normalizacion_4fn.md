# 2. Proceso Formal de Normalización hasta Cuarta Forma Normal (4FN)

El diseño de la base de datos para historias clínicas oftalmológicas se fundamenta en la teoría de la normalización de bases de datos relacionales formulada por Edgar F. Codd y Ronald Fagin. El objetivo es eliminar anomalías de inserción, actualización y borrado, erradicar redundancias injustificadas y modelar fielmente las restricciones de integridad y dependencias del dominio médico.

---

## 2.1. Estado Inicial: Forma No Normalizada (0FN)

Imaginemos el registro clínico histórico inicial almacenado en una única hoja o tabla desestructurada:

### Tabla Plana Desnormalizada (`HISTORIA_CLINICA_GENERAL`)
| paciente_id | doc_numero | nombre_paciente | ciudad | depto | alergias (multivaluado) | antecedentes_familiares | visita_id | fecha_visita | prof_id | prof_nombre | especialidad | diagnosticos | medicamentos | pio_od | pio_oi | oct_rnfl_od | oct_rnfl_oi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1098765432 | Carlos Gómez | Bucaramanga | Santander | Penicilina, Sulfas | Glaucoma materno, DM2 padre | 101 | 2026-02-10 | 1 | Dra. Ruiz | Oftalmología | Glaucoma Ángulo Abierto, Miopía | Latanoprost 0.005%, Timolol 0.5% | 24 | 22 | 75 | 78 |
| 1 | 1098765432 | Carlos Gómez | Bucaramanga | Santander | Penicilina, Sulfas | Glaucoma materno, DM2 padre | 102 | 2026-05-15 | 1 | Dra. Ruiz | Oftalmología | Glaucoma Ángulo Abierto | Bimatoprost 0.01% | 18 | 17 | 74 | 77 |

### Anomalías presentes en 0FN:
1. **Atributos no atómicos:** Celdas con listas de valores separados por comas (`alergias`, `antecedentes_familiares`, `diagnosticos`, `medicamentos`).
2. **Grupos repetitivos:** Repetición innecesaria de nombres, ciudades y antecedentes en cada visita.
3. **Anomalía de Inserción:** No es posible registrar un nuevo diagnóstico o medicamento en el catálogo si aún no ha sido prescrito a un paciente.
4. **Anomalía de Modificación:** Si la Dra. Ruiz cambia de especialidad o apellido, debe actualizarse en cientos de filas históricas.
5. **Anomalía de Eliminación:** Si se borra la visita `102`, se podrían perder notas clínicas o mediciones únicas asociadas a ese evento.

---

## 2.2. Primera Forma Normal (1FN)

### Requisitos teóricos:
1. Todos los atributos deben ser **atómicos** (indivisibles).
2. Cada celda de una tupla contiene **un único valor** de su dominio.
3. Ausencia de grupos repetitivos o columnas numeradas artificialmente (`diag_1`, `diag_2`).
4. Existencia de una clave primaria identificadora única para cada relación.

### Aplicación al modelo:
1. Se desglosan las listas multivaluadas (`diagnosticos`, `medicamentos`, `alergias`, `antecedentes`).
2. Se separan las entidades principales mediante llaves primarias:
   - `patients` (id, document_type_id, document_number, first_name, last_name, birth_date, gender, email, phone).
   - `clinical_histories` (id, patient_id, created_at, status).
   - `medical_visits` (id, clinical_history_id, professional_id, visit_date, reason, assessment, plan).
   - `intraocular_pressures` (id, visit_id, eye, pressure, measurement_time, method).
   - `visit_diagnoses` (visit_id, diagnosis_id, is_primary, notes).
   - `treatments` (id, visit_id, medication_id, dosage, frequency, eye, start_date, end_date, is_active).

**Resultado 1FN:** Todas las tablas poseen tuplas atómicas y claves primarias bien definidas.

---

## 2.3. Segunda Forma Normal (2FN)

### Requisitos teóricos:
1. La relación debe estar en **1FN**.
2. **Ausencia de dependencias funcionales parciales**: Todo atributo no clave debe depender de manera funcional **completa** de la clave primaria (aplica a tablas con claves primarias compuestas).

### Análisis y corrección:
Tomemos la relación intermedia `VISIT_DIAGNOSES` con clave candidata compuesta `{visit_id, diagnosis_id}` (en el modelo físico es la restricción `UNIQUE uq_visit_diag`; la `PRIMARY KEY` es el identificador sustituto `id`):

$$FD_1: \{visit\_id, diagnosis\_id\} \rightarrow \{notes, is\_primary\}$$
$$FD_2: diagnosis\_id \rightarrow \{diagnosis\_name, icd10\_code, description\}$$

- El atributo `diagnosis_name` depende únicamente de `diagnosis_id`, no de toda la clave `{visit_id, diagnosis_id}`.
- **Acción 2FN:** Se aísla el catálogo `diagnoses(id PK, code, name, description, is_glaucoma_type)` y en `visit_diagnoses` únicamente se almacena la relación `{visit_id FK, diagnosis_id FK, is_primary, notes}`.

De igual forma, en `TREATMENTS`:
- Si se dejara la descripción del medicamento (`medication_name`, `active_ingredient`, `concentration`) dentro de la prescripción, dependería únicamente de `medication_id`.
- **Acción 2FN:** Se independiza la tabla de catálogo `medications(id PK, name, generic_name, concentration, presentation)` vinculada mediante llave foránea en `treatments`.

**Resultado 2FN:** Se eliminan todas las dependencias funcionales parciales.

---

## 2.4. Tercera Forma Normal (3FN)

### Requisitos teóricos:
1. La relación debe estar en **2FN**.
2. **Ausencia de dependencias funcionales transitivas**: Ningún atributo no clave debe depender transitivamente de la clave primaria ($X \rightarrow Y$ y $Y \rightarrow Z \implies X \rightarrow Z$ donde $Y$ no es superclave).

### Análisis y corrección:
1. **Ubicación Geográfica de Pacientes:**
   - En la tabla de pacientes se tenía:
     $$patient\_id \rightarrow city\_id$$
     $$city\_id \rightarrow \{city\_name, department\_name\}$$
   - El atributo `department_name` dependía transitivamente de `patient_id` a través de `city_id`.
   - **Acción 3FN:** Se crean las tablas `cities(id PK, name, department_id FK)` y `departments(id PK, name)`. En `patients` solo se guarda `city_id FK`.
2. **Especialidad de Profesionales:**
   - En `healthcare_professionals`:
     $$professional\_id \rightarrow specialty\_id$$
     $$specialty\_id \rightarrow \{specialty\_name, description\}$$
   - **Acción 3FN:** Se crea el catálogo `specialties(id PK, name, description)`. En `healthcare_professionals` se referencia `specialty_id FK`.

**Resultado 3FN:** Todo atributo no primo depende directa y exclusivamente de la clave primaria.

---

## 2.5. Forma Normal de Boyce-Codd (BCNF / FNBC)

### Requisitos teóricos:
Una relación está en BCNF si y solo si, para cada dependencia funcional no trivial $X \rightarrow Y$, **$X$ es una superclave**.

### Verificación en el modelo:
- En `clinical_histories`:
  $$id \rightarrow patient\_id$$
  $$patient\_id \rightarrow id$$
  Dado que existe una restricción `UNIQUE(patient_id)`, ambos determinantes (`id` y `patient_id`) son superclaves candidatas válidas.
- En `patients`:
  $$id \rightarrow document\_number$$
  $$document\_number \rightarrow id$$
  La restricción `UNIQUE uq_patient_document (document_number)` convierte a `document_number` en clave candidata, así que cualquier búsqueda unívoca parte de una superclave. Lo mismo ocurre en `healthcare_professionals` con `document_number`, `medical_license` y `email`.
- En todas las tablas operativas, el determinante de cada dependencia funcional constituye la clave primaria o una clave candidata explícita. Por consiguiente, el modelo satisface plenamente **BCNF**.

---

## 2.6. Cuarta Forma Normal (4FN)

### Requisitos teóricos:
1. La relación debe encontrarse en **BCNF**.
2. **Ausencia de dependencias multivaluadas independientes (MVDs)**:
   Si una relación contiene tres o más atributos ($X, Y, Z$) y existe una dependencia multivaluada $X \twoheadrightarrow Y$ tal que para un valor de $X$ hay un conjunto de valores de $Y$ que es completamente independiente del conjunto de valores de $Z$ ($X \twoheadrightarrow Z$), entonces la relación debe descomponerse en dos relaciones binarias: $\{X, Y\}$ y $\{X, Z\}$.

### Caso de Estudio Crucial en Oftalmología:
Un paciente $P$ posee múltiples **Alergias** ($A$) y simultáneamente múltiples **Antecedentes Familiares** ($AF$).
- Las alergias del paciente son independientes de sus antecedentes familiares patológicos.
- Si intentáramos representar esto en una tabla unificada `patient_conditions(patient_id, allergy, family_history)`:

| patient_id | allergy | family_history |
|---|---|---|
| 1 | Penicilina | Glaucoma materno |
| 1 | Penicilina | Diabetes paterna |
| 1 | Sulfas | Glaucoma materno |
| 1 | Sulfas | Diabetes paterna |

Para representar 2 alergias y 2 antecedentes familiares independientes, se generan **4 tuplas artificiales** (producto cartesiano $2 \times 2$). Si el paciente desarrolla una 3ra alergia, se deben insertar 2 nuevas filas redundantes.
Esto viola formalmente la **4FN**:

$$patient\_id \twoheadrightarrow allergy$$
$$patient\_id \twoheadrightarrow family\_history$$
$$allergy \perp family\_history$$

### Solución aplicada en 4FN:
Descomposición estricta en dos relaciones independientes:
1. `patient_allergies(id PK, patient_id FK, allergen, reaction, severity)`:
   - Clave candidata `UNIQUE uq_patient_allergen (patient_id, allergen)`: un alérgeno se registra una sola vez por paciente.
2. `patient_family_histories(id PK, patient_id FK, condition_name, relationship, notes)`:
   - Cada fila es un antecedente familiar independiente; la `PRIMARY KEY` es el identificador sustituto `id`.

### Segundo caso de 4FN en el dominio:
- **Antecedentes personales ($P 	woheadrightarrow AP$):**
  Un paciente también tiene un conjunto de antecedentes personales (ej. hipertensión arterial, cirugía refractiva LASIK, trauma ocular, uso crónico de corticoides), independiente de sus alergias y de sus antecedentes familiares.
  Se desacopla en una tercera relación, `patient_antecedents(id PK, patient_id FK, antecedent_type, description, year_diagnosed)`.
  La categoría del antecedente (`antecedent_type ENUM('PATOLOGICO','QUIRURGICO','TRAUMATICO','FARMACOLOGICO')`) es un atributo del mismo hecho y no un conjunto independiente, por lo que no genera una nueva dependencia multivaluada ni requiere tablas separadas por tipo.
- **Separación de exámenes especializados independientes:**
  Cada examen diagnóstico (`oct_exams`, `visual_field_exams`, `pachymetry_exams`, `gonioscopy_exams`) responde a mediciones físicas y parámetros distintos. Desacoplarlos de la consulta principal y permitir múltiples instancias por ojo y técnica cumple de forma natural con los principios de 4FN.

---

## 2.7. Resumen de la Arquitectura Normalizada
El esquema resultante consta de más de **22 tablas relacionales** en 4FN:
1. `departments` (Catálogo geográfico nivel 1)
2. `cities` (Catálogo geográfico nivel 2)
3. `document_types` (Tipos de identificación)
4. `specialties` (Especialidades médicas)
5. `patients` (Datos demográficos del paciente)
6. `patient_allergies` (4FN: Alergias independientes)
7. `patient_family_histories` (4FN: Antecedentes familiares independientes)
8. `patient_antecedents` (4FN: Antecedentes médicos personales)
9. `healthcare_professionals` (Médicos y optómetras)
10. `clinical_histories` (Expediente único 1:1 con el paciente)
11. `medical_visits` (Consultas médicas 1:N)
12. `diagnoses` (Catálogo CIE-10 y glaucoma)
13. `visit_diagnoses` (Entidad asociativa 1:N consulta - diagnósticos)
14. `intraocular_pressures` (Mediciones de PIO por ojo y visita)
15. `pachymetry_exams` (Medición de paquimetría CCT por ojo)
16. `gonioscopy_exams` (Clasificación de ángulo gonioscópico)
17. `oct_exams` (Tomografía RNFL y células ganglionares)
18. `visual_field_exams` (Campimetría: MD, PSD, VFI)
19. `medications` (Catálogo farmacéutico)
20. `treatments` (Prescripciones farmacológicas con temporalidad y posología)
21. `procedures` (Cirugías y procedimientos láser realizados)
22. `glaucoma_records` (Expediente específico de glaucoma y PIO objetivo)
23. `glaucoma_controls` (Controles periódicos de evolución y estadiaje)
24. `clinical_documents` (Adjuntos y documentos clínicos)
25. `audit_logs` (Registro inmutable de auditoría transversal)
