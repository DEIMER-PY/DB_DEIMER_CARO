# Formulación del problema

## Título

**Diseño e implementación de una base de datos relacional normalizada para la gestión de historias clínicas de pacientes del área de oftalmología y glaucoma.**

## Problema

El área de oftalmología y glaucoma maneja información clínica que posee múltiples relaciones y una alta dependencia del histórico del paciente. Un diseño de datos inadecuado puede generar redundancia, inconsistencias, pérdida de trazabilidad y dificultades para consultar la evolución clínica.

Por esta razón, se requiere construir una base de datos relacional en MySQL que permita organizar correctamente pacientes, historias clínicas, consultas, diagnósticos, antecedentes, exámenes oftalmológicos, tratamientos y controles de glaucoma.

El diseño deberá aplicar técnicas de modelado conceptual, lógico y físico, así como un proceso de normalización hasta la Cuarta Forma Normal. Posteriormente se deberán implementar mecanismos de consulta y procesamiento mediante SQL, incluyendo consultas básicas, intermedias y avanzadas, subconsultas, funciones agregadas, vistas, procedimientos almacenados, funciones, triggers y eventos.

El resultado deberá ser una base de datos íntegra, consistente, escalable y capaz de responder consultas relacionadas con el seguimiento histórico y clínico de los pacientes.

Cada paciente puede asistir a múltiples consultas a lo largo del tiempo y, durante cada atención, pueden generarse diferentes tipos de datos clínicos.

Por ejemplo:

```
Paciente
   |
   +-- Datos personales
   |
   +-- Historia clínica
   |
   +-- Antecedentes
   |
   +-- Consultas
   |      |
   |      +-- Diagnósticos
   |      +-- Examen oftalmológico
   |      +-- Presión intraocular
   |      +-- Tratamientos
   |
   +-- Estudios especializados
          |
          +-- OCT
          +-- Campo visual
          +-- Paquimetría
          +-- Gonioscopía
```

En pacientes con glaucoma, la necesidad de conservar información histórica es aún mayor, debido a que variables como la presión intraocular, el estado del nervio óptico, la paquimetría, los resultados de OCT y los campos visuales deben compararse entre diferentes controles.

Si esta información se almacena de manera desestructurada, pueden aparecer problemas como:

- duplicidad de datos;
- inconsistencias entre registros;
- redundancia;
- dificultad para establecer relaciones entre consultas y resultados;
- pérdida de trazabilidad;
- dificultad para consultar la evolución histórica;
- dificultad para obtener indicadores;
- problemas para generar reportes;
- almacenamiento de información repetida;
- dependencia excesiva de campos de texto libre.

Por esta razón se requiere diseñar una base de datos relacional que permita representar correctamente la información clínica y mantener su integridad.

# 2. Situación problema

La información de una historia clínica oftalmológica está compuesta por múltiples entidades relacionadas entre sí.

Por ejemplo, un paciente puede presentar:

```
1 paciente
      |
      +-- 1 historia clínica
      |
      +-- N consultas
      |
      +-- N diagnósticos
      |
      +-- N tratamientos
      |
      +-- N mediciones de presión intraocular
      |
      +-- N estudios OCT
      |
      +-- N campos visuales
```

Además, muchas variables deben manejarse separadamente para:

```
OD = ojo derecho
OI = ojo izquierdo
```

Un diseño inadecuado podría conducir a estructuras como:

```
paciente
--------------------------------------------------
id
nombre
diagnostico1
diagnostico2
diagnostico3
medicamento1
medicamento2
presion_od_1
presion_oi_1
presion_od_2
presion_oi_2
oct1
oct2
campo_visual1
campo_visual2
```

Este diseño presenta importantes problemas de normalización.

Entre ellos:

- grupos repetitivos;
- múltiples valores dentro de una misma entidad;
- dificultad para agregar nuevos registros;
- redundancia;
- anomalías de inserción;
- anomalías de actualización;
- anomalías de eliminación.

Por esta razón será necesario aplicar un proceso formal de normalización.

# 3. Problema central

Se requiere diseñar una base de datos relacional en MySQL que permita gestionar de forma estructurada la información correspondiente a historias clínicas de pacientes atendidos en el área de oftalmología y glaucoma.

El diseño deberá permitir representar adecuadamente las relaciones existentes entre pacientes, historias clínicas, consultas, diagnósticos, antecedentes, medicamentos, tratamientos, estudios oftalmológicos y controles de glaucoma.

La estructura deberá minimizar redundancias y anomalías mediante un proceso de normalización hasta alcanzar la **Cuarta Forma Normal —4FN—**.

Además, la base de datos deberá permitir realizar operaciones de consulta y procesamiento de información utilizando SQL en diferentes niveles de complejidad.

# 4. Pregunta problema

**¿Cómo diseñar e implementar una base de datos relacional en MySQL, normalizada hasta la Cuarta Forma Normal, que permita almacenar, relacionar, consultar y procesar eficientemente la información de las historias clínicas de pacientes del área de oftalmología y glaucoma?**

# 5. Objetivo general

Diseñar e implementar una base de datos relacional en MySQL para la gestión de historias clínicas del área de oftalmología y glaucoma, aplicando técnicas de modelado de datos, normalización hasta 4FN, integridad referencial y consultas SQL de diferentes niveles de complejidad.

# 6. Objetivos específicos

1. Identificar las entidades, atributos y relaciones necesarias para representar la información clínica de pacientes de oftalmología y glaucoma.
2. Construir el modelo conceptual de la base de datos.
3. Diseñar el modelo lógico relacional.
4. Elaborar el Diagrama Entidad-Relación —DER—.
5. Aplicar el proceso de normalización hasta alcanzar la Cuarta Forma Normal.
6. Implementar el modelo físico utilizando MySQL.
7. Definir claves primarias y foráneas.
8. Implementar restricciones de integridad utilizando:

```
PRIMARY KEY
FOREIGN KEY
NOT NULL
UNIQUE
CHECK
DEFAULT
```

1. Insertar datos de prueba coherentes con el dominio del problema.
2. Construir consultas SQL básicas.
3. Construir consultas SQL de nivel intermedio.
4. Construir consultas SQL avanzadas.
5. Implementar subconsultas.
6. Aplicar funciones agregadas.
7. Utilizar agrupamientos con `GROUP BY` y filtros con `HAVING`.
8. Implementar vistas para facilitar consultas recurrentes.
9. Desarrollar procedimientos almacenados.
10. Implementar funciones almacenadas.
11. Crear disparadores —triggers— para automatizar operaciones y auditoría.
12. Utilizar eventos programados cuando el caso de estudio lo requiera.

# 7. Alcance del proyecto

El proyecto estará limitado al diseño, implementación y explotación de la base de datos.

No incluirá:

```
Frontend
Aplicación web
Aplicación móvil
API REST
Backend
Interfaces gráficas
```

El producto principal será una base de datos funcional en MySQL.

# 8. Alcance funcional de la base de datos

La base de datos deberá permitir gestionar información relacionada con:

```
Pacientes
Historias clínicas
Profesionales
Consultas
Antecedentes
Diagnósticos
Especialidades
Exámenes oftalmológicos
Presión intraocular
Paquimetrías
Gonioscopías
OCT
Campos visuales
Tratamientos
Medicamentos
Procedimientos
Controles de glaucoma
Archivos clínicos
Auditoría
```

# 9. Entidades preliminares

A partir del análisis inicial podrían identificarse entidades como:

```
patients
clinical_histories
medical_visits
healthcare_professionals
specialties
medical_histories
diagnoses
visit_diagnoses
ophthalmologic_exams
intraocular_pressures
pachymetry_exams
gonioscopy_exams
oct_exams
visual_field_exams
glaucoma_records
glaucoma_controls
medications
treatments
procedures
clinical_documents
audit_logs
```

Estas entidades deberán validarse y refinarse durante el modelado.

# 10. Modelo conceptual esperado

En el modelo conceptual deberán representarse las entidades principales sin depender todavía de detalles específicos del motor MySQL.

Una aproximación inicial podría ser:

```
PACIENTE
   |
   | 1
   |
   | 1
   v
HISTORIA_CLINICA
   |
   | 1
   |
   | N
   v
CONSULTA
   |
   +------------------+
   |                  |
   v                  v
DIAGNOSTICO       EXAMEN_OFTALMOLOGICO
                      |
        +-------------+-------------+
        |             |             |
        v             v             v
       PIO           OCT       CAMPO_VISUAL
```

Además:

```
PACIENTE
   |
   | 1
   |
   | N
   v
TRATAMIENTO
```

y:

```
PACIENTE
   |
   | 1
   |
   | N
   v
CONTROL_GLAUCOMA
```

# 11. Modelo lógico esperado

El modelo lógico deberá transformar las entidades conceptuales en relaciones.

Ejemplo:

```
PATIENTS
-------
id PK
document_type_id FK
document_number
first_name
last_name
birth_date
sex

CLINICAL_HISTORIES
------------------
id PK
patient_id FK

MEDICAL_VISITS
--------------
id PK
clinical_history_id FK
professional_id FK
visit_date
reason
assessment
plan
```

El modelo completo deberá incluir todas las claves y cardinalidades.

# 12. Diagrama Entidad-Relación

El DER deberá representar:

- entidades;
- atributos;
- claves primarias;
- claves foráneas;
- relaciones;
- cardinalidades;
- participación;
- entidades asociativas.

Por ejemplo:

```
PATIENT
1
|
|
1
CLINICAL_HISTORY

CLINICAL_HISTORY
1
|
|
N
MEDICAL_VISIT

MEDICAL_VISIT
N
|
|
N
DIAGNOSIS
```

La relación muchos a muchos entre consulta y diagnóstico deberá resolverse mediante una entidad asociativa:

```
VISIT_DIAGNOSES
```

# 13. Proceso de normalización

Uno de los componentes principales del proyecto será demostrar el proceso de normalización.

La normalización deberá desarrollarse progresivamente.

# 14. Datos no normalizados

Podría partirse de una estructura como:

```
HISTORIA_CLINICA

paciente
documento
telefono
consulta_fecha
diagnosticos
medicamentos
presion_od
presion_oi
oct
campo_visual
```

Ejemplo:

```
Paciente:
Carlos Gómez

Diagnósticos:
Glaucoma, Catarata

Medicamentos:
Latanoprost, Timolol
```

Aquí existen valores multivaluados.

# 15. Primera Forma Normal —1FN

La 1FN exige:

- atributos atómicos;
- ausencia de grupos repetitivos;
- una celda debe contener un solo valor.

Incorrecto:

```
diagnosticos:
Glaucoma, Catarata
```

Correcto:

```
VISIT_DIAGNOSES

visit_id | diagnosis_id
------------------------
1        | 5
1        | 8
```

# 16. Segunda Forma Normal —2FN

La 2FN requiere:

- estar en 1FN;
- eliminar dependencias parciales respecto a claves compuestas.

Ejemplo:

```
VISIT_DIAGNOSES

visit_id
diagnosis_id
diagnosis_name
```

Si:

```
diagnosis_name
```

depende únicamente de:

```
diagnosis_id
```

debe trasladarse a:

```
DIAGNOSES
```

# 17. Tercera Forma Normal —3FN

La 3FN elimina dependencias transitivas.

Ejemplo incorrecto:

```
PATIENTS

patient_id
city_id
city_name
department_name
```

Si:

```
patient_id -> city_id
city_id -> city_name
```

entonces:

```
city_name
```

no debe almacenarse directamente en `patients`.

Se crean catálogos independientes.

# 18. Forma Normal de Boyce-Codd —BCNF

Cuando sea pertinente, deberán revisarse dependencias funcionales más estrictas.

Toda dependencia funcional:

```
X -> Y
```

deberá tener como determinante una superclave.

# 19. Cuarta Forma Normal —4FN

La 4FN será especialmente importante en este proyecto debido a la existencia de atributos multivaluados independientes.

Supóngase:

```
PATIENT

patient_id
allergy
family_history
```

Un paciente puede tener:

```
N alergias
```

y también:

```
N antecedentes familiares
```

ambos independientes.

Una única relación podría producir combinaciones artificiales:

```
Alergia A + Antecedente 1
Alergia A + Antecedente 2
Alergia B + Antecedente 1
Alergia B + Antecedente 2
```

Esto representa una dependencia multivaluada.

Para alcanzar 4FN deberían separarse:

```
PATIENT_ALLERGIES
```

y:

```
PATIENT_FAMILY_HISTORIES
```

# 20. Ejemplo de aplicación de 4FN en el proyecto

Otra situación:

Un paciente puede tener múltiples:

```
medicamentos
```

y múltiples:

```
antecedentes
```

Estos conjuntos no dependen entre sí.

Incorrecto:

```
patient_medications_histories
```

Correcto:

```
PATIENT_MEDICATIONS

patient_id
medication_id
```

y:

```
PATIENT_HISTORIES

patient_id
history_type_id
description
```

# 21. Implementación física en MySQL

Después de validar el modelo lógico, deberá construirse el modelo físico mediante:

```
CREATE DATABASE
CREATE TABLE
ALTER TABLE
```

Se deberán utilizar tipos apropiados como:

```
BIGINT
INT
VARCHAR
TEXT
DATE
DATETIME
DECIMAL
BOOLEAN
```

### 21.1 Inicialización de la Base de Datos (`00_init_database.sql`)

Crea la base de datos `oftalmologia_glaucoma_db` con codificación `utf8mb4` y `COLLATE utf8mb4_unicode_ci`, activando el programador de eventos de MySQL (`event_scheduler = ON`):

