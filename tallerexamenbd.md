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

```
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

```
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

```
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

```
SELECT
    AVG(pressure) AS average_pressure,
    MIN(pressure) AS minimum_pressure,
    MAX(pressure) AS maximum_pressure
FROM intraocular_pressures;
```

# 30. GROUP BY

Ejemplo:

```
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
    COUNT(*) AS controls
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

### 2.

Mostrar únicamente el número de documento, nombres y apellidos de todos los pacientes.

### 3.

Listar todos los profesionales de salud registrados.

### 4.

Mostrar todos los diagnósticos disponibles en el catálogo.

### 5.

Consultar todas las historias clínicas registradas.

### 6.

Mostrar todos los pacientes ordenados alfabéticamente por apellido.

### 7.

Mostrar los pacientes ordenados por fecha de nacimiento desde el más joven hasta el de mayor edad.

### 8.

Consultar los pacientes cuyo apellido sea `Gómez`.

### 9.

Mostrar los pacientes cuyo número de documento comience por `10`.

### 10.

Consultar los pacientes cuyo correo electrónico pertenezca al dominio `gmail.com`.

### 11.

Mostrar los pacientes que no tengan correo electrónico registrado.

### 12.

Mostrar los profesionales cuya especialidad sea Oftalmología.

### 13.

Consultar todas las consultas médicas realizadas durante el año 2026.

### 14.

Mostrar las consultas realizadas durante un mes determinado.

### 15.

Consultar las mediciones de presión intraocular superiores a 20 mmHg.

### 16.

Mostrar las mediciones de presión intraocular correspondientes únicamente al ojo derecho.

### 17.

Mostrar las mediciones correspondientes únicamente al ojo izquierdo.

### 18.

Consultar todos los tratamientos que se encuentren activos.

### 19.

Mostrar todos los tratamientos que hayan finalizado.

### 20.

Consultar los procedimientos realizados después de una fecha determinada.

## Nivel intermedio

### 21.

Mostrar cada paciente junto con el número de su historia clínica.

### 22.

Mostrar cada consulta indicando el nombre completo del paciente.

### 23.

Mostrar cada consulta junto con el nombre del profesional que la realizó.

### 24.

Listar todos los pacientes junto con la fecha de sus consultas.

### 25.

Mostrar los diagnósticos asociados a cada consulta.

### 26.

Mostrar nombre del paciente, fecha de consulta y diagnóstico correspondiente.

### 27.

Consultar todos los pacientes que tengan diagnóstico de glaucoma.

### 28.

Mostrar todos los controles de glaucoma indicando el paciente correspondiente.

### 29.

Mostrar cada medición de presión intraocular junto con nombre del paciente, fecha y ojo.

### 30.

Mostrar los estudios OCT realizados indicando paciente, ojo y fecha.

### 31.

Mostrar los campos visuales registrados indicando paciente, ojo, MD, PSD y VFI.

### 32.

Mostrar las paquimetrías realizadas junto con el paciente y el espesor corneal registrado.

### 33.

Mostrar los tratamientos activos incluyendo nombre del paciente y medicamento.

### 34.

Mostrar cada medicamento y la cantidad de tratamientos en los que ha sido utilizado.

### 35.

Mostrar la cantidad total de pacientes registrados.

### 36.

Mostrar la cantidad de consultas realizadas.

### 37.

Mostrar la cantidad de pacientes por sexo.

### 38.

Mostrar la cantidad de pacientes atendidos por cada profesional.

### 39.

Calcular el promedio general de presión intraocular.

### 40.

Calcular la presión intraocular mínima y máxima registrada.

## Nivel avanzado

### 41.

Calcular la presión intraocular promedio para OD y OI por separado.

### 42.

Mostrar la cantidad de consultas realizadas por cada paciente.

### 43.

Mostrar únicamente los pacientes que tengan tres o más consultas.

### 44.

Mostrar cada profesional junto con la cantidad de consultas realizadas.

### 45.

Mostrar los profesionales que hayan realizado más de 20 consultas.

### 46.

Calcular la cantidad de diagnósticos registrados por tipo de diagnóstico.

### 47.

Mostrar los cinco diagnósticos más frecuentes.

### 48.

Mostrar la cantidad de estudios OCT realizados por mes.

### 49.

Mostrar la cantidad de campos visuales realizados por año.

### 50.

