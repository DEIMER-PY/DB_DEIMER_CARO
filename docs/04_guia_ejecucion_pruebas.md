# 4. Guía de Ejecución y Pruebas del Sistema

Esta guía describe el paso a paso para desplegar la base de datos `oftalmologia_glaucoma_db`, cargar el dataset de prueba, compilar las rutinas lógicas (SP, Triggers, Funciones, Vistas, Eventos), ejecutar el banco de 250 ejercicios y verificar los resultados de manera automatizada.

---

## 4.1. Requisitos Previos
1. **Sistema Operativo:** Linux (Ubuntu 22.04 LTS o superior).
2. **Motor de Base de Datos:** MySQL Server 8.0 (activo y escuchando en el puerto 3306).
3. **Credenciales de Acceso:** Usuario `root` (contraseña `root2026`) o el usuario administrador local.
4. **Herramientas Adicionales:**
   - Git para versionamiento.
   - StarUML (`/usr/bin/staruml`) para inspección gráfica de modelos `.mdj`.
   - Bash para la ejecución del runner automático `tests/run_all.sh`.

---

## 4.2. Estructura de Scripts SQL
Los scripts deben ejecutarse en estricto orden de dependencias referenciales:

```
sql/
├── 00_init_database.sql       -> Crea la BD con charset utf8mb4 y collation adecuada
├── 01_ddl_schema.sql          -> Define las 25 tablas con PK, FK, UNIQUE, CHECK
├── 02_dml_seed_data.sql       -> Carga datos maestros, pacientes, visitas y paraclínicos
├── 03_part1_queries.sql       -> Ejecuta las 50 consultas SQL
├── 04_part2_subqueries.sql    -> Ejecuta las 50 subconsultas SQL
├── 05_part3_procedures.sql    -> Compila los 50 procedimientos almacenados
├── 06_part4_triggers.sql      -> Compila los 50 disparadores (Triggers)
├── 07_part5_functions.sql     -> Compila las 50 funciones almacenadas
└── 08_views_and_events.sql    -> Crea vistas maestras y activa el Event Scheduler
```

---

## 4.3. Despliegue Manual Paso a Paso

Si se desea ejecutar cada script manualmente desde la terminal:

```bash
cd /home/camper/Documentos/TALLERDB_DEIMER_CARO

# 1. Crear base de datos
mysql -u root -proot2026 < sql/00_init_database.sql

# 2. Crear tablas y restricciones DDL
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/01_ddl_schema.sql

# 3. Poblar datos semilla DML
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/02_dml_seed_data.sql

# 4. Compilar Procedimientos Almacenados (50 SP)
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/05_part3_procedures.sql

# 5. Compilar Funciones Almacenadas (50 Funciones)
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/07_part5_functions.sql

# 6. Compilar Triggers (50 Triggers)
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/06_part4_triggers.sql

# 7. Crear Vistas y Eventos
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/08_views_and_events.sql

# 8. Ejecutar Consultas y Subconsultas
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/03_part1_queries.sql
mysql -u root -proot2026 oftalmologia_glaucoma_db < sql/04_part2_subqueries.sql
```

---

## 4.4. Ejecución Automatizada en un Solo Paso
Para agilizar la verificación y garantizar que no existan errores, se incluye el script de prueba desatendida:

```bash
cd /home/camper/Documentos/TALLERDB_DEIMER_CARO
bash tests/run_all.sh
```

El script ejecutará las validaciones, reportará el estado de cada componente en color verde/rojo y confirmará:
- Integridad de claves foráneas.
- Inserción correcta de 20+ pacientes, 5+ médicos y cientos de registros clínicos.
- Existencia de 50 procedimientos, 50 triggers, 50 funciones y 50 consultas.
- Validación del registro en la tabla `audit_logs`.

---

## 4.5. Apertura de Modelos en StarUML
Para visualizar el diagrama entidad-relación y modelo conceptual/lógico en StarUML:

```bash
staruml /home/camper/Documentos/TALLERDB_DEIMER_CARO/diagrams/oftalmologia_model.mdj &
```

Esto abrirá la interfaz de StarUML con todas las entidades, columnas y cardinalidades estructuradas.