```sql
-- =============================================================================
-- PROYECTO: HISTORIAS CLÍNICAS DE OFTALMOLOGÍA Y GLAUCOMA
-- AUTOR: Deimer Caro
-- ARCHIVO: 00_init_database.sql
-- DESCRIPCIÓN: Creación y configuración inicial de la base de datos
-- =============================================================================

DROP DATABASE IF EXISTS oftalmologia_glaucoma_db;

CREATE DATABASE oftalmologia_glaucoma_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE oftalmologia_glaucoma_db;

-- Habilitar el programador de eventos de MySQL
SET GLOBAL event_scheduler = ON;

SELECT 'Base de datos oftalmologia_glaucoma_db inicializada correctamente' AS estado;
```

### 21.2 Esquema Físico Relacional en 4FN (`01_ddl_schema.sql`)

Crea las 32 tablas relacionales normalizadas en Cuarta Forma Normal (4FN), 5 tablas de respaldo para auditoría histórica, índices de rendimiento y restricciones de integridad:

```sql
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
```

# 22. Restricciones

El proyecto deberá implementar restricciones.

Ejemplo:

```
CREATE TABLE patients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_number VARCHAR(30) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,

    CONSTRAINT uq_patient_document
        UNIQUE(document_number)
);
```

# 23. Integridad referencial

Ejemplo:

```
CREATE TABLE clinical_histories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,

    CONSTRAINT uq_history_patient
        UNIQUE(patient_id),

    CONSTRAINT fk_history_patient
        FOREIGN KEY(patient_id)
        REFERENCES patients(id)
);
```

# 24. Datos de prueba

El proyecto deberá incluir información suficiente para validar las consultas.

Por ejemplo:

```
20 pacientes
5 profesionales
10 tipos de diagnósticos
30 consultas
50 mediciones PIO
20 OCT
20 campos visuales
15 tratamientos
```

Los datos deberán ser coherentes con las relaciones definidas.

### 24.1 Dataset Clínico Semilla (`02_dml_seed_data.sql`)

Carga el dataset clínico completo de prueba con departamentos, ciudades, tipos de documentos, especialidades, profesionales de salud, pacientes, antecedentes personales y familiares, alergias, historias clínicas, consultas médicas, diagnósticos CIE-11, mediciones de presión intraocular (PIO), paquimetría, gonioscopía, tomografías de coherencia óptica (OCT), campimetrías computarizadas (campos visuales), catálogo farmacológico, tratamientos médicos, procedimientos quirúrgicos, registros y controles de progresión de glaucoma y bitácora de auditoría:

```sql
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
```

# 25. Consultas básicas

Deberán desarrollarse consultas como:

```
SELECT *
FROM patients;
```

Buscar por identificación:

```
SELECT *
FROM patients
WHERE document_number = '1098123456';
```

Ordenar:

```
SELECT *
FROM patients
ORDER BY last_name;
```

# 26. Consultas intermedias

Deberán utilizarse:

```
JOIN
ORDER BY
GROUP BY
HAVING
DISTINCT
CASE
```

Ejemplo:

```sql
SELECT
    p.first_name,
    p.last_name,
    mv.visit_date
FROM patients p
INNER JOIN clinical_histories ch
    ON p.id = ch.patient_id
INNER JOIN medical_visits mv
    ON ch.id = mv.clinical_history_id;
```

# 27. Consultas avanzadas

Ejemplo:

Obtener cada paciente con su última consulta:

```sql
SELECT
    p.id,
    p.first_name,
    p.last_name,
    MAX(mv.visit_date) AS last_visit
FROM patients p
INNER JOIN clinical_histories ch
    ON p.id = ch.patient_id
INNER JOIN medical_visits mv
    ON ch.id = mv.clinical_history_id
GROUP BY
    p.id,
    p.first_name,
    p.last_name;
```

# 28. Subconsultas

Ejemplo:

Obtener pacientes con más consultas que el promedio:

```sql
SELECT
    patient_id,
    total_visits
FROM (
    SELECT
        ch.patient_id,
        COUNT(*) AS total_visits
    FROM clinical_histories ch
    INNER JOIN medical_visits mv
        ON ch.id = mv.clinical_history_id
    GROUP BY ch.patient_id
) x
WHERE total_visits > (
    SELECT AVG(total_visits)
    FROM (
        SELECT
            COUNT(*) AS total_visits
        FROM clinical_histories ch
        INNER JOIN medical_visits mv
            ON ch.id = mv.clinical_history_id
        GROUP BY ch.patient_id
    ) y
);
```

# 29. Funciones agregadas

El proyecto deberá utilizar:

```
COUNT
SUM
AVG
MIN
MAX
```

Ejemplo:

```sql
SELECT
    AVG(pressure) AS average_pressure,
    MIN(pressure) AS minimum_pressure,
    MAX(pressure) AS maximum_pressure
FROM intraocular_pressures;
```

# 30. GROUP BY

Ejemplo:

```sql
SELECT
    eye,
    AVG(pressure) AS average_pressure
FROM intraocular_pressures
GROUP BY eye;
```

# 31. HAVING

Ejemplo:

```
SELECT
    patient_id,
    COUNT(*) AS controlsS
FROM glaucoma_controls
GROUP BY patient_id
HAVING COUNT(*) >= 3;
```

# 32. Procedimientos almacenados

Deberán implementarse procedimientos que representen operaciones del dominio.

Ejemplo conceptual:

```
sp_create_medical_visit
sp_register_intraocular_pressure
sp_register_diagnosis
sp_get_patient_history
```

Ejemplo:

```
DELIMITER $$

CREATE PROCEDURE sp_get_patient_visits(
    IN p_patient_id BIGINT
)
BEGIN

    SELECT
        mv.id,
        mv.visit_date,
        mv.reason
    FROM clinical_histories ch
    INNER JOIN medical_visits mv
        ON ch.id = mv.clinical_history_id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC;

END $$

DELIMITER ;
```

# 33. Funciones almacenadas

Ejemplo:

Calcular edad del paciente:

```
DELIMITER $$

CREATE FUNCTION fn_patient_age(
    p_birth_date DATE
)
RETURNS INT
DETERMINISTIC
BEGIN

    RETURN TIMESTAMPDIFF(
        YEAR,
        p_birth_date,
        CURDATE()
    );

END $$

DELIMITER ;
```

Consulta:

```
SELECT
    first_name,
    last_name,
    fn_patient_age(birth_date) AS age
FROM patients;
```

# 34. Triggers

Se deberán utilizar triggers cuando exista una justificación clara.

Ejemplo:

Crear auditoría automática de cambios.

```
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100),
    record_id BIGINT,
    action VARCHAR(20),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

Trigger:

```
DELIMITER $$

CREATE TRIGGER trg_patient_after_update
AFTER UPDATE
ON patients
FOR EACH ROW
BEGIN

    INSERT INTO audit_logs(
        table_name,
        record_id,
        action
    )
    VALUES(
        'patients',
        NEW.id,
        'UPDATE'
    );

END $$

DELIMITER ;
```

# 35. Otros triggers posibles

```
Auditar cambios en consultas
Auditar tratamientos
Registrar cambios de diagnóstico
Registrar eliminación lógica
Actualizar fechas de modificación
```

# 36. Eventos

Si se desea incorporar eventos MySQL, podrían utilizarse para tareas como:

```
limpieza periódica de registros temporales
generación de resúmenes
actualización de tablas de indicadores
```

Ejemplo:

```
CREATE EVENT ev_daily_statistics
ON SCHEDULE EVERY 1 DAY
DO
    CALL sp_generate_daily_statistics();
```

### 36.1 Implementación de Eventos Programados (`08_views_and_events.sql`)

Eventos programados en el motor MySQL (`event_scheduler = ON`) para el mantenimiento preventivo semanal de la bitácora de auditoría y la verificación diaria automática del estado de tratamientos caducados:

```sql
-- ==============================================================================
-- EVENTOS PROGRAMADOS(Event Scheduler)
-- ==============================================================================

SET GLOBAL event_scheduler = ON;

DELIMITER $$

-- Evento 1: Depuración Semanal de Auditoría y Notificaciones Antiguas
DROP EVENT IF EXISTS ev_weekly_audit_maintenance $$
CREATE EVENT ev_weekly_audit_maintenance
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
COMMENT 'Mantenimiento preventivo periódico de la tabla de auditoría'
DO
BEGIN
    -- Registro de ejecución del evento
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('SYSTEM_MAINTENANCE', 0, 'INSERT',
            JSON_OBJECT('event', 'ev_weekly_audit_maintenance', 'status', 'SUCCESS'),
            'EVENT_SCHEDULER', NOW());
END $$

-- Evento 2: Verificación Diaria de Tratamientos Vencidos
DROP EVENT IF EXISTS ev_daily_treatment_status_check $$
CREATE EVENT ev_daily_treatment_status_check
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
COMMENT 'Actualización automática del estado de tratamientos caducados'
DO
BEGIN
    UPDATE treatments
    SET is_active = FALSE
    WHERE end_date IS NOT NULL 
      AND end_date < CURDATE() 
      AND is_active = TRUE;
END $$

DELIMITER ;

SELECT 'Vistas y eventos programados creados exitosamente' AS estado;
```

# 37. Vistas

También deberían incorporarse vistas.

Por ejemplo:

```
CREATE VIEW vw_patient_last_visit AS
SELECT
    p.id AS patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient,
    MAX(mv.visit_date) AS last_visit
FROM patients p
INNER JOIN clinical_histories ch
    ON p.id = ch.patient_id
INNER JOIN medical_visits mv
    ON ch.id = mv.clinical_history_id
GROUP BY
    p.id,
    p.first_name,
    p.last_name;
```

### 37.1 Implementación de Vistas Clínicas y Analíticas (`08_views_and_events.sql`)

Ocho vistas analíticas especializadas para resumen integral de historias clínicas, última consulta asistida, tratamientos farmacológicos activos, monitoreo continuo de glaucoma, PIO bilateral comparativa, consolidado de exámenes paraclínicos (OCT, campo visual, paquimetría), productividad y carga laboral de especialistas médicos y bitácora de alertas de auditoría:

```sql
-- ==============================================================================
-- PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
-- AUTOR: Deimer Caro
-- ARCHIVO: 08_views_and_events.sql
-- DESCRIPCIÓN: Definición de Vistas de Explotación Clínica y Eventos Programados
-- MOTOR: MySQL 8.0 (InnoDB)
-- ==============================================================================

USE oftalmologia_glaucoma_db;

-- ==============================================================================
-- VISTAS CLÍNICAS Y DE GESTIÓN
-- ==============================================================================

-- 1. Vista de Resumen de Pacientes e Historia Clínica
DROP VIEW IF EXISTS vw_patient_summary;
CREATE VIEW vw_patient_summary AS
SELECT 
    p.id AS patient_id,
    per.document_number,
    dt.code AS doc_type,
    CONCAT(per.first_name, ' ', per.last_name) AS full_name,
    per.birth_date,
    TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) AS age,
    per.gender,
    c.name AS city_name,
    per.phone,
    per.email,
    ch.history_number,
    ch.status AS history_status,
    ch.created_at AS history_created_at
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN document_types dt ON per.document_type_id = dt.id
JOIN cities c ON per.city_id = c.id
JOIN clinical_histories ch ON p.id = ch.patient_id;

-- 2. Vista de Última Consulta por Paciente
DROP VIEW IF EXISTS vw_patient_last_visit;
CREATE VIEW vw_patient_last_visit AS
SELECT 
    p.id AS patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    ch.history_number,
    COUNT(mv.id) AS total_visits,
    MAX(mv.visit_date) AS last_visit_date,
    DATEDIFF(CURDATE(), DATE(MAX(mv.visit_date))) AS days_since_last_visit
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name, ch.history_number;

-- 3. Vista de Tratamientos Activos con Detalles Clínicos
DROP VIEW IF EXISTS vw_active_treatments;
CREATE VIEW vw_active_treatments AS
SELECT 
    t.id AS treatment_id,
    p.id AS patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    m.name AS medication_name,
    mc.name AS medication_class,
    m.generic_name,
    m.concentration,
    t.eye,
    t.dosage,
    t.frequency,
    t.start_date,
    t.end_date,
    t.notes
FROM treatments t
JOIN medications m ON t.medication_id = m.id
JOIN medication_classes mc ON m.medication_class_id = mc.id
JOIN medical_visits mv ON t.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE t.is_active = TRUE;

-- 4. Vista de Monitoreo Integral de Glaucoma
DROP VIEW IF EXISTS vw_glaucoma_monitoring;
CREATE VIEW vw_glaucoma_monitoring AS
SELECT 
    gr.id AS glaucoma_record_id,
    p.id AS patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    gr.clinical_stage,
    gr.target_iop_od,
    gr.target_iop_oi,
    gr.diagnosis_date,
    COUNT(gc.id) AS total_controls,
    MAX(gc.control_date) AS last_control_date,
    MAX(gc.is_progression_detected) AS progression_flag
FROM glaucoma_records gr
JOIN patients p ON gr.patient_id = p.id
JOIN persons per ON p.person_id = per.id
LEFT JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
GROUP BY gr.id, p.id, patient_name, gr.clinical_stage, gr.target_iop_od, gr.target_iop_oi, gr.diagnosis_date;

-- 5. Vista de Presión Intraocular Bilateral por Consulta
DROP VIEW IF EXISTS vw_iop_bilateral;
CREATE VIEW vw_iop_bilateral AS
SELECT 
    mv.id AS visit_id,
    p.id AS patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    mv.visit_date,
    MAX(CASE WHEN iop.eye = 'OD' THEN iop.pressure END) AS iop_od,
    MAX(CASE WHEN iop.eye = 'OI' THEN iop.pressure END) AS iop_oi,
    MAX(iop.method) AS method
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
JOIN intraocular_pressures iop ON mv.id = iop.visit_id
GROUP BY mv.id, p.id, patient_name, mv.visit_date;

