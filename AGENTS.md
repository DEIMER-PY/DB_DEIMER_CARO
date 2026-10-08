# AGENTS.md — Protocolo y Contexto de Proyecto para Agentes de IA

Este documento contiene la especificación técnica completa, el estado de avance, las convenciones de desarrollo y las instrucciones operativas del proyecto **TALLERDB_DEIMER_CARO**. Ha sido diseñado para permitir la migración fluida e inmediata entre agentes de inteligencia artificial (AGY, Gemini, Claude, GPT, etc.) sin pérdida de contexto ni divergencia en las decisiones arquitectónicas.

---

## 1. Identificación y Objetivos del Proyecto

- **Nombre del Proyecto:** Sistema de Gestión Integral de Historias Clínicas (Oftalmología y Glaucoma)
- **Autor / Titular:** Deimer Caro
- **Ubicación en el Filesystem:** raíz del repositorio `DB_DEIMER_CARO` (Windows: `C:\DB_DEIMER_CARO`; originalmente `/home/camper/Documents/DB_DEIMER_CARO` en Linux)
- **Guía de Requerimientos y Rúbricas:** [`tallerexamenbd.md`](tallerexamenbd.md)
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
  - StarUML: Windows (`C:\Program Files\StarUML\StarUML.exe`, abrir con File → Open), macOS (`open -a StarUML …`) o Linux (`/usr/bin/staruml`). Su API local (puerto `58321`) exporta imágenes de los diagramas abiertos.
  - Archivo de modelo nativo: `diagrams/oftalmologia_model.mdj`

---

## 3. Arquitectura del Repositorio de Archivos

```
DB_DEIMER_CARO/
├── README.md                          # Este documento
├── AGENTS.md                          # Contexto, decisiones y estado para agentes de IA
├── tallerexamenbd.md                  # Enunciado del taller y documento de entrega con los 250 ejercicios
├── .gitattributes                     # LF en .sh/.sql y CRLF en .ps1/.cmd
├── .gitignore
│
├── sql/                               # Scripts en orden de ejecución
│   ├── 00_init_database.sql           # Base de datos utf8mb4 y event_scheduler
│   ├── 01_ddl_schema.sql              # 25 tablas, 4 de respaldo, llaves, CHECK e índices
│   ├── 02_dml_seed_data.sql           # Datos clínicos de prueba
│   ├── 03_part1_queries.sql           # Parte I: 50 consultas
│   ├── 04_part2_subqueries.sql        # Parte II: 50 subconsultas
│   ├── 05_part3_procedures.sql        # Parte III: 50 procedimientos
│   ├── 06_part4_triggers.sql          # Parte IV: 50 triggers
│   ├── 07_part5_functions.sql         # Parte V: 50 funciones
│   └── 08_views_and_events.sql        # 8 vistas y 2 eventos
│
├── diagrams/
│   ├── modelo_entidad_relacion.html   # Modelo ER interactivo (versión local del artefacto)
│   ├── plantilla_modelo_er.html       # Estilos, navegación y explorador de la página
│   ├── generador_modelo_er.py         # Fuente única de tablas y llaves; genera el HTML
│   ├── oftalmologia_model.mdj         # Modelo lógico StarUML (29 entidades, 8 diagramas)
│   ├── generador_staruml.py           # Genera el .mdj
│   ├── physical_erd.mmd               # DER físico completo en Mermaid
│   ├── generador_mermaid.py           # Genera physical_erd.mmd
│   ├── logical_model.mmd              # Modelo lógico en Mermaid
│   ├── conceptual_model.mmd           # Modelo conceptual en Mermaid
│   ├── modelo_conceptual.drawio       # Modelo conceptual en draw.io
│   └── exportaciones_staruml/         # Los 8 diagramas de StarUML en PNG y SVG
│
├── docs/
│   ├── 01_planteamiento_problema.md   # Problema, objetivos y alcance
│   ├── 02_proceso_normalizacion_4fn.md# Normalización de 0FN a 4FN
│   ├── 03_diccionario_de_datos.md     # Diccionario de las 29 tablas
│   ├── 04_guia_ejecucion_pruebas.md   # Guía de despliegue, phpMyAdmin, StarUML y draw.io
│   ├── 05_ruta_de_aprendizaje.md      # Ruta de aprendizaje de los temas del proyecto
│   └── img/                           # Capturas del modelo ER interactivo
│
├── scripts/
│   ├── build_tallerexamenbd.py        # Inserta los SQL en tallerexamenbd.md
│   └── verify_tallerexamenbd.py       # Comprueba que tallerexamenbd.md tenga los 250 ejercicios
│
└── tests/
    ├── run_all.sh                     # Despliegue y pruebas: Linux, macOS, Git Bash, WSL
    ├── run_all.ps1                    # Despliegue y pruebas: Windows PowerShell
    ├── run_all.cmd                    # Atajo para Windows (CMD o doble clic)
    ├── verify_solutions.sql           # Aserciones finales sobre la base
    ├── validar_modelo_staruml.py      # Compara el .mdj con la base
    └── validar_consistencia.py        # Compara todo el repositorio con la base
```

> `diagrams/generador_modelo_er.py` es la **fuente única** de tablas (`T`) y llaves (`FKS`): de ella salen el HTML, el `.mdj` y `physical_erd.mmd`. La base desplegada es la fuente de verdad que usan los validadores.

---

## 4. Decisiones de Modelado y Normalización (4FN)