Generar un reporte que muestre por paciente: nombre completo, número de consultas, cantidad de controles de glaucoma, promedio de PIO y fecha de última consulta.

# PARTE II — 50 EJERCICIOS DE SUBCONSULTAS

## Subconsultas escalares

### 1.

Mostrar los pacientes cuya edad sea superior a la edad promedio de todos los pacientes.

### 2.

Mostrar los pacientes cuya edad sea inferior a la edad promedio.

### 3.

Consultar la medición de presión intraocular más alta registrada.

### 4.

Mostrar todas las mediciones que tengan el mismo valor que la presión máxima registrada.

### 5.

Mostrar la presión intraocular mínima registrada.

### 6.

Mostrar los estudios OCT cuyo RNFL sea inferior al promedio general.

### 7.

Mostrar los estudios OCT cuyo RNFL sea superior al promedio general.

### 8.

Consultar pacientes cuya cantidad de consultas sea mayor que el promedio de consultas por paciente.

### 9.

Mostrar profesionales cuya cantidad de consultas sea superior al promedio por profesional.

### 10.

Consultar pacientes cuya última presión intraocular sea superior al promedio general.

## Subconsultas con IN

### 11.

Mostrar pacientes que tengan al menos una consulta registrada.

### 12.

Mostrar pacientes que tengan diagnóstico de glaucoma.

### 13.

Mostrar pacientes que hayan recibido tratamiento farmacológico.

### 14.

Mostrar pacientes que tengan estudios OCT registrados.

### 15.

Mostrar pacientes que tengan campos visuales registrados.

### 16.

Mostrar medicamentos que hayan sido utilizados en al menos un tratamiento.

### 17.

Mostrar profesionales que hayan atendido pacientes con glaucoma.

### 18.

Mostrar diagnósticos utilizados en alguna consulta.

### 19.

Mostrar pacientes que hayan tenido algún procedimiento quirúrgico.

### 20.

Mostrar pacientes que tengan registros de paquimetría.

## Subconsultas con NOT IN / NOT EXISTS

### 21.

Mostrar pacientes que nunca hayan tenido una consulta.

### 22.

Mostrar pacientes que nunca hayan tenido un control de glaucoma.

### 23.

Mostrar pacientes que no tengan estudios OCT.

### 24.

Mostrar pacientes que no tengan campos visuales.

### 25.

Mostrar medicamentos que nunca hayan sido utilizados.

### 26.

Mostrar profesionales que todavía no hayan registrado consultas.

### 27.

Mostrar diagnósticos que nunca hayan sido asociados a una consulta.

### 28.

Mostrar pacientes que no tengan tratamientos activos.

### 29.

Mostrar pacientes que nunca hayan tenido procedimientos.

### 30.

Mostrar pacientes sin mediciones de presión intraocular.

## Subconsultas correlacionadas

### 31.

Mostrar las mediciones de PIO superiores al promedio del mismo paciente.

### 32.

Mostrar los estudios OCT cuyo RNFL sea inferior al promedio del mismo paciente.

### 33.

Mostrar las consultas posteriores a la primera consulta de cada paciente.

### 34.

Mostrar la última consulta de cada paciente utilizando una subconsulta correlacionada.

### 35.

Mostrar la primera medición de PIO de cada paciente.

### 36.

Mostrar la última medición de presión intraocular de cada paciente y ojo.

### 37.

Mostrar los tratamientos cuya fecha de inicio sea posterior a la primera consulta del paciente.

### 38.

Mostrar pacientes cuyo número de consultas sea mayor que el de todos los demás pacientes de su misma ciudad.

### 39.

Mostrar profesionales cuya cantidad de consultas sea superior al promedio de los profesionales de su especialidad.

### 40.

Mostrar el estudio OCT más reciente de cada paciente.

## Subconsultas avanzadas

### 41.

Mostrar pacientes cuya presión intraocular máxima sea mayor que la presión máxima promedio de todos los pacientes.

### 42.

Mostrar pacientes cuya cantidad de diagnósticos diferentes sea superior al promedio.

### 43.

Mostrar los pacientes que tengan más tratamientos activos que el promedio de tratamientos activos por paciente.

### 44.

Mostrar el medicamento más utilizado en tratamientos.

### 45.

Mostrar el diagnóstico más frecuente utilizando subconsultas.

### 46.

Mostrar los pacientes cuya última PIO sea inferior a su primera PIO.