-- 6. Vista de Exámenes Especializados Consolidados
DROP VIEW IF EXISTS vw_specialized_exams;
CREATE VIEW vw_specialized_exams AS
SELECT 
    'OCT' AS exam_type,
    oct.id AS exam_id,
    oct.visit_id,
    ch.patient_id,
    oct.eye,
    oct.exam_date,
    CONCAT('RNFL: ', oct.rnfl_average, ' µm') AS metric_primary,
    oct.interpretation
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
UNION ALL
SELECT 
    'CAMPO_VISUAL',
    vf.id,
    vf.visit_id,
    ch.patient_id,
    vf.eye,
    vf.exam_date,
    CONCAT('VFI: ', vf.visual_field_index_vfi, '% | MD: ', vf.mean_deviation_md, ' dB'),
    vf.interpretation
FROM visual_field_exams vf
JOIN medical_visits mv ON vf.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
UNION ALL
SELECT 
    'PAQUIMETRIA',
    pe.id,
    pe.visit_id,
    ch.patient_id,
    pe.eye,
    pe.exam_date,
    CONCAT('Espesor: ', pe.corneal_thickness, ' µm'),
    pe.method
FROM pachymetry_exams pe
JOIN medical_visits mv ON pe.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
UNION ALL
SELECT 
    'AGUDEZA_VISUAL',
    va.id,
    va.visit_id,
    ch.patient_id,
    va.eye,
    va.exam_date,
    CONCAT('SC: ', va.uncorrected_va, ' | CC: ', va.corrected_va),
    CONCAT('Esfera: ', IFNULL(va.sphere, 0.00), ' Cil: ', IFNULL(va.cylinder, 0.00), ' Eje: ', IFNULL(va.axis, 0))
FROM visual_acuity_exams va
JOIN medical_visits mv ON va.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
UNION ALL
SELECT 
    'BIOMICROSCOPIA',
    bio.id,
    bio.visit_id,
    ch.patient_id,
    bio.eye,
    bio.exam_date,
    CONCAT('Cámara: ', bio.anterior_chamber_depth, ' | Cristalino: ', bio.lens_status),
    CONCAT('Córnea: ', bio.cornea_status, ' | Iris: ', bio.iris_status, ' | PXF: ', IF(bio.pseudoexfoliation_present, 'SI', 'NO'))
FROM biomicroscopy_exams bio
JOIN medical_visits mv ON bio.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id;

-- 7. Vista de Productividad por Profesional
DROP VIEW IF EXISTS vw_physician_workload;
CREATE VIEW vw_physician_workload AS
SELECT 
    hp.id AS professional_id,
    CONCAT(per.first_name, ' ', per.last_name) AS professional_name,
    s.name AS specialty,
    COUNT(DISTINCT mv.id) AS total_visits,
    COUNT(DISTINCT ch.patient_id) AS distinct_patients_seen,
    (SELECT COUNT(*) FROM appointments a WHERE a.professional_id = hp.id) AS total_appointments,
    MIN(mv.visit_date) AS first_visit_attended,
    MAX(mv.visit_date) AS last_visit_attended
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
LEFT JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
GROUP BY hp.id, professional_name, s.name;

-- 8. Vista de Auditoría y Alertas Críticas
DROP VIEW IF EXISTS vw_audit_alerts;
CREATE VIEW vw_audit_alerts AS
SELECT 
    id AS log_id,
    table_name,
    record_id,
    action,
    new_values,
    performed_by,
    changed_at
FROM audit_logs
WHERE action = 'ALERT' OR action = 'DELETE'
ORDER BY changed_at DESC;
```

# 38. Posibles consultas requeridas

El proyecto podría exigir al estudiante construir al menos:

```
10 consultas básicas
10 consultas intermedias
10 consultas avanzadas
5 subconsultas
5 consultas con funciones agregadas
3 vistas
3 procedimientos almacenados
3 funciones
3 triggers
1 evento programado
```

# 39. Preguntas que la base de datos deberá responder

Algunos ejemplos:

1. ¿Cuántos pacientes se encuentran registrados?
2. ¿Cuántas consultas ha tenido cada paciente?
3. ¿Cuál fue la última consulta de un paciente?
4. ¿Qué pacientes tienen diagnóstico de glaucoma?
5. ¿Cuántos pacientes existen por tipo de glaucoma?
6. ¿Cuál es la presión intraocular promedio por ojo?
7. ¿Cuál es la presión máxima registrada por paciente?
8. ¿Qué pacientes tienen más de tres controles de glaucoma?
9. ¿Qué profesionales han atendido más pacientes?
10. ¿Qué medicamentos son utilizados con mayor frecuencia?
11. ¿Cuántos estudios OCT se realizaron por mes?
12. ¿Qué pacientes no han tenido consulta durante determinado período?
13. ¿Cuál es la evolución de la presión intraocular de un paciente?
14. ¿Qué pacientes presentan valores de PIO superiores a determinado umbral?
15. ¿Cuántos procedimientos se realizaron por tipo?

# 40. Producto final esperado

El proyecto deberá entregar:

```
1. Formulación del problema
2. Identificación de entidades
3. Diccionario preliminar de datos
4. Modelo conceptual
5. DER
6. Modelo lógico
7. Evidencia de normalización:
   - 1FN
   - 2FN
   - 3FN
   - BCNF cuando aplique
   - 4FN
8. Modelo físico MySQL
9. Script DDL
10. Script de datos de prueba
11. Banco de 250 ejercicios MySQL
12. Evidencias de ejecución
```

### 40.1 Arquitectura Maestra de Scripts del Repositorio

La solución integral implementada y verificada en MySQL 8.0 se estructura en la siguiente suite de scripts ordenados:

1. **`00_init_database.sql`**: Crea la base de datos `oftalmologia_glaucoma_db` con codificación `utf8mb4` y activa el programador de eventos (`event_scheduler = ON`).
2. **`01_ddl_schema.sql`**: Crea las 32 tablas relacionales normalizadas en Cuarta Forma Normal (4FN), 5 tablas de backup, llaves primarias, llaves foráneas con integridad referencial, índices y restricciones CHECK/UNIQUE.
3. **`02_dml_seed_data.sql`**: Carga el dataset clínico completo de prueba con pacientes, antecedentes, visitas, exámenes paraclínicos, tratamientos y controles de glaucoma.
4. **`03_part1_queries.sql`**: Ejecuta las 50 consultas SQL (básicas, intermedias y avanzadas).
5. **`04_part2_subqueries.sql`**: Ejecuta las 50 subconsultas SQL (escalares, IN, NOT EXISTS, correlacionadas y avanzadas).
6. **`05_part3_procedures.sql`**: Compila los 50 Procedimientos Almacenados (CRUD, reglas de negocio, validaciones con SIGNAL SQLSTATE y transacciones ACID con START TRANSACTION, COMMIT y ROLLBACK).
7. **`06_part4_triggers.sql`**: Compila los 50 Triggers (BEFORE/AFTER INSERT/UPDATE/DELETE con auditoría inmutable en JSON).
8. **`07_part5_functions.sql`**: Compila las 50 Funciones Almacenadas clínicas, diagnósticas, estadísticas y de cálculo cardiovascular/ocular.
9. **`08_views_and_events.sql`**: Compila las 8 Vistas analíticas y los 2 Eventos programados de mantenimiento en el motor.

# 42. Pregunta orientadora final

**¿Cómo modelar, normalizar e implementar en MySQL una base de datos relacional para historias clínicas de oftalmología y glaucoma que permita garantizar integridad, reducir redundancia y soportar consultas y procesos SQL de diferentes niveles de complejidad?**

# Banco de 250 ejercicios MySQL

## Proyecto: Historias clínicas de Oftalmología y Glaucoma

Este banco de ejercicios está organizado en cinco categorías:

1. Consultas SQL.
2. Subconsultas.
3. Procedimientos almacenados.
4. Triggers.
5. Funciones almacenadas.

Cada categoría contiene **50 ejercicios**, para un total de **250 actividades**.

Como referencia, se asume que la base de datos contiene entidades similares a:

```
patients
clinical_histories
medical_visits
healthcare_professionals
specialties
diagnoses
visit_diagnoses
glaucoma_records
glaucoma_controls
intraocular_pressures
pachymetry_exams
gonioscopy_exams
oct_exams
visual_field_exams
medications
treatments
procedures
clinical_documents
audit_logs
```

# PARTE I — 50 EJERCICIOS DE CONSULTAS SQL

## Nivel básico

### 1.





Mostrar todos los pacientes registrados en la base de datos.

```sql
SELECT p.id, per.document_number, per.first_name, per.last_name, per.birth_date, per.gender, p.blood_type, p.health_insurance, p.affiliation_type
FROM patients p
JOIN persons per ON p.person_id = per.id;
```

### 2.





Mostrar únicamente el número de documento, nombres y apellidos de todos los pacientes.

```sql
SELECT per.document_number, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id;
```

### 3.





Listar todos los profesionales de salud registrados.

```sql
SELECT hp.id, per.document_number, per.first_name, per.last_name, hp.medical_license, hp.specialty_id, hp.is_active
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id;
```

### 4.





Mostrar todos los diagnósticos disponibles en el catálogo.

```sql
SELECT * FROM diagnoses;
```

### 5.





Consultar todas las historias clínicas registradas.

```sql
SELECT * FROM clinical_histories;
```

### 6.





Mostrar todos los pacientes ordenados alfabéticamente por apellido.

```sql
SELECT p.id, per.document_number, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id
ORDER BY per.last_name ASC, per.first_name ASC;
```

### 7.





Mostrar los pacientes ordenados por fecha de nacimiento desde el más joven hasta el de mayor edad.

```sql
SELECT p.id, per.first_name, per.last_name, per.birth_date
FROM patients p
JOIN persons per ON p.person_id = per.id
ORDER BY per.birth_date DESC;
```

### 8.





Consultar los pacientes cuyo apellido sea `Gómez`.

```sql
SELECT p.id, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.last_name LIKE '%Gómez%' OR per.last_name LIKE '%Gomez%';
```

### 9.





Mostrar los pacientes cuyo número de documento comience por `10`.

```sql
SELECT p.id, per.document_number, per.first_name, per.last_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.document_number LIKE '10%';
```

### 10.





Consultar los pacientes cuyo correo electrónico pertenezca al dominio `gmail.com`.

```sql
SELECT p.id, per.first_name, per.last_name, per.email
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.email LIKE '%@gmail.com';
```

### 11.





Mostrar los pacientes que no tengan correo electrónico registrado.

```sql
SELECT p.id, per.first_name, per.last_name, per.email
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE per.email IS NULL;
```

### 12.





Mostrar los profesionales cuya especialidad sea Oftalmología.

```sql
SELECT hp.id, per.first_name, per.last_name, hp.medical_license, s.name AS specialty
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id
WHERE s.name = 'Oftalmología';
```

### 13.





Consultar todas las consultas médicas realizadas durante el año 2026.

```sql
SELECT * FROM medical_visits WHERE YEAR(visit_date) = 2026;
```

### 14.





Mostrar las consultas realizadas durante un mes determinado.

```sql
SELECT * FROM medical_visits WHERE YEAR(visit_date) = 2026 AND MONTH(visit_date) = 1;
```

### 15.





Consultar las mediciones de presión intraocular superiores a 20 mmHg.

```sql
SELECT * FROM intraocular_pressures WHERE pressure > 20.00;
```

### 16.





Mostrar las mediciones de presión intraocular correspondientes únicamente al ojo derecho.

```sql
SELECT * FROM intraocular_pressures WHERE eye = 'OD';
```

### 17.





Mostrar las mediciones correspondientes únicamente al ojo izquierdo.

```sql
SELECT * FROM intraocular_pressures WHERE eye = 'OI';
```

### 18.





Consultar todos los tratamientos que se encuentren activos.

```sql
SELECT * FROM treatments WHERE is_active = TRUE;
```

### 19.





Mostrar todos los tratamientos que hayan finalizado.

```sql
SELECT * FROM treatments WHERE is_active = FALSE OR (end_date IS NOT NULL AND end_date < CURDATE());
```

### 20.





Consultar los procedimientos realizados después de una fecha determinada.

```sql
SELECT * FROM procedures WHERE procedure_date >= '2026-01-01 00:00:00';
```

## Nivel intermedio

### 21.





Mostrar cada paciente junto con el número de su historia clínica.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, ch.history_number, ch.status
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id;
```

### 22.





Mostrar cada consulta indicando el nombre completo del paciente.

```sql
SELECT mv.id AS visit_id, mv.visit_date, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.reason
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;
```

### 23.





Mostrar cada consulta junto con el nombre del profesional que la realizó.

```sql
SELECT mv.id AS visit_id, mv.visit_date, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, s.name AS specialty, mv.reason
FROM medical_visits mv
JOIN healthcare_professionals hp ON mv.professional_id = hp.id
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id;
```

### 24.





