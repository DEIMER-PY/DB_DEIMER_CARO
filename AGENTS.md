# AGENTS.md — Protocolo y Contexto de Proyecto para Agentes de IA

Este documento contiene la especificación técnica completa, el estado de avance, las convenciones de desarrollo y las instrucciones operativas del proyecto **TALLERDB_DEIMER_CARO**. Ha sido diseñado para permitir la migración fluida e inmediata entre agentes de inteligencia artificial (AGY, Gemini, Claude, GPT, etc.) sin pérdida de contexto ni divergencia en las decisiones arquitectónicas.

---

## 1. Identificación y Objetivos del Proyecto

- **Nombre del Proyecto:** Sistema de Gestión Integral de Historias Clínicas (Oftalmología y Glaucoma)
- **Autor / Titular:** Deimer Caro
- **Ubicación en el Filesystem:** `/home/camper/Documentos/TALLERDB_DEIMER_CARO`
- **Guía de Requerimientos y Rúbricas:** [`tallerexamenbd.md`](file:///home/camper/Documentos/TALLERDB_DEIMER_CARO/tallerexamenbd.md)
- **Objetivo Central:** Diseñar, normalizar rigurosamente hasta la **Cuarta Forma Normal (4FN)**, documentar e implementar en **MySQL 8.0** una base de datos relacional médica de nivel clínico, acompañada de un banco exhaustivo de **250 ejercicios resueltos** (consultas, subconsultas, procedimientos almacenados, triggers y funciones), modelos conceptual/lógico/físico, archivo nativo StarUML y suite de pruebas automatizadas.

---

## 2. Entorno de Ejecución y Configuración de Infraestructura

> [!IMPORTANT]
> MySQL corre en un puerto alternativo local. Cualquier comando CLI o conexión por cliente DEBE apuntar explícitamente al puerto 3307 y dirección IPv4 `127.0.0.1`.

- **Motor RDBMS:** MySQL 8.0 (InnoDB)
- **Host:** `127.0.0.1`
- **Puerto:** `3307`
- **Usuario:** `root`
- **Contraseña:** `root2026`
- **Base de Datos:** `oftalmologia_glaucoma_db`
- **Comando de Conexión CLI de referencia:**
  ```bash
  mysql -h 127.0.0.1 -P 3307 -u root -proot2026 oftalmologia_glaucoma_db
  ```
- **Herramienta UML Instalada en el Sistema:**
  - Binario StarUML: `/usr/bin/staruml`
  - Archivo de modelo nativo: `diagrams/oftalmologia_model.mdj`

---

## 3. Arquitectura del Repositorio de Archivos

```
/home/camper/Documentos/TALLERDB_DEIMER_CARO/
├── AGENTS.md                          # Este archivo: contexto vivo y directrices de relevo
├── README.md                          # Documentación maestra de entrega y sustentación
├── tallerexamenbd.md                  # Enunciado y rúbricas originales del taller
├── .gitignore                         # Reglas de exclusión Git
│
├── diagrams/                          # Modelos visuales y de herramientas
│   ├── oftalmologia_model.mdj         # Metamodelo nativo en formato JSON para StarUML 5.x
│   ├── conceptual_model.mmd           # Diagrama Conceptual (Mermaid erDiagram)
│   ├── logical_model.mmd              # Diagrama Lógico Relacional (Mermaid)
│   └── physical_erd.mmd               # Diagrama Físico / DER Completo (Mermaid)
│
├── docs/                              # Documentación teórica y técnica
│   ├── 01_planteamiento_problema.md   # Justificación clínica, alcance y entidades
│   ├── 02_proceso_normalizacion_4fn.md# Justificación paso a paso de 0FN a 4FN con MVDs
│   ├── 03_diccionario_de_datos.md     # Diccionario de datos de las 25 tablas relacionales
│   └── 04_guia_ejecucion_pruebas.md   # Guía paso a paso de despliegue y pruebas
│
├── sql/                               # Scripts SQL organizados secuencialmente
│   ├── 00_init_database.sql           # CREATE DATABASE utf8mb4, DROP IF EXISTS
│   ├── 01_ddl_schema.sql              # Creación de tablas, PKs, FKs, CHECKs, UNIQUEs, auditoría
│   ├── 02_dml_seed_data.sql           # Dataset semilla coherente con oftalmología y glaucoma
│   ├── 03_part1_queries.sql           # 50 Consultas SQL (Básicas, Intermedias, Avanzadas)
│   ├── 04_part2_subqueries.sql        # 50 Subconsultas SQL (Escalares, IN, EXISTS, Correlacionadas)
│   ├── 05_part3_procedures.sql        # 50 Procedimientos Almacenados (CRUD, Control, Transacciones)
│   ├── 06_part4_triggers.sql          # 50 Triggers (Auditoría, Reglas de negocio, Validaciones)
│   ├── 07_part5_functions.sql         # 50 Funciones Almacenadas (Cálculos clínicos, KPIs)
│   └── 08_views_and_events.sql        # Vistas requeridas y Event Scheduler de mantenimiento
│
└── tests/                             # Verificación automatizada
    ├── run_all.sh                     # Script Bash de ejecución desatendida integral
    └── verify_solutions.sql           # Consultas de verificación y aserciones de prueba
```

---

## 4. Decisiones de Modelado y Normalización (4FN)

1. **Aislamiento de Dependencias Multivaluadas (MVDs - 4FN):**
   - Un paciente posee un conjunto de alergias ($P \twoheadrightarrow A$), antecedentes familiares ($P \twoheadrightarrow AF$) y antecedentes personales ($P \twoheadrightarrow AP$). Para evitar el producto cartesiano y anomalías de actualización, se modelaron en tablas independientes: `patient_allergies`, `patient_family_histories` y `patient_antecedents`.
2. **Desacoplamiento Clínico por Ojo (`OD` / `OI`):**
   - La toma de presión intraocular (`intraocular_pressures`), paquimetría (`pachymetry_exams`), gonioscopía (`gonioscopy_exams`), tomografía de coherencia óptica (`oct_exams`) y campo visual (`visual_field_exams`) admiten evaluaciones por ojo individual (`OD` = Ojo Derecho, `OI` = Ojo Izquierdo) o bilateral, con restricciones `CHECK` que validan rangos fisiológicos coherentes (ej. PIO entre 5.0 y 70.0 mmHg, espesor corneal entre 300 y 800 micras).
3. **Mecanismo de Auditoría Inmutable:**
   - Tabla `audit_logs` con columnas `table_name`, `record_id`, `action`, `old_values` (JSON), `new_values` (JSON), `performed_by VARCHAR(100) DEFAULT 'SYSTEM'`, y `changed_at DATETIME DEFAULT CURRENT_TIMESTAMP`.

---

## 5. Estado Actual del Proyecto

- [x] **Fase 1 (Estructura y Git):** Directorio creado, `.gitignore` establecido.
- [x] **Fase 2 (Documentación y Modelos):** 4 documentos generados en `docs/`, 3 diagramas Mermaid en `diagrams/` y el archivo StarUML `oftalmologia_model.mdj` listo y validado.
- [x] **Fase 3A (DDL Schema):** Scripts `00_init_database.sql` y `01_ddl_schema.sql` ejecutados y validados con 0 errores en MySQL port 3307 (25 tablas principales + 4 tablas de backup).
- [x] **Fase 3B (DML Seed Data):** `sql/02_dml_seed_data.sql` con datos representativos y consistentes cargados exitosamente.
- [x] **Fase 4 (Banco de 250 Ejercicios):**
  - [x] `sql/03_part1_queries.sql` (50 consultas según guía, verificadas).
  - [x] `sql/04_part2_subqueries.sql` (50 subconsultas según guía, verificadas).
  - [x] `sql/05_part3_procedures.sql` (50 procedimientos compilados con éxito).
  - [x] `sql/06_part4_triggers.sql` (50 triggers compilados con éxito).
  - [x] `sql/07_part5_functions.sql` (50 funciones compiladas con éxito).
  - [x] `sql/08_views_and_events.sql` (8 Vistas y 2 Eventos en ejecución).
- [x] **Fase 5 (Tests y Verificación):** `tests/run_all.sh` y script de comprobación pasando al 100%.
- [x] **Fase 6 (README.md Maestro y Commit Git):** `README.md` completo y repositorio con commit inicial en `main`.

---

## 6. Directrices Obligatorias para los Agentes

1. **Idioma de Comunicación:** Comunicarse y responder SIEMPRE en **español**, tal como lo solicitó explícitamente el usuario.
2. **Ejecución Totalmente Autónoma (Sin Preguntas Innecesarias):**
   - El usuario ha ordenado explícitamente: *"no me vuelvas a preguntar tu solo ejecuta lo que sea necesario"*.
   - El agente DEBE asumir total autonomía técnica: no formular preguntas triviales ni detenerse a pedir confirmación para tareas que puede deducir o ejecutar por sí mismo.
   - Ejecutar, probar y verificar de inmediato en el entorno local antes de responder.
3. **Sintaxis SQL:**
   - Compatible estrictamente con MySQL 8.0.
   - En procedimientos, triggers y funciones, usar `DELIMITER $$ ... DELIMITER ;`.
   - Limpiar con `DROP PROCEDURE IF EXISTS`, `DROP TRIGGER IF EXISTS`, `DROP FUNCTION IF EXISTS` antes de cada creación.
   - En los procedimientos transaccionales, emplear `DECLARE EXIT HANDLER FOR SQLEXCEPTION` con `ROLLBACK; RESIGNAL;`.
4. **Verificación Directa:**
   - Todo script que se desarrolle debe ser probado inmediatamente en el motor local ejecutando el comando bash sobre el puerto 3307 para comprobar que no existan errores de sintaxis, violaciones de llaves foráneas o errores de delimiter.