### 47.

Mostrar pacientes cuya presión promedio del ojo derecho sea mayor que la del ojo izquierdo.

### 48.

Mostrar los pacientes con mayor cantidad de controles de glaucoma que el promedio general.

### 49.

Mostrar las consultas que tengan más diagnósticos asociados que el promedio de diagnósticos por consulta.

### 50.

Mostrar los pacientes que tengan simultáneamente OCT, campo visual, paquimetría y control de glaucoma registrados.

# PARTE III — 50 EJERCICIOS DE PROCEDIMIENTOS ALMACENADOS

## Procedimientos básicos

### 1.

Crear un procedimiento que liste todos los pacientes.

### 2.

Crear un procedimiento que reciba el ID de un paciente y muestre sus datos.

### 3.

Crear un procedimiento que busque un paciente por número de documento.

### 4.

Crear un procedimiento que liste todas las consultas de un paciente.

### 5.

Crear un procedimiento que muestre todos los profesionales.

### 6.

Crear un procedimiento que reciba una especialidad y muestre sus profesionales.

### 7.

Crear un procedimiento que liste diagnósticos.

### 8.

Crear un procedimiento que muestre medicamentos activos.

### 9.

Crear un procedimiento que liste procedimientos clínicos realizados a un paciente.

### 10.

Crear un procedimiento para consultar todos los controles de glaucoma de un paciente.

## Procedimientos de inserción

### 11.

Crear un procedimiento para registrar un nuevo paciente.

### 12.

Crear un procedimiento para crear una historia clínica.

### 13.

Crear un procedimiento para registrar una consulta médica.

### 14.

Crear un procedimiento para registrar un diagnóstico asociado a una consulta.

### 15.

Crear un procedimiento para registrar una medición de PIO.

### 16.

Crear un procedimiento para registrar un control de glaucoma.

### 17.

Crear un procedimiento para registrar un examen OCT.

### 18.

Crear un procedimiento para registrar un campo visual.

### 19.

Crear un procedimiento para registrar una paquimetría.

### 20.

Crear un procedimiento para registrar un tratamiento.

## Procedimientos de modificación

### 21.

Crear un procedimiento para actualizar teléfono y correo de un paciente.

### 22.

Crear un procedimiento para modificar el estado de una historia clínica.

### 23.

Crear un procedimiento para actualizar observaciones de una consulta.

### 24.

Crear un procedimiento para modificar la presión objetivo de un paciente con glaucoma.

### 25.

Crear un procedimiento para finalizar un tratamiento.

### 26.

Crear un procedimiento para cambiar el medicamento de un tratamiento.

### 27.

Crear un procedimiento para actualizar el estado clínico del glaucoma.

### 28.

Crear un procedimiento para actualizar información de un profesional.

### 29.

Crear un procedimiento para modificar la interpretación de un OCT.

### 30.

Crear un procedimiento para actualizar la interpretación de un campo visual.

## Procedimientos con validaciones

### 31.

Crear un procedimiento que registre una PIO únicamente si el paciente existe.

### 32.

Crear un procedimiento que registre una consulta solo si existe la historia clínica.

### 33.

Crear un procedimiento que impida registrar un tratamiento con fecha final anterior a la inicial.

### 34.

Crear un procedimiento que impida registrar valores negativos de PIO.

### 35.

Crear un procedimiento que valide que el ojo recibido sea `OD` u `OI`.

### 36.

Crear un procedimiento que impida crear dos historias clínicas para el mismo paciente.

### 37.

Crear un procedimiento que registre un diagnóstico solo si existe en el catálogo.

### 38.

Crear un procedimiento que valide que el profesional se encuentre activo antes de registrar una consulta.

### 39.

Crear un procedimiento que registre un campo visual validando que VFI esté entre 0 y 100.

### 40.

Crear un procedimiento que registre una paquimetría validando que el valor sea positivo.

## Procedimientos avanzados

### 41.

Crear un procedimiento que devuelva un resumen completo de la historia clínica de un paciente.

### 42.

Crear un procedimiento que muestre la evolución de PIO de un paciente entre dos fechas.

### 43.

Crear un procedimiento que reciba paciente y ojo y muestre todas sus mediciones cronológicamente.

### 44.

Crear un procedimiento que genere estadísticas mensuales de consultas.

### 45.