Listar todos los pacientes junto con la fecha de sus consultas.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.id AS visit_id, mv.visit_date
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
ORDER BY p.id, mv.visit_date;
```

### 25.





Mostrar los diagnósticos asociados a cada consulta.

```sql
SELECT mv.id AS visit_id, mv.visit_date, d.code, d.name AS diagnosis_name, vd.is_primary, vd.notes
FROM medical_visits mv
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.id
ORDER BY mv.id, vd.is_primary DESC;
```

### 26.





Mostrar nombre del paciente, fecha de consulta y diagnóstico correspondiente.

```sql
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date, d.code, d.name AS diagnosis, vd.is_primary
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.id;
```

### 27.





Consultar todos los pacientes que tengan diagnóstico de glaucoma.

```sql
SELECT DISTINCT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, d.code, d.name AS glaucoma_diagnosis
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.id
WHERE d.is_glaucoma_type = TRUE;
```

### 28.





Mostrar todos los controles de glaucoma indicando el paciente correspondiente.

```sql
SELECT gc.id AS control_id, gc.control_date, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, gr.clinical_stage, gc.is_progression_detected, gc.adherence_score, gc.notes
FROM glaucoma_controls gc
JOIN glaucoma_records gr ON gc.glaucoma_record_id = gr.id
JOIN patients p ON gr.patient_id = p.id
JOIN persons per ON p.person_id = per.id;
```

### 29.





Mostrar cada medición de presión intraocular junto con nombre del paciente, fecha y ojo.

```sql
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date, iop.eye, iop.pressure, iop.method
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
ORDER BY mv.visit_date DESC, iop.eye;
```

### 30.





Mostrar los estudios OCT realizados indicando paciente, ojo y fecha.

```sql
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, oct.eye, oct.exam_date, oct.rnfl_average, oct.cup_to_disc_ratio, oct.interpretation
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;
```

### 31.





Mostrar los campos visuales registrados indicando paciente, ojo, MD, PSD y VFI.

```sql
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, vf.eye, vf.mean_deviation_md, vf.pattern_std_deviation_psd, vf.visual_field_index_vfi, vf.reliability, vf.exam_date
FROM visual_field_exams vf
JOIN medical_visits mv ON vf.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;
```

### 32.





Mostrar las paquimetrías realizadas junto con el paciente y el espesor corneal registrado.

```sql
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, pe.eye, pe.corneal_thickness, pe.method, pe.exam_date
FROM pachymetry_exams pe
JOIN medical_visits mv ON pe.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id;
```

### 33.





Mostrar los tratamientos activos incluyendo nombre del paciente y medicamento.

```sql
SELECT CONCAT(per.first_name, ' ', per.last_name) AS patient_name, m.name AS medication_name, m.generic_name, t.dosage, t.frequency, t.eye, t.start_date
FROM treatments t
JOIN medications m ON t.medication_id = m.id
JOIN medical_visits mv ON t.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE t.is_active = TRUE;
```

### 34.





Mostrar cada medicamento y la cantidad de tratamientos en los que ha sido utilizado.

```sql
SELECT m.id, m.name, m.generic_name, COUNT(t.id) AS total_treatments_prescribed
FROM medications m
LEFT JOIN treatments t ON m.id = t.medication_id
GROUP BY m.id, m.name, m.generic_name
ORDER BY total_treatments_prescribed DESC;
```

### 35.





Mostrar la cantidad total de pacientes registrados.

```sql
SELECT COUNT(*) AS total_patients_registered FROM patients;
```

### 36.





Mostrar la cantidad de consultas realizadas.

```sql
SELECT COUNT(*) AS total_visits_conducted FROM medical_visits;
```

### 37.





Mostrar la cantidad de pacientes por sexo.

```sql
SELECT per.gender, COUNT(*) AS total_patients
FROM patients p
JOIN persons per ON p.person_id = per.id
GROUP BY per.gender;
```

### 38.





Mostrar la cantidad de pacientes atendidos por cada profesional.

```sql
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, COUNT(DISTINCT ch.patient_id) AS distinct_patients_attended
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
LEFT JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
GROUP BY hp.id, professional_name
ORDER BY distinct_patients_attended DESC;
```

### 39.





Calcular el promedio general de presión intraocular.

```sql
SELECT ROUND(AVG(pressure), 2) AS overall_average_iop FROM intraocular_pressures;
```

### 40.





Calcular la presión intraocular mínima y máxima registrada.

```sql
SELECT MIN(pressure) AS min_iop_recorded, MAX(pressure) AS max_iop_recorded FROM intraocular_pressures;
```

## Nivel avanzado

### 41.





Calcular la presión intraocular promedio para OD y OI por separado.

```sql
SELECT eye, ROUND(AVG(pressure), 2) AS avg_pressure, MIN(pressure) AS min_pressure, MAX(pressure) AS max_pressure, COUNT(*) AS total_measurements
FROM intraocular_pressures
GROUP BY eye;
```

### 42.





Mostrar la cantidad de consultas realizadas por cada paciente.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(mv.id) AS total_visits
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name
ORDER BY total_visits DESC;
```

### 43.





Mostrar únicamente los pacientes que tengan tres o más consultas.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(mv.id) AS total_visits
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name
HAVING COUNT(mv.id) >= 2
ORDER BY total_visits DESC;
```

### 44.





Mostrar cada profesional junto con la cantidad de consultas realizadas.

```sql
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, s.name AS specialty, COUNT(mv.id) AS total_visits
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN specialties s ON hp.specialty_id = s.id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY hp.id, professional_name, s.name
ORDER BY total_visits DESC;
```

### 45.





Mostrar los profesionales que hayan realizado más de 20 consultas.

```sql
SELECT s.name AS specialty, COUNT(mv.id) AS visits_count
FROM specialties s
JOIN healthcare_professionals hp ON s.id = hp.specialty_id
LEFT JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY s.name
HAVING visits_count > 0;
```

### 46.





Calcular la cantidad de diagnósticos registrados por tipo de diagnóstico.

```sql
SELECT d.id, d.code, d.name AS diagnosis_name, d.is_glaucoma_type, COUNT(vd.id) AS total_occurrences
FROM diagnoses d
LEFT JOIN visit_diagnoses vd ON d.id = vd.diagnosis_id
GROUP BY d.id, d.code, d.name, d.is_glaucoma_type
ORDER BY total_occurrences DESC;
```

### 47.





Mostrar los cinco diagnósticos más frecuentes.

```sql
SELECT d.code, d.name AS diagnosis_name, COUNT(vd.id) AS frequency
FROM diagnoses d
JOIN visit_diagnoses vd ON d.id = vd.diagnosis_id
GROUP BY d.id, d.code, d.name
ORDER BY frequency DESC
LIMIT 5;
```

### 48.





Mostrar la cantidad de estudios OCT realizados por mes.

```sql
SELECT DATE_FORMAT(exam_date, '%Y-%m') AS exam_month, COUNT(*) AS total_oct_exams
FROM oct_exams
GROUP BY exam_month
ORDER BY exam_month;
```

### 49.





Mostrar la cantidad de campos visuales realizados por año.

```sql
SELECT YEAR(exam_date) AS exam_year, COUNT(*) AS total_visual_fields
FROM visual_field_exams
GROUP BY exam_year
ORDER BY exam_year;
```

### 50.





Generar un reporte que muestre por paciente: nombre completo, número de consultas, cantidad de controles de glaucoma, promedio de PIO y fecha de última consulta.

```sql
SELECT 
    p.id AS patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    COUNT(DISTINCT mv.id) AS total_visits,
    COUNT(DISTINCT gc.id) AS total_glaucoma_controls,
    ROUND(AVG(iop.pressure), 2) AS avg_iop,
    MAX(mv.visit_date) AS last_visit_date
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
LEFT JOIN medical_visits mv ON ch.id = mv.clinical_history_id
LEFT JOIN glaucoma_records gr ON p.id = gr.patient_id
LEFT JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
LEFT JOIN intraocular_pressures iop ON mv.id = iop.visit_id
GROUP BY p.id, patient_name
ORDER BY total_visits DESC, p.id;
```

# PARTE II — 50 EJERCICIOS DE SUBCONSULTAS

## Subconsultas escalares

### 1.





Mostrar los pacientes cuya edad sea superior a la edad promedio de todos los pacientes.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) AS age
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) > (
    SELECT AVG(TIMESTAMPDIFF(YEAR, per2.birth_date, CURDATE()))
    FROM patients p2
    JOIN persons per2 ON p2.person_id = per2.id
);
```

### 2.





Mostrar los pacientes cuya edad sea inferior a la edad promedio.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) AS age
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) < (
    SELECT AVG(TIMESTAMPDIFF(YEAR, per2.birth_date, CURDATE()))
    FROM patients p2
    JOIN persons per2 ON p2.person_id = per2.id
);
```

### 3.





Consultar la medición de presión intraocular más alta registrada.

```sql
SELECT *
FROM intraocular_pressures
WHERE pressure = (SELECT MAX(pressure) FROM intraocular_pressures);
```

### 4.





Mostrar todas las mediciones que tengan el mismo valor que la presión máxima registrada.

```sql
SELECT iop.id, iop.visit_id, iop.eye, iop.pressure, iop.method, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
WHERE iop.pressure = (SELECT MAX(pressure) FROM intraocular_pressures);
```

### 5.





Mostrar la presión intraocular mínima registrada.

```sql
SELECT *
FROM intraocular_pressures
WHERE pressure = (SELECT MIN(pressure) FROM intraocular_pressures);
```

### 6.





Mostrar los estudios OCT cuyo RNFL sea inferior al promedio general.

```sql
SELECT *
FROM oct_exams
WHERE rnfl_average < (SELECT AVG(rnfl_average) FROM oct_exams);
```

### 7.





Mostrar los estudios OCT cuyo RNFL sea superior al promedio general.

```sql
SELECT *
FROM oct_exams
WHERE rnfl_average > (SELECT AVG(rnfl_average) FROM oct_exams);
```

### 8.





Consultar pacientes cuya cantidad de consultas sea mayor que el promedio de consultas por paciente.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(mv.id) AS total_visits
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
GROUP BY p.id, patient_name
HAVING COUNT(mv.id) > (
    SELECT AVG(visit_count)
    FROM (
        SELECT COUNT(mv2.id) AS visit_count
        FROM clinical_histories ch2
        LEFT JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
        GROUP BY ch2.patient_id
    ) AS patient_averages
);
```

### 9.





Mostrar profesionales cuya cantidad de consultas sea superior al promedio por profesional.

```sql
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, COUNT(mv.id) AS total_visits
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY hp.id, professional_name
HAVING COUNT(mv.id) > (
    SELECT AVG(prof_visits)
    FROM (
        SELECT COUNT(mv2.id) AS prof_visits
        FROM healthcare_professionals hp2
        LEFT JOIN medical_visits mv2 ON hp2.id = mv2.professional_id
        GROUP BY hp2.id
    ) AS prof_averages
);
```

### 10.





Consultar pacientes cuya última presión intraocular sea superior al promedio general.

```sql
SELECT DISTINCT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, iop.pressure AS latest_iop
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN intraocular_pressures iop ON mv.id = iop.visit_id
WHERE iop.id = (
    SELECT iop2.id
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
    ORDER BY mv2.visit_date DESC, iop2.id DESC
    LIMIT 1
)
AND iop.pressure > (SELECT AVG(pressure) FROM intraocular_pressures);
```

## Subconsultas con IN

### 11.





Mostrar pacientes que tengan al menos una consulta registrada.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
);
```

### 12.





Mostrar pacientes que tengan diagnóstico de glaucoma.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visit_diagnoses vd ON mv.id = vd.visit_id
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    WHERE d.is_glaucoma_type = TRUE
);
```

### 13.





Mostrar pacientes que hayan recibido tratamiento farmacológico.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN treatments t ON mv.id = t.visit_id
);
```

### 14.





Mostrar pacientes que tengan estudios OCT registrados.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN oct_exams oct ON mv.id = oct.visit_id
);
```

### 15.





Mostrar pacientes que tengan campos visuales registrados.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visual_field_exams vf ON mv.id = vf.visit_id
);
```

### 16.





Mostrar medicamentos que hayan sido utilizados en al menos un tratamiento.

```sql
SELECT id, name, generic_name, concentration
FROM medications
WHERE id IN (
    SELECT DISTINCT medication_id FROM treatments
);
```

### 17.





Mostrar profesionales que hayan atendido pacientes con glaucoma.

```sql
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, hp.medical_license
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
WHERE hp.id IN (
    SELECT mv.professional_id
    FROM medical_visits mv
    JOIN visit_diagnoses vd ON mv.id = vd.visit_id
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    WHERE d.is_glaucoma_type = TRUE
);
```

### 18.





Mostrar diagnósticos utilizados en alguna consulta.

```sql
SELECT id, code, name
FROM diagnoses
WHERE id IN (
    SELECT DISTINCT diagnosis_id FROM visit_diagnoses
);
```

### 19.





Mostrar pacientes que hayan tenido algún procedimiento quirúrgico.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN procedures pr ON mv.id = pr.visit_id
);
```

### 20.





Mostrar pacientes que tengan registros de paquimetría.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE p.id IN (
    SELECT ch.patient_id
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN pachymetry_exams pe ON mv.id = pe.visit_id
);
```

## Subconsultas con NOT IN / NOT EXISTS

### 21.





Mostrar pacientes que nunca hayan tenido una consulta.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    WHERE ch.patient_id = p.id
);
```

### 22.





Mostrar pacientes que nunca hayan tenido un control de glaucoma.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM glaucoma_records gr
    JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
    WHERE gr.patient_id = p.id
);
```

### 23.





Mostrar pacientes que no tengan estudios OCT.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN oct_exams oct ON mv.id = oct.visit_id
    WHERE ch.patient_id = p.id
);
```

### 24.





Mostrar pacientes que no tengan campos visuales.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visual_field_exams vf ON mv.id = vf.visit_id
    WHERE ch.patient_id = p.id
);
```

### 25.





Mostrar medicamentos que nunca hayan sido utilizados.

```sql
SELECT m.id, m.name, m.generic_name
FROM medications m
WHERE m.id NOT IN (
    SELECT DISTINCT medication_id FROM treatments WHERE medication_id IS NOT NULL
);
```

### 26.





Mostrar profesionales que todavía no hayan registrado consultas.

```sql
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1 FROM medical_visits mv WHERE mv.professional_id = hp.id
);
```

### 27.





Mostrar diagnósticos que nunca hayan sido asociados a una consulta.

```sql
SELECT d.id, d.code, d.name
FROM diagnoses d
WHERE d.id NOT IN (
    SELECT DISTINCT diagnosis_id FROM visit_diagnoses WHERE diagnosis_id IS NOT NULL
);
```

### 28.





Mostrar pacientes que no tengan tratamientos activos.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN treatments t ON mv.id = t.visit_id
    WHERE ch.patient_id = p.id AND t.is_active = TRUE
);
```

