# Sistema de Gestión Integral de Historias Clínicas (Oftalmología y Glaucoma)

**Autor:** Deimer Caro  
**Motor RDBMS:** MySQL 8.0 (InnoDB)  
**Entorno de Ejecución:** Linux, macOS o Windows (Docker `mysql_db` o MySQL local) — Host `127.0.0.1`, Puerto `3307`  
**Base de Datos:** `oftalmologia_glaucoma_db`  
**Especificación Original:** [`tallerexamenbd.md`](file:///home/camper/Documents/DB_DEIMER_CARO/tallerexamenbd.md)  
**Protocolo para Agentes de IA:** [`AGENTS.md`](file:///home/camper/Documents/DB_DEIMER_CARO/AGENTS.md)  

---

## 1. Resumen Ejecutivo y Planteamiento del Problema

El presente proyecto implementa una solución relacional integral para la administración clínica, diagnóstico y seguimiento longitudinal de pacientes en el área de **Oftalmología y Glaucoma**. 

El glaucoma representa una de las principales causas mundiales de ceguera irreversible. El control de esta neuropatía óptica exige el seguimiento riguroso y comparativo de variables biométricas por ojo (`OD` = Ojo Derecho, `OI` = Ojo Izquierdo), tales como la **Presión Intraocular (PIO)** mediante tonometría de aplanación Goldmann, la **Paquimetría Corneal Central (CCT)**, la **Gonioscopía** de ángulo iridocorneal, la **Tomografía de Coherencia Óptica (OCT)** de la capa de fibras nerviosas de la retina (CFNR / RNFL) y la **Campimetría Computarizada (Campo Visual)**.

Para resolver los riesgos de inconsistencia, redundancia y pérdida de trazabilidad, el modelo fue estructurado bajo una estricta **normalización hasta la Cuarta Forma Normal (4FN)**, complementado con un banco exhaustivo de **250 ejercicios resueltos** en SQL (consultas, subconsultas, procedimientos, disparadores y funciones), vistas analíticas, eventos programados y compatibilidad nativa con **StarUML**.

---

## 2. Estructura del Repositorio

```
/home/camper/Documents/DB_DEIMER_CARO/
├── README.md                          # Este archivo: Documentación maestra del proyecto
├── AGENTS.md                          # Guía de contexto, arquitectura y credenciales para agentes
├── tallerexamenbd.md                  # Enunciado y rúbricas completas del taller/examen
├── .gitignore                         # Exclusiones estándar de Git
│
├── diagrams/                          # Modelos visuales y de herramientas UML
│   ├── oftalmologia_model.mdj         # Proyecto nativo para StarUML 5.x
│   ├── conceptual_model.mmd           # Diagrama Conceptual (Mermaid)
│   ├── logical_model.mmd              # Diagrama Lógico Relacional (Mermaid)
│   ├── physical_erd.mmd               # Diagrama Físico DER Completo (Mermaid)
│   ├── modelo_entidad_relacion.html   # Modelo ER interactivo: conceptual, lógico, DER y explorador
│   ├── generador_modelo_er.py         # Script que genera el HTML del modelo ER
│   └── plantilla_modelo_er.html       # Plantilla (estilos, navegación y explorador) del modelo ER
│
├── docs/                              # Documentación técnica paso a paso
│   ├── 01_planteamiento_problema.md   # Justificación clínica, alcance y entidades
│   ├── 02_proceso_normalizacion_4fn.md# Demostración formal de normalización de 0FN a 4FN
│   ├── 03_diccionario_de_datos.md     # Catálogo exhaustivo de tablas, tipos y restricciones
│   └── 04_guia_ejecucion_pruebas.md   # Manual de despliegue y verificación
│
├── sql/                               # Scripts SQL modulares y secuenciales
│   ├── 00_init_database.sql           # CREATE DATABASE utf8mb4 y configuración inicial
│   ├── 01_ddl_schema.sql              # Creación de 25 tablas relacionales, llaves e índices
│   ├── 02_dml_seed_data.sql           # Dataset semilla clínicamente coherente
│   ├── 03_part1_queries.sql           # Parte I: 50 Consultas SQL (Básicas, Intermedias, Avanzadas)
│   ├── 04_part2_subqueries.sql        # Parte II: 50 Subconsultas SQL (Escalares, IN, EXISTS, Correlacionadas)
│   ├── 05_part3_procedures.sql        # Parte III: 50 Procedimientos Almacenados (CRUD y Transaccionales)
│   ├── 06_part4_triggers.sql          # Parte IV: 50 Triggers (BEFORE/AFTER INSERT, UPDATE, DELETE)
│   ├── 07_part5_functions.sql         # Parte V: 50 Funciones Almacenadas (KPIs y clasificaciones)
│   └── 08_views_and_events.sql        # 8 Vistas clínicas y 2 Eventos automáticos
│
├── .gitattributes                     # Fuerza LF en .sh/.sql y CRLF en .ps1/.cmd
│
└── tests/                             # Suite de pruebas automatizadas
    ├── run_all.sh                     # Lanzador Linux / macOS (y Git Bash / WSL)
    ├── run_all.ps1                    # Lanzador Windows (PowerShell)
    ├── run_all.cmd                    # Atajo Windows (CMD o doble clic) que ejecuta run_all.ps1
    └── verify_solutions.sql           # Consultas de verificación y aserciones de integridad
```

---

## 3. Modelo Entidad-Relación (DER)

A continuación se presenta el diagrama físico de la base de datos relacional:

```mermaid
erDiagram
    DEPARTMENTS ||--o{ CITIES : "ubica"
    CITIES ||--o{ PATIENTS : "reside"
    DOCUMENT_TYPES ||--o{ PATIENTS : "identifica"
    DOCUMENT_TYPES ||--o{ HEALTHCARE_PROFESSIONALS : "identifica"
    SPECIALTIES ||--o{ HEALTHCARE_PROFESSIONALS : "posee"

    PATIENTS ||--|| CLINICAL_HISTORIES : "1:1 tiene"
    PATIENTS ||--o{ PATIENT_ALLERGIES : "1:N (4FN)"
    PATIENTS ||--o{ PATIENT_FAMILY_HISTORIES : "1:N (4FN)"
    PATIENTS ||--o{ PATIENT_ANTECEDENTS : "1:N (4FN)"
    PATIENTS ||--o{ GLAUCOMA_RECORDS : "1:1 registra"

    CLINICAL_HISTORIES ||--o{ MEDICAL_VISITS : "1:N contiene"
    CLINICAL_HISTORIES ||--o{ CLINICAL_DOCUMENTS : "1:N adjunta"

    HEALTHCARE_PROFESSIONALS ||--o{ MEDICAL_VISITS : "1:N atiende"

    MEDICAL_VISITS ||--o{ VISIT_DIAGNOSES : "1:N genera"
    DIAGNOSES ||--o{ VISIT_DIAGNOSES : "1:N asocia"

    MEDICAL_VISITS ||--o{ INTRAOCULAR_PRESSURES : "1:N mide"
    MEDICAL_VISITS ||--o{ PACHYMETRY_EXAMS : "1:N realiza"
    MEDICAL_VISITS ||--o{ GONIOSCOPY_EXAMS : "1:N evalua"
    MEDICAL_VISITS ||--o{ OCT_EXAMS : "1:N registra"
    MEDICAL_VISITS ||--o{ VISUAL_FIELD_EXAMS : "1:N cuantifica"

    MEDICAL_VISITS ||--o{ TREATMENTS : "1:N prescribe"
    MEDICATIONS ||--o{ TREATMENTS : "1:N suministra"

    MEDICAL_VISITS ||--o{ PROCEDURES : "1:N ejecuta"

    GLAUCOMA_RECORDS ||--o{ GLAUCOMA_CONTROLS : "1:N monitorea"
    MEDICAL_VISITS ||--o{ GLAUCOMA_CONTROLS : "1:N asocia"

    AUDIT_LOGS {
        bigint id PK
        varchar table_name
        bigint record_id
        enum action
        json old_values
        json new_values
        varchar performed_by
        datetime changed_at
    }
```

---

## 4. Normalización Rigurosa hasta 4FN

El proceso formal se encuentra detallado en [`docs/02_proceso_normalizacion_4fn.md`](file:///home/camper/Documents/DB_DEIMER_CARO/docs/02_proceso_normalizacion_4fn.md):

1. **Primera Forma Normal (1FN):** Eliminación de listas de texto libre y atributos multivaluados en una sola columna. Cada columna almacena valores atómicos.
2. **Segunda Forma Normal (2FN):** Toda tabla con clave primaria compuesta tiene sus atributos no clave dependiendo de la totalidad de la clave y no de una parte (ej. desacoplamiento de diagnósticos y tratamientos respecto a la consulta médica).
3. **Tercera Forma Normal (3FN):** Eliminación de dependencias transitivas. Los catálogos de ciudades (`cities`), departamentos (`departments`), especialidades (`specialties`), tipos de documento (`document_types`), medicamentos (`medications`) y diagnósticos (`diagnoses`) se aislaron de las tablas operativas.
4. **Forma Normal de Boyce-Codd (BCNF):** Toda determinante de una dependencia funcional es una superclave.
5. **Cuarta Forma Normal (4FN):** Eliminación de **Dependencias Multivaluadas Independientes (MVD)**:
   - En el dominio clínico, un paciente tiene un conjunto de *Alergias* ($P \twoheadrightarrow A$), un conjunto de *Antecedentes Familiares* ($P \twoheadrightarrow AF$) y antecedentes personales patológicos ($P \twoheadrightarrow AP$).
   - Dejar estos atributos en una misma tabla generaba anomalías de producto cartesiano y redundancia combinatoria.
   - **Solución 4FN:** Se crearon las tablas aisladas `patient_allergies`, `patient_family_histories` y `patient_antecedents`.

---

## 5. Modelado Visual: StarUML y draw.io

### 5.1. StarUML (DER Físico y Modelo Lógico con Cardinalidad)
El proyecto incluye un modelo nativo completo en formato StarUML 6.x (`diagrams/oftalmologia_model.mdj`), con **todas las 25 entidades relacionales**, atributos tipificados, restricciones PK/FK y **líneas de relación con cardinalidad explícita (notación Crow's Foot)**:

- **Archivo del Modelo:** [`diagrams/oftalmologia_model.mdj`](file:///home/camper/Documents/DB_DEIMER_CARO/diagrams/oftalmologia_model.mdj)
- **Diagramas incluidos:**
  1. **Diagrama Entidad-Relación (Físico 4FN):** Contiene las 25 tablas con todas las columnas, índices, llaves foráneas y cardinalidad completa (`1:1`, `1:N`, `0..*`, `0..1`).
  2. **Modelo Lógico Relacional:** Diagrama estructural con las entidades lógicas y dependencias relacionales directas.
- **Formas de abrir en StarUML:**
  ```bash
  # Opción A: Mediante el script lanzador directo
  bash open_staruml.sh

  # Opción B: Ejecutando el comando directo
  staruml diagrams/oftalmologia_model.mdj &
  ```

### 5.2. Modelo Entidad-Relación interactivo (HTML)
Una sola página con las 25 tablas (+4 de respaldo), sus 214 atributos y las 25 llaves foráneas, organizada en 7 módulos. Las pestañas siguen el orden del diseño:
1. **Mapa general:** cómo se conectan los módulos y tabla con las 25 relaciones (cardinalidad y `ON DELETE`).
2. **Modelo conceptual (Chen):** entidades, entidades débiles, rombos de relación y cardinalidades `1 · N · M · 0..1`.
3. **Modelo lógico relacional:** cada tabla en notación relacional con tipos, nulidad, claves, defaults y restricciones `CHECK`/`UNIQUE`/`FK`.
4. **Diagrama entidad-relación (pata de gallo):** cada línea une la columna FK con el `id` que referencia.
5. **Explorador de tablas y atributos:** búsqueda en tablas o atributos y filtros por módulo, tipo de entidad (fuerte, débil, catálogo, asociativa N:M, auditoría, respaldo), clave (PK, FK, UK), tipo de dato y nulidad; vista por tabla o lista de atributos ordenable.

**Navegación cruzada:** al hacer clic en una entidad de cualquier diagrama, en una tabla del mapa general o en «Explorar →» del modelo lógico, se abre su ficha en el explorador; desde cada ficha se vuelve al modelo conceptual, lógico o DER de su módulo.

- **Archivo:** [`diagrams/modelo_entidad_relacion.html`](diagrams/modelo_entidad_relacion.html) (se abre en cualquier navegador)
- **Versión publicada:** https://claude.ai/artifact/H6ik4gABMoRhG7E4DRqsis
- **Regenerarlo** (si cambia el DDL, actualizar primero las tablas `T` y las FK `FKS` del script):
  ```bash
  python diagrams/generador_modelo_er.py diagrams/modelo_entidad_relacion.html diagrams/plantilla_modelo_er.html
  ```

### 5.3. Modelo Conceptual en draw.io
El diagrama conceptual del dominio clínico también se encuentra disponible en formato nativo de draw.io / diagrams.net:
- **Archivo draw.io:** [`diagrams/modelo_conceptual.drawio`](file:///home/camper/Documents/DB_DEIMER_CARO/diagrams/modelo_conceptual.drawio)
- **Archivo Mermaid:** [`diagrams/conceptual_model.mmd`](file:///home/camper/Documents/DB_DEIMER_CARO/diagrams/conceptual_model.mmd)
- Compatible para abrir en [diagrams.net](https://app.diagrams.net/) o mediante la extensión Draw.io en VS Code.

---

## 6. Banco de 250 Ejercicios MySQL Implementados

El proyecto da cumplimiento íntegro y verificable a las 5 partes solicitadas:

| Componente | Archivo SQL | Ejercicios | Descripción |
| :--- | :--- | :---: | :--- |
| **Parte I: Consultas SQL** | [`sql/03_part1_queries.sql`](file:///home/camper/Documents/DB_DEIMER_CARO/sql/03_part1_queries.sql) | **50** | Consultas Básicas (1-20), Intermedias con `JOIN` (21-40) y Avanzadas con agregaciones, `GROUP BY`, `HAVING` y funciones ventana (41-50). |
| **Parte II: Subconsultas** | [`sql/04_part2_subqueries.sql`](file:///home/camper/Documents/DB_DEIMER_CARO/sql/04_part2_subqueries.sql) | **50** | Subconsultas escalares (1-10), operadores `IN` (11-20), cláusulas `NOT IN` / `NOT EXISTS` (21-30), subconsultas correlacionadas (31-40) y avanzadas (41-50). |
| **Parte III: Procedimientos** | [`sql/05_part3_procedures.sql`](file:///home/camper/Documents/DB_DEIMER_CARO/sql/05_part3_procedures.sql) | **50** | Procedimientos de consulta y catálogo (1-10), inserción (11-20), actualización (21-30), validaciones con `SIGNAL SQLSTATE` (31-40) y flujos transaccionales con `START TRANSACTION`, `COMMIT` y `ROLLBACK` (41-50). |
| **Parte IV: Triggers** | [`sql/06_part4_triggers.sql`](file:///home/camper/Documents/DB_DEIMER_CARO/sql/06_part4_triggers.sql) | **50** | Disparadores `BEFORE INSERT` (1-10), `AFTER INSERT` con auditoría (11-20), `BEFORE UPDATE` para integridad (21-30), `AFTER UPDATE` con alertas clínicas (31-40) y `BEFORE/AFTER DELETE` con tablas de backup (41-50). |
| **Parte V: Funciones** | [`sql/07_part5_functions.sql`](file:///home/camper/Documents/DB_DEIMER_CARO/sql/07_part5_functions.sql) | **50** | Funciones escalares y formato (1-10), métricas clínicas (11-20), lógica diagnóstica y completitud (21-30), cálculos estadísticos temporales (31-40) y fichas de resumen textual (41-50). |
| **Vistas y Event Scheduler** | [`sql/08_views_and_events.sql`](file:///home/camper/Documents/DB_DEIMER_CARO/sql/08_views_and_events.sql) | **10** | 8 vistas para analítica clínica y 2 eventos programados de mantenimiento preventivo y control de tratamientos. |

---

## 7. Despliegue y Ejecución Automatizada

El proyecto incluye scripts de arranque desatendidos que reconstruyen la base de datos, compilan todos los objetos, ejecutan los 250 ejercicios y comprueban las aserciones de calidad. Hay un lanzador para cada sistema operativo:

| Sistema operativo | Archivo | Comando (desde la raíz del proyecto) |
| :--- | :--- | :--- |
| **Linux** | `tests/run_all.sh` | `bash tests/run_all.sh` |
| **macOS** | `tests/run_all.sh` | `bash tests/run_all.sh` |
| **Windows (PowerShell)** | `tests/run_all.ps1` | `powershell -ExecutionPolicy Bypass -File tests\run_all.ps1` |
| **Windows (CMD / doble clic)** | `tests/run_all.cmd` | `tests\run_all.cmd` |

> Linux y macOS comparten el mismo script porque ambos usan bash. En Windows también funciona `bash tests/run_all.sh` desde Git Bash o WSL.

### Requisitos
Se necesita **uno** de estos dos programas:
- **Docker** con el contenedor MySQL en ejecución (por defecto `mysql_db`). No hace falta instalar MySQL en el equipo: los scripts ejecutan el cliente `mysql` **dentro del contenedor** con `docker exec`.
- **Cliente `mysql`** instalado en el equipo, con acceso a `127.0.0.1:3307`.

Con el modo `auto` (por defecto), si el cliente `mysql` está en el PATH se usa ese; si no, se usa Docker.

### Parámetros de conexión configurables
Todos los lanzadores leen las mismas variables de entorno:

| Variable | Valor por defecto | Descripción |
| :--- | :--- | :--- |
| `MYSQL_MODE` | `auto` | `auto`, `local` (cliente mysql del equipo) o `docker` (cliente dentro del contenedor) |
| `MYSQL_CONTAINER` | `mysql_db` | Nombre del contenedor (solo en modo `docker`) |
| `MYSQL_HOST` | `127.0.0.1` | Host (solo en modo `local`) |
| `MYSQL_PORT` | `3307` | Puerto (solo en modo `local`) |
| `MYSQL_USER` | `root` | Usuario |
| `MYSQL_PASS` | `root2026` | Contraseña |
| `MYSQL_DB` | `oftalmologia_glaucoma_db` | Base de datos destino |

```bash
# Linux / macOS
MYSQL_MODE=docker MYSQL_CONTAINER=mysql_db bash tests/run_all.sh
```
```powershell
# Windows (PowerShell)
$env:MYSQL_MODE = "docker"; $env:MYSQL_CONTAINER = "mysql_db"
powershell -ExecutionPolicy Bypass -File tests\run_all.ps1
```

### Error `$'\r': command not found` al ejecutar el script de bash
Este error aparece cuando `run_all.sh` tiene finales de línea de Windows (CRLF). Git en Windows (`core.autocrlf=true`) los convierte al hacer checkout. El archivo [`.gitattributes`](.gitattributes) evita el problema porque obliga a guardar los `.sh` con LF. Si el clon es anterior a ese archivo, vuelva a extraer el script una sola vez (no afecta otros archivos):
```bash
rm tests/run_all.sh && git checkout -- tests/run_all.sh
```
Alternativa: en VS Code abra el archivo, haga clic en `CRLF` en la barra inferior, elija `LF` y guarde.

### Resultados de la Verificación:
```
Tablas Relacionales Creadas:        29
Vistas Creadas:                      8
Procedimientos Almacenados Creados: 50
Funciones Almacenadas Creadas:      50
Triggers Creados:                   50
Eventos Programados:                 2
Estado de Ejecución:                100% EXITOSO
```

---

## 8. Licencia y Créditos

Proyecto desarrollado por **Deimer Caro** para el Taller Evaluativo de Bases de Datos Relacionales (Oftalmología y Glaucoma). Código abierto para propósitos académicos y de sustentación técnica.