Crear un procedimiento que calcule la cantidad de pacientes atendidos por cada especialista.

### 46.

Crear un procedimiento que determine pacientes sin consulta durante un número de meses recibido como parámetro.

### 47.

Crear un procedimiento que genere un resumen de diagnósticos por paciente.

### 48.

Crear un procedimiento que devuelva el último OCT, último campo visual y última PIO de un paciente.

### 49.

Crear un procedimiento que registre en una sola transacción una consulta, un diagnóstico y una medición de PIO.

### 50.

Crear un procedimiento transaccional que registre un control completo de glaucoma y ejecute `ROLLBACK` si alguna operación falla.

# PARTE IV — 50 EJERCICIOS DE TRIGGERS

## BEFORE INSERT

### 1.

Crear un trigger que elimine espacios externos de los nombres de pacientes antes de insertarlos.

### 2.

Convertir automáticamente el correo del paciente a minúsculas.

### 3.

Convertir el número de documento a mayúsculas cuando contenga caracteres.

### 4.

Impedir registrar una fecha de nacimiento futura.

### 5.

Impedir registrar una presión intraocular negativa.

### 6.

Impedir registrar una PIO superior a un límite definido para datos plausibles.

### 7.

Validar que el campo `eye` solo admita `OD` u `OI`.

### 8.

Impedir que un tratamiento tenga fecha final anterior a la inicial.

### 9.

Validar que el VFI de un campo visual esté entre 0 y 100.

### 10.

Validar que la paquimetría sea mayor que cero.

## AFTER INSERT

### 11.

Registrar en auditoría la creación de un nuevo paciente.

### 12.

Registrar en auditoría la creación de una historia clínica.

### 13.

Registrar automáticamente en auditoría cada nueva consulta.

### 14.

Registrar cada nuevo diagnóstico asociado a una consulta.

### 15.

Registrar cada nueva medición de presión intraocular.

### 16.

Registrar cada nuevo tratamiento.

### 17.

Registrar cada nuevo procedimiento.

### 18.

Registrar en auditoría cada nuevo estudio OCT.

### 19.

Registrar cada campo visual creado.

### 20.

Crear una notificación interna cuando se registre una PIO mayor que un valor determinado.

## BEFORE UPDATE

### 21.

Actualizar automáticamente `updated_at` antes de modificar un paciente.

### 22.

Actualizar `updated_at` antes de modificar una consulta.

### 23.

Impedir modificar el número de documento una vez creada la historia clínica.

### 24.

Impedir asignar una fecha de consulta futura no permitida.

### 25.

Validar que una nueva presión objetivo sea positiva.

### 26.

Impedir establecer una fecha final de tratamiento anterior a su inicio.

### 27.

Evitar modificar un examen OCT que haya sido marcado como validado.

### 28.

Evitar modificar una consulta marcada como cerrada.

### 29.

Validar valores del campo visual antes de una actualización.

### 30.

Normalizar observaciones eliminando espacios innecesarios antes de actualizar.

## AFTER UPDATE

### 31.

Registrar cambios de datos personales del paciente.

### 32.

Guardar valor anterior y nuevo del correo del paciente.

### 33.

Registrar cambios en la presión objetivo.

### 34.

Auditar cambios en el estado del glaucoma.

### 35.

Registrar cambios en tratamientos.

### 36.

Registrar cambios en diagnósticos.

### 37.

Registrar cambios de interpretación de OCT.

### 38.

Registrar modificaciones de campos visuales.

### 39.

Generar una alerta cuando una PIO sea actualizada a un valor superior al objetivo.

### 40.

Registrar cuándo un tratamiento cambia de activo a finalizado.

## DELETE y auditoría

### 41.

Guardar una copia de un paciente antes de eliminarlo.

### 42.

Guardar una copia de una consulta eliminada.

### 43.

Guardar un histórico de un tratamiento eliminado.

### 44.

Registrar en auditoría la eliminación de un diagnóstico.

### 45.

Impedir eliminar pacientes que tengan historia clínica.

### 46.

Impedir eliminar profesionales con consultas registradas.

### 47.

Impedir eliminar medicamentos actualmente utilizados en tratamientos activos.

### 48.

Registrar automáticamente la eliminación de un examen OCT.

### 49.

Registrar quién eliminó un documento clínico.

### 50.

Implementar un esquema completo de auditoría mediante triggers para `INSERT`, `UPDATE` y `DELETE` sobre la tabla `patients`.