### 29.





Mostrar pacientes que nunca hayan tenido procedimientos.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN procedures pr ON mv.id = pr.visit_id
    WHERE ch.patient_id = p.id
);
```

### 30.





Mostrar pacientes sin mediciones de presión intraocular.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN intraocular_pressures iop ON mv.id = iop.visit_id
    WHERE ch.patient_id = p.id
);
```

## Subconsultas correlacionadas

### 31.





Mostrar las mediciones de PIO superiores al promedio del mismo paciente.

```sql
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       iop.eye, iop.pressure, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE iop.pressure > (
    SELECT AVG(iop2.pressure)
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);
```

### 32.





Mostrar los estudios OCT cuyo RNFL sea inferior al promedio del mismo paciente.

```sql
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       oct.eye, oct.rnfl_average, oct.exam_date
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE oct.rnfl_average < (
    SELECT AVG(oct2.rnfl_average)
    FROM oct_exams oct2
    JOIN medical_visits mv2 ON oct2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);
```

### 33.





Mostrar las consultas posteriores a la primera consulta de cada paciente.

```sql
SELECT mv.id AS visit_id, p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date > (
    SELECT MIN(mv2.visit_date)
    FROM medical_visits mv2
    WHERE mv2.clinical_history_id = ch.id
);
```

### 34.





Mostrar la última consulta de cada paciente utilizando una subconsulta correlacionada.

```sql
SELECT mv.id AS visit_id, p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, mv.visit_date, mv.reason
FROM medical_visits mv
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date = (
    SELECT MAX(mv2.visit_date)
    FROM medical_visits mv2
    WHERE mv2.clinical_history_id = ch.id
);
```

### 35.





Mostrar la primera medición de PIO de cada paciente.

```sql
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       iop.eye, iop.pressure, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date = (
    SELECT MIN(mv2.visit_date)
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);
```

### 36.





Mostrar la última medición de presión intraocular de cada paciente y ojo.

```sql
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       iop.eye, iop.pressure, mv.visit_date
FROM intraocular_pressures iop
JOIN medical_visits mv ON iop.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE mv.visit_date = (
    SELECT MAX(mv2.visit_date)
    FROM intraocular_pressures iop2
    JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id AND iop2.eye = iop.eye
);
```

### 37.





Mostrar los tratamientos cuya fecha de inicio sea posterior a la primera consulta del paciente.

```sql
SELECT t.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, t.dosage, t.start_date
FROM treatments t
JOIN medical_visits mv ON t.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE t.start_date > (
    SELECT MIN(DATE(mv2.visit_date))
    FROM medical_visits mv2
    WHERE mv2.clinical_history_id = ch.id
);
```

### 38.





Mostrar pacientes cuyo número de consultas sea mayor que el de todos los demás pacientes de su misma ciudad.

```sql
SELECT p1.id, CONCAT(per1.first_name, ' ', per1.last_name) AS patient_name, per1.city_id, COUNT(mv1.id) AS visit_count
FROM patients p1
JOIN persons per1 ON p1.person_id = per1.id
JOIN clinical_histories ch1 ON p1.id = ch1.patient_id
JOIN medical_visits mv1 ON ch1.id = mv1.clinical_history_id
GROUP BY p1.id, patient_name, per1.city_id
HAVING visit_count >= ALL (
    SELECT COUNT(mv2.id)
    FROM patients p2
    JOIN persons per2 ON p2.person_id = per2.id
    JOIN clinical_histories ch2 ON p2.id = ch2.patient_id
    JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
    WHERE per2.city_id = per1.city_id AND p2.id <> p1.id
    GROUP BY p2.id
);
```

### 39.





Mostrar profesionales cuya cantidad de consultas sea superior al promedio de los profesionales de su especialidad.

```sql
SELECT hp.id, CONCAT(per.first_name, ' ', per.last_name) AS professional_name, hp.specialty_id, COUNT(mv.id) AS visits_count
FROM healthcare_professionals hp
JOIN persons per ON hp.person_id = per.id
JOIN medical_visits mv ON hp.id = mv.professional_id
GROUP BY hp.id, professional_name, hp.specialty_id
HAVING visits_count >= (
    SELECT AVG(specialty_visits)
    FROM (
        SELECT COUNT(mv2.id) AS specialty_visits
        FROM healthcare_professionals hp2
        LEFT JOIN medical_visits mv2 ON hp2.id = mv2.professional_id
        WHERE hp2.specialty_id = hp.specialty_id
        GROUP BY hp2.id
    ) AS spec_sub
);
```

### 40.





Mostrar el estudio OCT más reciente de cada paciente.

```sql
SELECT p.id AS patient_id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
       oct.eye, oct.rnfl_average, oct.exam_date
FROM oct_exams oct
JOIN medical_visits mv ON oct.visit_id = mv.id
JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
JOIN patients p ON ch.patient_id = p.id
JOIN persons per ON p.person_id = per.id
WHERE oct.exam_date = (
    SELECT MAX(oct2.exam_date)
    FROM oct_exams oct2
    JOIN medical_visits mv2 ON oct2.visit_id = mv2.id
    JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
    WHERE ch2.patient_id = p.id
);
```

## Subconsultas avanzadas

### 41.





Mostrar pacientes cuya presión intraocular máxima sea mayor que la presión máxima promedio de todos los pacientes.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, MAX(iop.pressure) AS patient_max_iop
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN intraocular_pressures iop ON mv.id = iop.visit_id
GROUP BY p.id, patient_name
HAVING patient_max_iop > (
    SELECT AVG(max_p)
    FROM (
        SELECT MAX(iop2.pressure) AS max_p
        FROM intraocular_pressures iop2
        JOIN medical_visits mv2 ON iop2.visit_id = mv2.id
        JOIN clinical_histories ch2 ON mv2.clinical_history_id = ch2.id
        GROUP BY ch2.patient_id
    ) AS patient_max_averages
);
```

### 42.





Mostrar pacientes cuya cantidad de diagnósticos diferentes sea superior al promedio.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(DISTINCT vd.diagnosis_id) AS distinct_diag_count
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
GROUP BY p.id, patient_name
HAVING distinct_diag_count > (
    SELECT AVG(diag_count)
    FROM (
        SELECT COUNT(DISTINCT vd2.diagnosis_id) AS diag_count
        FROM clinical_histories ch2
        JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
        JOIN visit_diagnoses vd2 ON mv2.id = vd2.visit_id
        GROUP BY ch2.patient_id
    ) AS diag_averages
);
```

### 43.





Mostrar los pacientes que tengan más tratamientos activos que el promedio de tratamientos activos por paciente.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(t.id) AS active_treatments
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN clinical_histories ch ON p.id = ch.patient_id
JOIN medical_visits mv ON ch.id = mv.clinical_history_id
JOIN treatments t ON mv.id = t.visit_id
WHERE t.is_active = TRUE
GROUP BY p.id, patient_name
HAVING active_treatments > (
    SELECT AVG(active_count)
    FROM (
        SELECT COUNT(t2.id) AS active_count
        FROM clinical_histories ch2
        LEFT JOIN medical_visits mv2 ON ch2.id = mv2.clinical_history_id
        LEFT JOIN treatments t2 ON mv2.id = t2.visit_id AND t2.is_active = TRUE
        GROUP BY ch2.patient_id
    ) AS active_averages
);
```

### 44.





Mostrar el medicamento más utilizado en tratamientos.

```sql
SELECT m.id, m.name, m.generic_name, COUNT(t.id) AS usage_count
FROM medications m
JOIN treatments t ON m.id = t.medication_id
GROUP BY m.id, m.name, m.generic_name
HAVING usage_count = (
    SELECT MAX(med_count)
    FROM (
        SELECT COUNT(t2.id) AS med_count
        FROM treatments t2
        GROUP BY t2.medication_id
    ) AS med_counts
);
```

### 45.





Mostrar el diagnóstico más frecuente utilizando subconsultas.

```sql
SELECT d.id, d.code, d.name, COUNT(vd.id) AS occurrences
FROM diagnoses d
JOIN visit_diagnoses vd ON d.id = vd.diagnosis_id
GROUP BY d.id, d.code, d.name
HAVING occurrences = (
    SELECT MAX(diag_occ)
    FROM (
        SELECT COUNT(vd2.id) AS diag_occ
        FROM visit_diagnoses vd2
        GROUP BY vd2.diagnosis_id
    ) AS diag_counts
);
```

### 46.





Mostrar los pacientes cuya última PIO sea inferior a su primera PIO.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE (
    SELECT iop_first.pressure
    FROM intraocular_pressures iop_first
    JOIN medical_visits mv_first ON iop_first.visit_id = mv_first.id
    JOIN clinical_histories ch_first ON mv_first.clinical_history_id = ch_first.id
    WHERE ch_first.patient_id = p.id
    ORDER BY mv_first.visit_date ASC, iop_first.id ASC
    LIMIT 1
) > (
    SELECT iop_last.pressure
    FROM intraocular_pressures iop_last
    JOIN medical_visits mv_last ON iop_last.visit_id = mv_last.id
    JOIN clinical_histories ch_last ON mv_last.clinical_history_id = ch_last.id
    WHERE ch_last.patient_id = p.id
    ORDER BY mv_last.visit_date DESC, iop_last.id DESC
    LIMIT 1
);
```

### 47.





Mostrar pacientes cuya presión promedio del ojo derecho sea mayor que la del ojo izquierdo.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE (
    SELECT AVG(iop_od.pressure)
    FROM intraocular_pressures iop_od
    JOIN medical_visits mv_od ON iop_od.visit_id = mv_od.id
    JOIN clinical_histories ch_od ON mv_od.clinical_history_id = ch_od.id
    WHERE ch_od.patient_id = p.id AND iop_od.eye = 'OD'
) > (
    SELECT AVG(iop_oi.pressure)
    FROM intraocular_pressures iop_oi
    JOIN medical_visits mv_oi ON iop_oi.visit_id = mv_oi.id
    JOIN clinical_histories ch_oi ON mv_oi.clinical_history_id = ch_oi.id
    WHERE ch_oi.patient_id = p.id AND iop_oi.eye = 'OI'
);
```

### 48.





Mostrar los pacientes con mayor cantidad de controles de glaucoma que el promedio general.

```sql
SELECT p.id, CONCAT(per.first_name, ' ', per.last_name) AS patient_name, COUNT(gc.id) AS controls_count
FROM patients p
JOIN persons per ON p.person_id = per.id
JOIN glaucoma_records gr ON p.id = gr.patient_id
JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
GROUP BY p.id, patient_name
HAVING controls_count > (
    SELECT AVG(patient_ctrls)
    FROM (
        SELECT COUNT(gc2.id) AS patient_ctrls
        FROM glaucoma_records gr2
        LEFT JOIN glaucoma_controls gc2 ON gr2.id = gc2.glaucoma_record_id
        GROUP BY gr2.patient_id
    ) AS ctrl_averages
);
```

### 49.





Mostrar las consultas que tengan más diagnósticos asociados que el promedio de diagnósticos por consulta.

```sql
SELECT mv.id AS visit_id, mv.visit_date, COUNT(vd.id) AS diag_count
FROM medical_visits mv
JOIN visit_diagnoses vd ON mv.id = vd.visit_id
GROUP BY mv.id, mv.visit_date
HAVING diag_count > (
    SELECT AVG(visit_diag_count)
    FROM (
        SELECT COUNT(vd2.id) AS visit_diag_count
        FROM medical_visits mv2
        LEFT JOIN visit_diagnoses vd2 ON mv2.id = vd2.visit_id
        GROUP BY mv2.id
    ) AS avg_diag_per_visit
);
```

### 50.





Mostrar los pacientes que tengan simultáneamente OCT, campo visual, paquimetría y control de glaucoma registrados.

```sql
SELECT p.id, per.document_number, CONCAT(per.first_name, ' ', per.last_name) AS patient_name
FROM patients p
JOIN persons per ON p.person_id = per.id
WHERE EXISTS (
    SELECT 1 FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN oct_exams oct ON mv.id = oct.visit_id
    WHERE ch.patient_id = p.id
)
AND EXISTS (
    SELECT 1 FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN visual_field_exams vf ON mv.id = vf.visit_id
    WHERE ch.patient_id = p.id
)
AND EXISTS (
    SELECT 1 FROM clinical_histories ch
    JOIN medical_visits mv ON ch.id = mv.clinical_history_id
    JOIN pachymetry_exams pe ON mv.id = pe.visit_id
    WHERE ch.patient_id = p.id
)
AND EXISTS (
    SELECT 1 FROM glaucoma_records gr
    JOIN glaucoma_controls gc ON gr.id = gc.glaucoma_record_id
    WHERE gr.patient_id = p.id
);
```

# PARTE III — 50 EJERCICIOS DE PROCEDIMIENTOS ALMACENADOS

## Procedimientos básicos

### 1.





Crear un procedimiento que liste todos los pacientes.

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_list_all_patients $$
CREATE PROCEDURE sp_list_all_patients()
BEGIN
    SELECT p.id, per.document_number, per.first_name, per.last_name, per.birth_date, per.gender, per.phone, per.email
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    ORDER BY per.last_name, per.first_name;
END $$
DELIMITER ;
```

### 2.





Crear un procedimiento que reciba el ID de un paciente y muestre sus datos.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 3.





Crear un procedimiento que busque un paciente por número de documento.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 4.





Crear un procedimiento que liste todas las consultas de un paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 5.





Crear un procedimiento que muestre todos los profesionales.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 6.