1. **Aislamiento de Dependencias Multivaluadas (MVDs - 4FN):**
   - Un paciente posee un conjunto de alergias ($P \twoheadrightarrow A$), antecedentes familiares ($P \twoheadrightarrow AF$) y antecedentes personales ($P \twoheadrightarrow AP$). Para evitar el producto cartesiano y anomalías de actualización, se modelaron en tablas independientes: `patient_allergies`, `patient_family_histories` y `patient_antecedents`.
2. **Desacoplamiento Clínico por Ojo (`OD` / `OI`):**
   - La toma de presión intraocular (`intraocular_pressures`), paquimetría (`pachymetry_exams`), gonioscopía (`gonioscopy_exams`), tomografía de coherencia óptica (`oct_exams`) y campo visual (`visual_field_exams`) registran cada medición por ojo individual (`eye ENUM('OD','OI')`: `OD` = Ojo Derecho, `OI` = Ojo Izquierdo); solo `treatments` y `procedures` admiten además `AMBOS`. Las restricciones `CHECK` validan rangos: PIO `pressure > 0 AND <= 80` mmHg, espesor corneal `corneal_thickness > 0 AND <= 1000` µm, RNFL entre 0 y 300 µm, relación copa/disco entre 0 y 1, VFI entre 0 y 100 % y PIO objetivo `> 0 AND <= 50` mmHg.
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
- [x] **Fase 7 (Arranque multiplataforma):** lanzadores `run_all.sh` (Linux/macOS), `run_all.ps1` y `run_all.cmd` (Windows) con modo `auto|local|docker` (por defecto usa `docker exec` sobre el contenedor `mysql_db` si no hay cliente `mysql` local). `.gitattributes` fuerza LF en `.sh`/`.sql` y CRLF en `.ps1`/`.cmd`.
- [x] **Fase 8 (Modelo ER interactivo):** `diagrams/modelo_entidad_relacion.html` (mapa de módulos, Chen, lógico relacional y DER pata de gallo; 25 tablas + 4 de respaldo, 25 FK) generado por `diagrams/generador_modelo_er.py` con `diagrams/plantilla_modelo_er.html`. Si cambia el DDL, actualizar `T` y `FKS` en el generador y regenerar. Publicado en https://claude.ai/artifact/H6ik4gABMoRhG7E4DRqsis
- [x] **Fase 9 (Explorador fusionado):** el explorador de tablas, entidades y atributos es la 5.ª pestaña de `diagrams/modelo_entidad_relacion.html` (filtros por módulo, tipo de entidad, clave, tipo de dato y nulidad; clic en una entidad de los diagramas abre su ficha). Su JS/CSS vive en `diagrams/plantilla_modelo_er.html` (prefijo `xp-`) y sus datos los genera `explorer_json()` en `generador_modelo_er.py`. No existe página aparte.
- [x] **Fase 10 (Modelo lógico StarUML):** `diagrams/oftalmologia_model.mdj` regenerado por `diagrams/generador_staruml.py` (reutiliza `T`, `FKS`, `DER_LAYOUT` de `generador_modelo_er.py`): 29 ERDEntity, 214 ERDColumn con tipo/longitud/PK/FK(referenceTo)/UNIQUE/NULL, 25 ERDRelationship (1:0..* y 1:0..1) y 8 diagramas. Verificado abriéndolo en StarUML y exportando cada diagrama con su API local (puerto 58321). Validación repetible contra la base real: `python tests/validar_modelo_staruml.py` (entidades, columnas, claves, FK, cardinalidades y conexión de cada línea de los diagramas). El MCP `staruml-mcp-server` solo importa Mermaid (no admite `DECIMAL(5,2)` ni `referenceTo`), por eso se genera el .mdj nativo.
- [x] **Fase 11 (Consistencia global):** `python tests/validar_consistencia.py` compara con la base real (fuente de verdad) el DDL, la copia del DDL en `tallerexamenbd.md`, las referencias a columnas de los scripts 02–08 y `verify_solutions.sql`, el diccionario de datos, `physical_erd.mmd` (ahora generado por `diagrams/generador_mermaid.py`), `logical_model.mmd`, el DER del README, los modelos conceptuales (`.mmd` y `.drawio`), el modelo ER HTML, el `.mdj` y las cifras citadas en los textos. Estado: 0 errores. Las exportaciones de StarUML (8 diagramas en PNG y SVG) están en `diagrams/exportaciones_staruml/` y el validador revisa cada SVG contra su diagrama del `.mdj` y la base; también valida el HTML del modelo ER y, si se le pasa la ruta de la copia descargada, el artefacto publicado; los SVG antiguos (`erd_clean.svg`, `erd_exported.svg`) se retiraron porque eran del modelo incompleto. **Tras cambiar el DDL: actualizar `T`/`FKS` en `generador_modelo_er.py`, regenerar HTML, `.mdj` y `.mmd`, y volver a ejecutar el validador.**
- [x] **Fase 12 (README, ruta de aprendizaje y limpieza):** README reestructurado (tecnologías, arquitectura, modelo, instalación y pruebas por sistema operativo, enlace al artefacto e imágenes en `docs/img/`), ruta de aprendizaje en `docs/05_ruta_de_aprendizaje.md`, eliminados `diagrams/erd_exported.png` (duplicado de `exportaciones_staruml/0_modelo_logico_completo.png`) y `open_staruml.sh` (lanzador solo para Linux con ruta fija). Pruebas: Windows (PowerShell/CMD y Git Bash), Linux (contenedor `mysql:8.4`, bash 5.1) y bash 3.2 (versión de macOS) pasan los 9 pasos; validadores en 0 errores.

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