# PARTE V — 50 EJERCICIOS DE FUNCIONES ALMACENADAS

## Funciones básicas

### 1.

Crear una función que calcule la edad de un paciente a partir de su fecha de nacimiento.

### 2.

Crear una función que reciba nombres y apellidos y retorne el nombre completo.

### 3.

Crear una función que reciba un ID de paciente y retorne su número de documento.

### 4.

Crear una función que reciba un ID de paciente y retorne su edad.

### 5.

Crear una función que reciba el ID de una consulta y retorne su fecha.

### 6.

Crear una función que determine cuántos años han pasado desde una fecha.

### 7.

Crear una función que reciba un valor de PIO y retorne un texto descriptivo.

### 8.

Crear una función que reciba `OD` u `OI` y devuelva `Ojo derecho` u `Ojo izquierdo`.

### 9.

Crear una función que reciba un booleano y retorne `Activo` o `Inactivo`.

### 10.

Crear una función que formatee un número de historia clínica.

## Funciones con consultas

### 11.

Crear una función que retorne la cantidad de consultas de un paciente.

### 12.

Crear una función que retorne la cantidad de diagnósticos de un paciente.

### 13.

Crear una función que retorne la cantidad de controles de glaucoma de un paciente.

### 14.

Crear una función que retorne la última fecha de consulta.

### 15.

Crear una función que retorne la primera fecha de consulta.

### 16.

Crear una función que retorne la presión intraocular promedio de un paciente.

### 17.

Crear una función que retorne la presión promedio de OD.

### 18.

Crear una función que retorne la presión promedio de OI.

### 19.

Crear una función que retorne la PIO máxima registrada para un paciente.

### 20.

Crear una función que retorne la PIO mínima registrada.

## Funciones clínicas y de clasificación

### 21.

Crear una función que clasifique una PIO según rangos definidos para fines académicos.

### 22.

Crear una función que indique si una PIO supera una presión objetivo recibida como parámetro.

### 23.

Crear una función que determine si un paciente tiene diagnóstico de glaucoma.

### 24.

Crear una función que determine si un paciente tiene tratamientos activos.

### 25.

Crear una función que indique si el paciente tiene al menos un OCT registrado.

### 26.

Crear una función que indique si tiene campo visual registrado.

### 27.

Crear una función que determine si tiene paquimetría.

### 28.

Crear una función que determine si el paciente tiene controles pendientes según un número de meses.

### 29.

Crear una función que clasifique un paciente según cantidad de consultas: nuevo, recurrente o frecuente.

### 30.

Crear una función que retorne `Completo` si el paciente tiene OCT, campo visual, PIO y paquimetría, o `Incompleto` en caso contrario.

## Funciones estadísticas

### 31.

Crear una función que calcule el promedio de PIO entre dos fechas para un paciente.

### 32.

Crear una función que calcule la diferencia entre la primera y última PIO.

### 33.

Crear una función que retorne el número de días desde la última consulta.

### 34.

Crear una función que retorne el número de meses desde el último OCT.

### 35.

Crear una función que retorne el número de meses desde el último campo visual.

### 36.

Crear una función que calcule el promedio de RNFL de los OCT de un paciente.

### 37.

Crear una función que retorne el valor más reciente de RNFL.

### 38.

Crear una función que calcule el promedio de VFI de un paciente.

### 39.

Crear una función que retorne la cantidad de tratamientos históricos.

### 40.

Crear una función que retorne la cantidad de medicamentos diferentes utilizados por un paciente.

## Funciones avanzadas

### 41.

Crear una función que reciba paciente y ojo y retorne la última PIO registrada.

### 42.

Crear una función que reciba paciente y ojo y retorne la PIO promedio.

### 43.

Crear una función que determine si la última PIO es mayor o menor que la primera.

### 44.

Crear una función que retorne la diferencia porcentual entre primera y última PIO.

### 45.

Crear una función que retorne el diagnóstico principal más reciente de un paciente.

### 46.

Crear una función que retorne el nombre del medicamento activo más reciente.

### 47.

Crear una función que retorne la cantidad de procedimientos realizados a un paciente.

### 48.

Crear una función que determine si un profesional ha atendido alguna vez a un paciente específico.

### 49.

Crear una función que calcule la cantidad total de exámenes especializados registrados para un paciente.

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