Crear un procedimiento que reciba una especialidad y muestre sus profesionales.

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_list_professionals_by_specialty $$
CREATE PROCEDURE sp_list_professionals_by_specialty(IN p_specialty_name VARCHAR(100))
BEGIN
    SELECT hp.id, per.first_name, per.last_name, hp.medical_license, per.email, per.phone
    FROM healthcare_professionals hp
    JOIN persons per ON hp.person_id = per.id
    JOIN specialties s ON hp.specialty_id = s.id
    WHERE s.name LIKE CONCAT('%', p_specialty_name, '%');
END $$
DELIMITER ;
```

### 7.





Crear un procedimiento que liste diagnósticos.

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_list_diagnoses $$
CREATE PROCEDURE sp_list_diagnoses()
BEGIN
    SELECT id, code, name, is_glaucoma_type, description
    FROM diagnoses
    ORDER BY code;
END $$
DELIMITER ;
```

### 8.





Crear un procedimiento que muestre medicamentos activos.

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_list_active_medications $$
CREATE PROCEDURE sp_list_active_medications()
BEGIN
    SELECT m.id, m.name, mc.name AS class_name, m.generic_name, m.concentration, m.presentation
    FROM medications m
    JOIN medication_classes mc ON m.medication_class_id = mc.id
    WHERE m.is_active = TRUE
    ORDER BY mc.name, m.name;
END $$
DELIMITER ;
```

### 9.





Crear un procedimiento que liste procedimientos clínicos realizados a un paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 10.





Crear un procedimiento para consultar todos los controles de glaucoma de un paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

## Procedimientos de inserción

### 11.





Crear un procedimiento para registrar un nuevo paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 12.





Crear un procedimiento para crear una historia clínica.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 13.





Crear un procedimiento para registrar una consulta médica.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 14.





Crear un procedimiento para registrar un diagnóstico asociado a una consulta.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 15.





Crear un procedimiento para registrar una medición de PIO.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 16.





Crear un procedimiento para registrar un control de glaucoma.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 17.





Crear un procedimiento para registrar un examen OCT.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 18.





Crear un procedimiento para registrar un campo visual.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 19.





Crear un procedimiento para registrar una paquimetría.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 20.





Crear un procedimiento para registrar un tratamiento.

```sql
DELIMITER $$
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
DELIMITER ;
```

## Procedimientos de modificación

### 21.





Crear un procedimiento para actualizar teléfono y correo de un paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 22.





Crear un procedimiento para modificar el estado de una historia clínica.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 23.





Crear un procedimiento para actualizar observaciones de una consulta.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 24.





Crear un procedimiento para modificar la presión objetivo de un paciente con glaucoma.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 25.





Crear un procedimiento para finalizar un tratamiento.

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_finalize_treatment $$
CREATE PROCEDURE sp_finalize_treatment(IN p_treatment_id BIGINT)
BEGIN
    UPDATE treatments
    SET is_active = FALSE, end_date = CURDATE()
    WHERE id = p_treatment_id;
END $$
DELIMITER ;
```

### 26.





Crear un procedimiento para cambiar el medicamento de un tratamiento.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 27.





Crear un procedimiento para actualizar el estado clínico del glaucoma.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 28.





Crear un procedimiento para actualizar información de un profesional.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 29.





Crear un procedimiento para modificar la interpretación de un OCT.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 30.





Crear un procedimiento para actualizar la interpretación de un campo visual.

```sql
DELIMITER $$
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
DELIMITER ;
```

## Procedimientos con validaciones

### 31.





Crear un procedimiento que registre una PIO únicamente si el paciente existe.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 32.





Crear un procedimiento que registre una consulta solo si existe la historia clínica.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 33.





Crear un procedimiento que impida registrar un tratamiento con fecha final anterior a la inicial.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 34.





Crear un procedimiento que impida registrar valores negativos de PIO.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 35.





Crear un procedimiento que valide que el ojo recibido sea `OD` u `OI`.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 36.





Crear un procedimiento que impida crear dos historias clínicas para el mismo paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 37.





Crear un procedimiento que registre un diagnóstico solo si existe en el catálogo.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 38.





Crear un procedimiento que valide que el profesional se encuentre activo antes de registrar una consulta.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 39.





Crear un procedimiento que registre un campo visual validando que VFI esté entre 0 y 100.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 40.





Crear un procedimiento que registre una paquimetría validando que el valor sea positivo.

```sql
DELIMITER $$
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
DELIMITER ;
```

## Procedimientos avanzados

### 41.





Crear un procedimiento que devuelva un resumen completo de la historia clínica de un paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 42.





Crear un procedimiento que muestre la evolución de PIO de un paciente entre dos fechas.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 43.





Crear un procedimiento que reciba paciente y ojo y muestre todas sus mediciones cronológicamente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 44.





Crear un procedimiento que genere estadísticas mensuales de consultas.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 45.





Crear un procedimiento que calcule la cantidad de pacientes atendidos por cada especialista.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 46.





Crear un procedimiento que determine pacientes sin consulta durante un número de meses recibido como parámetro.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 47.





Crear un procedimiento que genere un resumen de diagnósticos por paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 48.





Crear un procedimiento que devuelva el último OCT, último campo visual y última PIO de un paciente.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 49.





Crear un procedimiento que registre en una sola transacción una consulta, un diagnóstico y una medición de PIO.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 50.





Crear un procedimiento transaccional que registre un control completo de glaucoma y ejecute `ROLLBACK` si alguna operación falla.

```sql
DELIMITER $$
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
DELIMITER ;
```

# PARTE IV — 50 EJERCICIOS DE TRIGGERS

## BEFORE INSERT

### 1.





Crear un trigger que elimine espacios externos de los nombres de pacientes antes de insertarlos.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bi_persons_trim_names $$
CREATE TRIGGER trg_bi_persons_trim_names
BEFORE INSERT ON persons
FOR EACH ROW
BEGIN
    SET NEW.first_name = TRIM(NEW.first_name);
    SET NEW.last_name = TRIM(NEW.last_name);
END $$
DELIMITER ;
```

### 2.





Convertir automáticamente el correo del paciente a minúsculas.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bi_persons_lower_email $$
CREATE TRIGGER trg_bi_persons_lower_email
BEFORE INSERT ON persons
FOR EACH ROW
BEGIN
    IF NEW.email IS NOT NULL THEN
        SET NEW.email = LOWER(TRIM(NEW.email));
    END IF;
END $$
DELIMITER ;
```

### 3.





Convertir el número de documento a mayúsculas cuando contenga caracteres.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bi_persons_upper_document $$
CREATE TRIGGER trg_bi_persons_upper_document
BEFORE INSERT ON persons
FOR EACH ROW
BEGIN
    SET NEW.document_number = UPPER(TRIM(NEW.document_number));
END $$
DELIMITER ;
```

### 4.





Impedir registrar una fecha de nacimiento futura.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bi_persons_check_birth_date $$
CREATE TRIGGER trg_bi_persons_check_birth_date
BEFORE INSERT ON persons
FOR EACH ROW
BEGIN
    IF NEW.birth_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error cronológico: La fecha de nacimiento no puede ser posterior a la fecha actual.';
    END IF;
END $$
DELIMITER ;
```

### 5.





Impedir registrar una presión intraocular negativa.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 6.





Impedir registrar una PIO superior a un límite definido para datos plausibles.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 7.





Validar que el campo `eye` solo admita `OD` u `OI`.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 8.





Impedir que un tratamiento tenga fecha final anterior a la inicial.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 9.





Validar que el VFI de un campo visual esté entre 0 y 100.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 10.





Validar que la paquimetría sea mayor que cero.

```sql
DELIMITER $$
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
DELIMITER ;
```

## AFTER INSERT

### 11.





Registrar en auditoría la creación de un nuevo paciente.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_patient $$
CREATE TRIGGER trg_ai_audit_patient
AFTER INSERT ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('patients', NEW.id, 'INSERT', JSON_OBJECT('person_id', NEW.person_id, 'insurance', NEW.health_insurance, 'affiliation', NEW.affiliation_type), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 12.





Registrar en auditoría la creación de una historia clínica.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_clinical_history $$
CREATE TRIGGER trg_ai_audit_clinical_history
AFTER INSERT ON clinical_histories
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('clinical_histories', NEW.id, 'INSERT', JSON_OBJECT('history_number', NEW.history_number, 'patient_id', NEW.patient_id), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 13.





Registrar automáticamente en auditoría cada nueva consulta.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_medical_visit $$
CREATE TRIGGER trg_ai_audit_medical_visit
AFTER INSERT ON medical_visits
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('medical_visits', NEW.id, 'INSERT', JSON_OBJECT('history_id', NEW.clinical_history_id, 'professional_id', NEW.professional_id, 'date', NEW.visit_date), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 14.





Registrar cada nuevo diagnóstico asociado a una consulta.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_visit_diagnosis $$
CREATE TRIGGER trg_ai_audit_visit_diagnosis
AFTER INSERT ON visit_diagnoses
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('visit_diagnoses', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'diagnosis_id', NEW.diagnosis_id, 'primary', NEW.is_primary), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 15.





Registrar cada nueva medición de presión intraocular.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_iop $$
CREATE TRIGGER trg_ai_audit_iop
AFTER INSERT ON intraocular_pressures
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('intraocular_pressures', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'eye', NEW.eye, 'pressure', NEW.pressure), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 16.





Registrar cada nuevo tratamiento.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_treatment $$
CREATE TRIGGER trg_ai_audit_treatment
AFTER INSERT ON treatments
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('treatments', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'medication_id', NEW.medication_id, 'eye', NEW.eye), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 17.





Registrar cada nuevo procedimiento.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_procedure $$
CREATE TRIGGER trg_ai_audit_procedure
AFTER INSERT ON procedures
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('procedures', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'procedure_type_id', NEW.procedure_type_id, 'eye', NEW.eye), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 18.





Registrar en auditoría cada nuevo estudio OCT.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_oct $$
CREATE TRIGGER trg_ai_audit_oct
AFTER INSERT ON oct_exams
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('oct_exams', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'eye', NEW.eye, 'rnfl_average', NEW.rnfl_average), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 19.





Registrar cada campo visual creado.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ai_audit_visual_field $$
CREATE TRIGGER trg_ai_audit_visual_field
AFTER INSERT ON visual_field_exams
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, new_values, performed_by, changed_at)
    VALUES ('visual_field_exams', NEW.id, 'INSERT', JSON_OBJECT('visit_id', NEW.visit_id, 'eye', NEW.eye, 'vfi', NEW.visual_field_index_vfi, 'md', NEW.mean_deviation_md), 'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 20.





Crear una notificación interna cuando se registre una PIO mayor que un valor determinado.

```sql
DELIMITER $$
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
DELIMITER ;
```

## BEFORE UPDATE

### 21.





Actualizar automáticamente `updated_at` antes de modificar un paciente.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bu_persons_updated_at $$
CREATE TRIGGER trg_bu_persons_updated_at
BEFORE UPDATE ON persons
FOR EACH ROW
BEGIN
    SET NEW.first_name = TRIM(NEW.first_name);
    SET NEW.last_name = TRIM(NEW.last_name);
    IF NEW.email IS NOT NULL THEN
        SET NEW.email = LOWER(TRIM(NEW.email));
    END IF;
    SET NEW.updated_at = NOW();
END $$
DELIMITER ;
```

### 22.





Actualizar `updated_at` antes de modificar una consulta.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bu_visits_updated_at $$
CREATE TRIGGER trg_bu_visits_updated_at
BEFORE UPDATE ON medical_visits
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END $$
DELIMITER ;
```

### 23.





Impedir modificar el número de documento una vez creada la historia clínica.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bu_persons_freeze_doc $$
CREATE TRIGGER trg_bu_persons_freeze_doc
BEFORE UPDATE ON persons
FOR EACH ROW
BEGIN
    IF NEW.document_number <> OLD.document_number THEN
        IF EXISTS (SELECT 1 FROM patients p JOIN clinical_histories ch ON p.id = ch.patient_id WHERE p.person_id = OLD.id) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Integridad clínica: No se permite modificar el número de documento una vez expedida la historia clínica.';
        END IF;
    END IF;
END $$
DELIMITER ;
```

### 24.





Impedir asignar una fecha de consulta futura no permitida.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 25.





Validar que una nueva presión objetivo sea positiva.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 26.





Impedir establecer una fecha final de tratamiento anterior a su inicio.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 27.





Evitar modificar un examen OCT que haya sido marcado como validado.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 28.





Evitar modificar una consulta marcada como cerrada.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 29.





Validar valores del campo visual antes de una actualización.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 30.





Normalizar observaciones eliminando espacios innecesarios antes de actualizar.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bu_visits_normalize_notes $$
CREATE TRIGGER trg_bu_visits_normalize_notes
BEFORE UPDATE ON medical_visits
FOR EACH ROW
BEGIN
    SET NEW.reason = TRIM(NEW.reason);
    SET NEW.assessment = TRIM(NEW.assessment);
    SET NEW.plan = TRIM(NEW.plan);
END $$
DELIMITER ;
```

## AFTER UPDATE

### 31.





Registrar cambios de datos personales del paciente.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_au_audit_person_update $$
CREATE TRIGGER trg_au_audit_person_update
AFTER UPDATE ON persons
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
    VALUES ('persons', NEW.id, 'UPDATE',
            JSON_OBJECT('phone', OLD.phone, 'address', OLD.address),
            JSON_OBJECT('phone', NEW.phone, 'address', NEW.address),
            'SYSTEM', NOW());
END $$
DELIMITER ;
```

### 32.





Guardar valor anterior y nuevo del correo del paciente.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_au_audit_person_email $$
CREATE TRIGGER trg_au_audit_person_email
AFTER UPDATE ON persons
FOR EACH ROW
BEGIN
    IF OLD.email <=> NEW.email THEN
        -- No cambió el correo
        BEGIN END;
    ELSE
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, performed_by, changed_at)
        VALUES ('persons', NEW.id, 'UPDATE',
                JSON_OBJECT('email', OLD.email),
                JSON_OBJECT('email', NEW.email),
                'SECURITY_AUDIT', NOW());
    END IF;
END $$
DELIMITER ;
```

### 33.





Registrar cambios en la presión objetivo.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 34.





Auditar cambios en el estado del glaucoma.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 35.





Registrar cambios en tratamientos.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 36.





Registrar cambios en diagnósticos.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 37.





Registrar cambios de interpretación de OCT.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 38.





Registrar modificaciones de campos visuales.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 39.





Generar una alerta cuando una PIO sea actualizada a un valor superior al objetivo.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 40.





Registrar cuándo un tratamiento cambia de activo a finalizado.

```sql
DELIMITER $$
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
DELIMITER ;
```

## DELETE y auditoría

### 41.





Guardar una copia de un paciente antes de eliminarlo.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bd_patients_backup $$
CREATE TRIGGER trg_bd_patients_backup
BEFORE DELETE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO patients_backup (id, person_id, blood_type, health_insurance, affiliation_type, occupation, emergency_contact_name, emergency_contact_phone, created_at, updated_at)
    VALUES (OLD.id, OLD.person_id, OLD.blood_type, OLD.health_insurance, OLD.affiliation_type, OLD.occupation, OLD.emergency_contact_name, OLD.emergency_contact_phone, OLD.created_at, OLD.updated_at);
END $$
DELIMITER ;
```

### 42.





Guardar una copia de una consulta eliminada.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bd_visits_backup $$
CREATE TRIGGER trg_bd_visits_backup
BEFORE DELETE ON medical_visits
FOR EACH ROW
BEGIN
    INSERT INTO medical_visits_backup (id, clinical_history_id, professional_id, visit_date, reason, symptoms, assessment, plan, is_closed, created_at, updated_at)
    VALUES (OLD.id, OLD.clinical_history_id, OLD.professional_id, OLD.visit_date, OLD.reason, OLD.symptoms, OLD.assessment, OLD.plan, OLD.is_closed, OLD.created_at, OLD.updated_at);
END $$
DELIMITER ;
```

### 43.





Guardar un histórico de un tratamiento eliminado.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bd_treatments_backup $$
CREATE TRIGGER trg_bd_treatments_backup
BEFORE DELETE ON treatments
FOR EACH ROW
BEGIN
    INSERT INTO treatments_backup (id, visit_id, medication_id, eye, dosage, frequency, start_date, end_date, is_active, notes)
    VALUES (OLD.id, OLD.visit_id, OLD.medication_id, OLD.eye, OLD.dosage, OLD.frequency, OLD.start_date, OLD.end_date, OLD.is_active, OLD.notes);
END $$
DELIMITER ;
```

### 44.





Registrar en auditoría la eliminación de un diagnóstico.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_ad_audit_diagnosis_delete $$
CREATE TRIGGER trg_ad_audit_diagnosis_delete
AFTER DELETE ON diagnoses
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, action, old_values, performed_by, changed_at)
    VALUES ('diagnoses', OLD.id, 'DELETE', JSON_OBJECT('code', OLD.code, 'name', OLD.name), 'ADMIN', NOW());
END $$
DELIMITER ;
```

### 45.





Impedir eliminar pacientes que tengan historia clínica.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 46.





Impedir eliminar profesionales con consultas registradas.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 47.





Impedir eliminar medicamentos actualmente utilizados en tratamientos activos.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 48.





Registrar automáticamente la eliminación de un examen OCT.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 49.





Registrar quién eliminó un documento clínico.

```sql
DELIMITER $$
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
DELIMITER ;
```

### 50.





Implementar un esquema completo de auditoría mediante triggers para `INSERT`, `UPDATE` y `DELETE` sobre la tabla `patients`.

```sql
DELIMITER $$
DROP TRIGGER IF EXISTS trg_bd_persons_backup $$
CREATE TRIGGER trg_bd_persons_backup
BEFORE DELETE ON persons
FOR EACH ROW
BEGIN
    INSERT INTO persons_backup (id, document_type_id, document_number, first_name, last_name, birth_date, gender, city_id, address, phone, email, created_at, updated_at)
    VALUES (OLD.id, OLD.document_type_id, OLD.document_number, OLD.first_name, OLD.last_name, OLD.birth_date, OLD.gender, OLD.city_id, OLD.address, OLD.phone, OLD.email, OLD.created_at, OLD.updated_at);
END $$

DELIMITER ;
DELIMITER ;
```

# PARTE V — 50 EJERCICIOS DE FUNCIONES ALMACENADAS

## Funciones básicas

### 1.





Crear una función que calcule la edad de un paciente a partir de su fecha de nacimiento.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_calculate_age $$
CREATE FUNCTION fn_calculate_age(p_birth_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_birth_date, CURDATE());
END $$
DELIMITER ;
```

### 2.





Crear una función que reciba nombres y apellidos y retorne el nombre completo.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_full_name $$
CREATE FUNCTION fn_full_name(p_first VARCHAR(100), p_last VARCHAR(100))
RETURNS VARCHAR(210)
DETERMINISTIC
BEGIN
    RETURN CONCAT(TRIM(p_first), ' ', TRIM(p_last));
END $$
DELIMITER ;
```

### 3.





Crear una función que reciba un ID de paciente y retorne su número de documento.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_get_patient_document $$
CREATE FUNCTION fn_get_patient_document(p_patient_id BIGINT)
RETURNS VARCHAR(30)
READS SQL DATA
BEGIN
    DECLARE v_doc VARCHAR(30);
    SELECT per.document_number INTO v_doc
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    WHERE p.id = p_patient_id;
    RETURN IFNULL(v_doc, 'NO ENCONTRADO');
END $$
DELIMITER ;
```

### 4.





Crear una función que reciba un ID de paciente y retorne su edad.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_get_patient_age $$
CREATE FUNCTION fn_get_patient_age(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_age INT;
    SELECT TIMESTAMPDIFF(YEAR, per.birth_date, CURDATE()) INTO v_age
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    WHERE p.id = p_patient_id;
    RETURN IFNULL(v_age, 0);
END $$
DELIMITER ;
```

### 5.





Crear una función que reciba el ID de una consulta y retorne su fecha.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_get_visit_date $$
CREATE FUNCTION fn_get_visit_date(p_visit_id BIGINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
    DECLARE v_date DATETIME;
    SELECT visit_date INTO v_date FROM medical_visits WHERE id = p_visit_id;
    RETURN v_date;
END $$
DELIMITER ;
```

### 6.





Crear una función que determine cuántos años han pasado desde una fecha.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_years_since $$
CREATE FUNCTION fn_years_since(p_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_date IS NULL THEN
        RETURN 0;
    END IF;
    RETURN TIMESTAMPDIFF(YEAR, p_date, CURDATE());
END $$
DELIMITER ;
```

### 7.





Crear una función que reciba un valor de PIO y retorne un texto descriptivo.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_iop_status_text $$
CREATE FUNCTION fn_iop_status_text(p_pressure DECIMAL(5,2))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    IF p_pressure <= 10.00 THEN
        RETURN 'HIPOTONÍA OCULAR';
    ELSEIF p_pressure <= 21.00 THEN
        RETURN 'DENTRO DE LÍMITES NORMALES';
    ELSEIF p_pressure <= 29.00 THEN
        RETURN 'HIPERTENSIÓN OCULAR MODERADA';
    ELSE
        RETURN 'HIPERTENSIÓN OCULAR SEVERA / CRÍTICA';
    END IF;
END $$
DELIMITER ;
```

### 8.





Crear una función que reciba `OD` u `OI` y devuelva `Ojo derecho` u `Ojo izquierdo`.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_eye_label $$
CREATE FUNCTION fn_eye_label(p_eye VARCHAR(10))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_eye = 'OD' THEN
        RETURN 'Ojo Derecho';
    ELSEIF p_eye = 'OI' THEN
        RETURN 'Ojo Izquierdo';
    ELSEIF p_eye = 'AMBOS' THEN
        RETURN 'Ambos Ojos';
    ELSE
        RETURN 'No Especificado';
    END IF;
END $$
DELIMITER ;
```

### 9.





Crear una función que reciba un booleano y retorne `Activo` o `Inactivo`.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_status_label $$
CREATE FUNCTION fn_status_label(p_status BOOLEAN)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_status = TRUE THEN
        RETURN 'Activo';
    ELSE
        RETURN 'Inactivo';
    END IF;
END $$
DELIMITER ;
```

### 10.





Crear una función que formatee un número de historia clínica.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_format_history_number $$
CREATE FUNCTION fn_format_history_number(p_raw VARCHAR(50))
RETURNS VARCHAR(60)
DETERMINISTIC
BEGIN
    IF p_raw LIKE 'HC-%' THEN
        RETURN UPPER(TRIM(p_raw));
    ELSE
        RETURN CONCAT('HC-2026-', UPPER(TRIM(p_raw)));
    END IF;
END $$
DELIMITER ;
```

## Funciones con consultas

### 11.





Crear una función que retorne la cantidad de consultas de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_visits_count $$
CREATE FUNCTION fn_patient_visits_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(mv.id) INTO v_count
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$
DELIMITER ;
```

### 12.





Crear una función que retorne la cantidad de diagnósticos de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_diagnoses_count $$
CREATE FUNCTION fn_patient_diagnoses_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(DISTINCT vd.diagnosis_id) INTO v_count
    FROM visit_diagnoses vd
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$
DELIMITER ;
```

### 13.





Crear una función que retorne la cantidad de controles de glaucoma de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_glaucoma_controls_count $$
CREATE FUNCTION fn_patient_glaucoma_controls_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(gc.id) INTO v_count
    FROM glaucoma_controls gc
    JOIN glaucoma_records gr ON gc.glaucoma_record_id = gr.id
    WHERE gr.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$
DELIMITER ;
```

### 14.





Crear una función que retorne la última fecha de consulta.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_last_visit_date $$
CREATE FUNCTION fn_patient_last_visit_date(p_patient_id BIGINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(mv.visit_date) INTO v_last
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN v_last;
END $$
DELIMITER ;
```

### 15.





Crear una función que retorne la primera fecha de consulta.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_first_visit_date $$
CREATE FUNCTION fn_patient_first_visit_date(p_patient_id BIGINT)
RETURNS DATETIME
READS SQL DATA
BEGIN
    DECLARE v_first DATETIME;
    SELECT MIN(mv.visit_date) INTO v_first
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN v_first;
END $$
DELIMITER ;
```

### 16.





Crear una función que retorne la presión intraocular promedio de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_iop $$
CREATE FUNCTION fn_patient_avg_iop(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 17.





Crear una función que retorne la presión promedio de OD.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_iop_od $$
CREATE FUNCTION fn_patient_avg_iop_od(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = 'OD';
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 18.





Crear una función que retorne la presión promedio de OI.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_iop_oi $$
CREATE FUNCTION fn_patient_avg_iop_oi(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = 'OI';
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 19.





Crear una función que retorne la PIO máxima registrada para un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_max_iop $$
CREATE FUNCTION fn_patient_max_iop(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_max DECIMAL(5,2);
    SELECT MAX(iop.pressure) INTO v_max
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_max, 0.00);
END $$
DELIMITER ;
```

### 20.





Crear una función que retorne la PIO mínima registrada.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_min_iop $$
CREATE FUNCTION fn_patient_min_iop(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_min DECIMAL(5,2);
    SELECT MIN(iop.pressure) INTO v_min
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_min, 0.00);
END $$
DELIMITER ;
```

## Funciones clínicas y de clasificación

### 21.





Crear una función que clasifique una PIO según rangos definidos para fines académicos.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_classify_iop_range $$
CREATE FUNCTION fn_classify_iop_range(p_iop DECIMAL(5,2))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_iop < 10.00 THEN
        RETURN 'HIPOTONIA';
    ELSEIF p_iop <= 21.00 THEN
        RETURN 'RANGO NORMAL';
    ELSEIF p_iop <= 25.00 THEN
        RETURN 'HTO LEVE';
    ELSEIF p_iop <= 30.00 THEN
        RETURN 'HTO MODERADA';
    ELSE
        RETURN 'HTO CRITICA';
    END IF;
END $$
DELIMITER ;
```

### 22.





Crear una función que indique si una PIO supera una presión objetivo recibida como parámetro.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_is_iop_above_target $$
CREATE FUNCTION fn_is_iop_above_target(p_pressure DECIMAL(5,2), p_target DECIMAL(5,2))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN (p_pressure > p_target);
END $$
DELIMITER ;
```

### 23.





Crear una función que determine si un paciente tiene diagnóstico de glaucoma.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_glaucoma_diagnosis $$
CREATE FUNCTION fn_has_glaucoma_diagnosis(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists
    FROM visit_diagnoses vd
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND d.is_glaucoma_type = TRUE;
    RETURN (v_exists > 0);
END $$
DELIMITER ;
```

### 24.





Crear una función que determine si un paciente tiene tratamientos activos.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_active_treatments $$
CREATE FUNCTION fn_has_active_treatments(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(t.id) INTO v_count
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND t.is_active = TRUE;
    RETURN (v_count > 0);
END $$
DELIMITER ;
```

### 25.





Crear una función que indique si el paciente tiene al menos un OCT registrado.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_oct_exam $$
CREATE FUNCTION fn_has_oct_exam(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(oct.id) INTO v_count
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$
DELIMITER ;
```

### 26.





Crear una función que indique si tiene campo visual registrado.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_visual_field $$
CREATE FUNCTION fn_has_visual_field(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(vf.id) INTO v_count
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$
DELIMITER ;
```

### 27.





Crear una función que determine si tiene paquimetría.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_pachymetry $$
CREATE FUNCTION fn_has_pachymetry(p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(pe.id) INTO v_count
    FROM pachymetry_exams pe
    JOIN medical_visits mv ON pe.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$
DELIMITER ;
```

### 28.





Crear una función que determine si el paciente tiene controles pendientes según un número de meses.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_pending_controls $$
CREATE FUNCTION fn_has_pending_controls(p_patient_id BIGINT, p_months INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(visit_date) INTO v_last
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    
    IF v_last IS NULL THEN
        RETURN TRUE;
    END IF;
    RETURN (TIMESTAMPDIFF(MONTH, v_last, NOW()) >= p_months);
END $$
DELIMITER ;
```

### 29.





Crear una función que clasifique un paciente según cantidad de consultas: nuevo, recurrente o frecuente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_classify_patient_frequency $$
CREATE FUNCTION fn_classify_patient_frequency(p_patient_id BIGINT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_visits INT;
    SET v_visits = fn_patient_visits_count(p_patient_id);
    IF v_visits <= 1 THEN
        RETURN 'NUEVO';
    ELSEIF v_visits <= 3 THEN
        RETURN 'RECURRENTE';
    ELSE
        RETURN 'FRECUENTE';
    END IF;
END $$
DELIMITER ;
```

### 30.





Crear una función que retorne `Completo` si el paciente tiene OCT, campo visual, PIO y paquimetría, o `Incompleto` en caso contrario.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_clinical_exam_completeness $$
CREATE FUNCTION fn_clinical_exam_completeness(p_patient_id BIGINT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    IF fn_has_oct_exam(p_patient_id)
       AND fn_has_visual_field(p_patient_id)
       AND fn_has_pachymetry(p_patient_id)
       AND (fn_patient_avg_iop(p_patient_id) > 0.00) THEN
        RETURN 'COMPLETO';
    ELSE
        RETURN 'INCOMPLETO';
    END IF;
END $$
DELIMITER ;
```

## Funciones estadísticas

### 31.





Crear una función que calcule el promedio de PIO entre dos fechas para un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_iop_period $$
CREATE FUNCTION fn_patient_avg_iop_period(p_patient_id BIGINT, p_start DATE, p_end DATE)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
      AND DATE(mv.visit_date) BETWEEN p_start AND p_end;
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 32.





Crear una función que calcule la diferencia entre la primera y última PIO.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_iop_difference $$
CREATE FUNCTION fn_patient_iop_difference(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_first DECIMAL(5,2);
    DECLARE v_last DECIMAL(5,2);

    SELECT iop.pressure INTO v_first
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date ASC, iop.id ASC LIMIT 1;

    SELECT iop.pressure INTO v_last
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;

    IF v_first IS NULL OR v_last IS NULL THEN
        RETURN 0.00;
    END IF;
    RETURN (v_last - v_first);
END $$
DELIMITER ;
```

### 33.





Crear una función que retorne el número de días desde la última consulta.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_days_since_last_visit $$
CREATE FUNCTION fn_days_since_last_visit(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SET v_last = fn_patient_last_visit_date(p_patient_id);
    IF v_last IS NULL THEN
        RETURN -1;
    END IF;
    RETURN DATEDIFF(CURDATE(), DATE(v_last));
END $$
DELIMITER ;
```

### 34.





Crear una función que retorne el número de meses desde el último OCT.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_months_since_last_oct $$
CREATE FUNCTION fn_months_since_last_oct(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(oct.exam_date) INTO v_last
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;

    IF v_last IS NULL THEN
        RETURN -1;
    END IF;
    RETURN TIMESTAMPDIFF(MONTH, v_last, NOW());
END $$
DELIMITER ;
```

### 35.





Crear una función que retorne el número de meses desde el último campo visual.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_months_since_last_vf $$
CREATE FUNCTION fn_months_since_last_vf(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_last DATETIME;
    SELECT MAX(vf.exam_date) INTO v_last
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;

    IF v_last IS NULL THEN
        RETURN -1;
    END IF;
    RETURN TIMESTAMPDIFF(MONTH, v_last, NOW());
END $$
DELIMITER ;
```

### 36.





Crear una función que calcule el promedio de RNFL de los OCT de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_rnfl $$
CREATE FUNCTION fn_patient_avg_rnfl(p_patient_id BIGINT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(6,2);
    SELECT AVG(oct.rnfl_average) INTO v_avg
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 37.





Crear una función que retorne el valor más reciente de RNFL.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_latest_rnfl $$
CREATE FUNCTION fn_patient_latest_rnfl(p_patient_id BIGINT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_rnfl DECIMAL(6,2);
    SELECT oct.rnfl_average INTO v_rnfl
    FROM oct_exams oct
    JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY oct.exam_date DESC LIMIT 1;
    RETURN IFNULL(v_rnfl, 0.00);
END $$
DELIMITER ;
```

### 38.





Crear una función que calcule el promedio de VFI de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_vfi $$
CREATE FUNCTION fn_patient_avg_vfi(p_patient_id BIGINT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(vf.visual_field_index_vfi) INTO v_avg
    FROM visual_field_exams vf
    JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 39.





Crear una función que retorne la cantidad de tratamientos históricos.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_total_treatments $$
CREATE FUNCTION fn_patient_total_treatments(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(t.id) INTO v_count
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$
DELIMITER ;
```

### 40.





Crear una función que retorne la cantidad de medicamentos diferentes utilizados por un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_distinct_medications_count $$
CREATE FUNCTION fn_patient_distinct_medications_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(DISTINCT t.medication_id) INTO v_count
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$
DELIMITER ;
```

## Funciones avanzadas

### 41.





Crear una función que reciba paciente y ojo y retorne la última PIO registrada.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_latest_iop_by_eye $$
CREATE FUNCTION fn_patient_latest_iop_by_eye(p_patient_id BIGINT, p_eye VARCHAR(10))
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_iop DECIMAL(5,2);
    SELECT iop.pressure INTO v_iop
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = p_eye
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;
    RETURN IFNULL(v_iop, 0.00);
END $$
DELIMITER ;
```

### 42.





Crear una función que reciba paciente y ojo y retorne la PIO promedio.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_avg_iop_by_eye $$
CREATE FUNCTION fn_patient_avg_iop_by_eye(p_patient_id BIGINT, p_eye VARCHAR(10))
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(5,2);
    SELECT AVG(iop.pressure) INTO v_avg
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND iop.eye = p_eye;
    RETURN IFNULL(v_avg, 0.00);
END $$
DELIMITER ;
```

### 43.





Crear una función que determine si la última PIO es mayor o menor que la primera.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_iop_trend $$
CREATE FUNCTION fn_iop_trend(p_patient_id BIGINT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_diff DECIMAL(5,2);
    SET v_diff = fn_patient_iop_difference(p_patient_id);
    IF v_diff > 0.00 THEN
        RETURN 'AUMENTO';
    ELSEIF v_diff < 0.00 THEN
        RETURN 'DISMINUCION';
    ELSE
        RETURN 'ESTABLE';
    END IF;
END $$
DELIMITER ;
```

### 44.





Crear una función que retorne la diferencia porcentual entre primera y última PIO.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_iop_pct_change $$
CREATE FUNCTION fn_iop_pct_change(p_patient_id BIGINT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_first DECIMAL(5,2);
    DECLARE v_last DECIMAL(5,2);

    SELECT iop.pressure INTO v_first
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date ASC, iop.id ASC LIMIT 1;

    SELECT iop.pressure INTO v_last
    FROM intraocular_pressures iop
    JOIN medical_visits mv ON iop.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id
    ORDER BY mv.visit_date DESC, iop.id DESC LIMIT 1;

    IF v_first IS NULL OR v_first = 0.00 OR v_last IS NULL THEN
        RETURN 0.00;
    END IF;
    RETURN ROUND(((v_last - v_first) / v_first) * 100.0, 2);
END $$
DELIMITER ;
```

### 45.





Crear una función que retorne el diagnóstico principal más reciente de un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_latest_primary_diagnosis $$
CREATE FUNCTION fn_patient_latest_primary_diagnosis(p_patient_id BIGINT)
RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
    DECLARE v_diag VARCHAR(200);
    SELECT d.name INTO v_diag
    FROM visit_diagnoses vd
    JOIN diagnoses d ON vd.diagnosis_id = d.id
    JOIN medical_visits mv ON vd.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND vd.is_primary = TRUE
    ORDER BY mv.visit_date DESC LIMIT 1;
    RETURN IFNULL(v_diag, 'SIN DIAGNOSTICO PRINCIPAL');
END $$
DELIMITER ;
```

### 46.





Crear una función que retorne el nombre del medicamento activo más reciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_latest_active_medication $$
CREATE FUNCTION fn_patient_latest_active_medication(p_patient_id BIGINT)
RETURNS VARCHAR(150)
READS SQL DATA
BEGIN
    DECLARE v_med VARCHAR(150);
    SELECT m.name INTO v_med
    FROM treatments t
    JOIN medications m ON t.medication_id = m.id
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND t.is_active = TRUE
    ORDER BY t.start_date DESC LIMIT 1;
    RETURN IFNULL(v_med, 'SIN TRATAMIENTO ACTIVO');
END $$
DELIMITER ;
```

### 47.





Crear una función que retorne la cantidad de procedimientos realizados a un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_procedures_count $$
CREATE FUNCTION fn_patient_procedures_count(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(pr.id) INTO v_count
    FROM procedures pr
    JOIN medical_visits mv ON pr.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id;
    RETURN IFNULL(v_count, 0);
END $$
DELIMITER ;
```

### 48.





Crear una función que determine si un profesional ha atendido alguna vez a un paciente específico.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_has_doctor_treated_patient $$
CREATE FUNCTION fn_has_doctor_treated_patient(p_prof_id BIGINT, p_patient_id BIGINT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(mv.id) INTO v_count
    FROM medical_visits mv
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE mv.professional_id = p_prof_id AND ch.patient_id = p_patient_id;
    RETURN (v_count > 0);
END $$
DELIMITER ;
```

### 49.





Crear una función que calcule la cantidad total de exámenes especializados registrados para un paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_total_specialized_exams $$
CREATE FUNCTION fn_patient_total_specialized_exams(p_patient_id BIGINT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_oct INT DEFAULT 0;
    DECLARE v_vf INT DEFAULT 0;
    DECLARE v_pachy INT DEFAULT 0;
    DECLARE v_gonio INT DEFAULT 0;
    DECLARE v_va INT DEFAULT 0;
    DECLARE v_bio INT DEFAULT 0;

    SELECT COUNT(oct.id) INTO v_oct
    FROM oct_exams oct JOIN medical_visits mv ON oct.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(vf.id) INTO v_vf
    FROM visual_field_exams vf JOIN medical_visits mv ON vf.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(pe.id) INTO v_pachy
    FROM pachymetry_exams pe JOIN medical_visits mv ON pe.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(ge.id) INTO v_gonio
    FROM gonioscopy_exams ge JOIN medical_visits mv ON ge.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(va.id) INTO v_va
    FROM visual_acuity_exams va JOIN medical_visits mv ON va.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SELECT COUNT(bio.id) INTO v_bio
    FROM biomicroscopy_exams bio JOIN medical_visits mv ON bio.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id WHERE ch.patient_id = p_patient_id;

    SET v_total = v_oct + v_vf + v_pachy + v_gonio + v_va + v_bio;
    RETURN v_total;
END $$
DELIMITER ;
```

### 50.





Crear una función que genere un resumen textual como:

```
Paciente: Carlos Gómez
Consultas: 8
Controles glaucoma: 4
Última PIO OD: 18
Última PIO OI: 17
Tratamientos activos: 2
```

a partir del ID del paciente.

```sql
DELIMITER $$
DROP FUNCTION IF EXISTS fn_patient_summary_card $$
CREATE FUNCTION fn_patient_summary_card(p_patient_id BIGINT)
RETURNS TEXT
READS SQL DATA
BEGIN
    DECLARE v_name VARCHAR(210);
    DECLARE v_visits INT;
    DECLARE v_controls INT;
    DECLARE v_last_od DECIMAL(5,2);
    DECLARE v_last_oi DECIMAL(5,2);
    DECLARE v_active_tx INT;
    DECLARE v_result TEXT;

    SELECT CONCAT(per.first_name, ' ', per.last_name) INTO v_name
    FROM patients p
    JOIN persons per ON p.person_id = per.id
    WHERE p.id = p_patient_id;
    IF v_name IS NULL THEN
        RETURN 'PACIENTE NO REGISTRADO';
    END IF;

    SET v_visits = fn_patient_visits_count(p_patient_id);
    SET v_controls = fn_patient_glaucoma_controls_count(p_patient_id);
    SET v_last_od = fn_patient_latest_iop_by_eye(p_patient_id, 'OD');
    SET v_last_oi = fn_patient_latest_iop_by_eye(p_patient_id, 'OI');

    SELECT COUNT(t.id) INTO v_active_tx
    FROM treatments t
    JOIN medical_visits mv ON t.visit_id = mv.id
    JOIN clinical_histories ch ON mv.clinical_history_id = ch.id
    WHERE ch.patient_id = p_patient_id AND t.is_active = TRUE;

    SET v_result = CONCAT(
        'Paciente: ', v_name, '\n',
        'Consultas: ', v_visits, '\n',
        'Controles glaucoma: ', v_controls, '\n',
        'Última PIO OD: ', IF(v_last_od > 0, v_last_od, 'Sin registro'), '\n',
        'Última PIO OI: ', IF(v_last_oi > 0, v_last_oi, 'Sin registro'), '\n',
        'Tratamientos activos: ', v_active_tx
    );

    RETURN v_result;
END $$

DELIMITER ;
DELIMITER ;
```

