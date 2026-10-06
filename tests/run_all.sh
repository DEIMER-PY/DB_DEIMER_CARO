#!/usr/bin/env bash
# ==============================================================================
# PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
# AUTOR: Deimer Caro
# ARCHIVO: tests/run_all.sh
# DESCRIPCIÓN: Script de ejecución integral y automatizada de la suite de base de datos
# ==============================================================================

set -e

# Configuración de Conexión (Sobrescribible por variables de entorno)
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3307}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASS="${MYSQL_PASS:-root2026}"
MYSQL_DB="${MYSQL_DB:-oftalmologia_glaucoma_db}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colores para salida en terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================================================${NC}"
echo -e "${BLUE}  SUITE DE DESPLIEGUE Y PRUEBAS AUTOMATIZADAS - TALLERDB_DEIMER_CARO   ${NC}"
echo -e "${BLUE}========================================================================${NC}"
echo -e "Host: ${MYSQL_HOST}:${MYSQL_PORT} | Usuario: ${MYSQL_USER} | BD: ${MYSQL_DB}"
echo -e "Directorio Base: ${BASE_DIR}"
echo ""

run_sql_file() {
    local step_name="$1"
    local file_path="$2"
    local use_db="$3"

    echo -ne " [EJECUTANDO] ${step_name} (${file_path})... "
    
    local cmd="mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASS}"
    if [ "$use_db" = "true" ]; then
        cmd="${cmd} ${MYSQL_DB}"
    fi

    if ${cmd} < "${BASE_DIR}/${file_path}" > /dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[ERROR]${NC}"
        echo -e "${RED}Falló la ejecución de: ${file_path}${NC}"
        # Re-ejecutar mostrando el error
        ${cmd} < "${BASE_DIR}/${file_path}"
        exit 1
    fi
}

# 1. Inicialización de la Base de Datos
run_sql_file "Paso 1: Inicialización de Base de Datos" "sql/00_init_database.sql" "false"

# 2. Esquema DDL (25 Tablas + Backups)
run_sql_file "Paso 2: Creación de Esquema Físico DDL" "sql/01_ddl_schema.sql" "true"

# 3. Datos Semilla DML
run_sql_file "Paso 3: Carga de Datos Semilla DML" "sql/02_dml_seed_data.sql" "true"

# 4. Parte I: 50 Consultas SQL
run_sql_file "Paso 4: Verificación de 50 Consultas SQL" "sql/03_part1_queries.sql" "true"

# 5. Parte II: 50 Subconsultas SQL
run_sql_file "Paso 5: Verificación de 50 Subconsultas SQL" "sql/04_part2_subqueries.sql" "true"

# 6. Parte III: 50 Procedimientos Almacenados
run_sql_file "Paso 6: Compilación de 50 Procedimientos" "sql/05_part3_procedures.sql" "true"

# 7. Parte IV: 50 Triggers
run_sql_file "Paso 7: Compilación de 50 Triggers" "sql/06_part4_triggers.sql" "true"

# 8. Parte V: 50 Funciones Almacenadas
run_sql_file "Paso 8: Compilación de 50 Funciones" "sql/07_part5_functions.sql" "true"

# 9. Vistas y Eventos
run_sql_file "Paso 9: Creación de Vistas y Eventos" "sql/08_views_and_events.sql" "true"

# 10. Aserciones y Comprobación Integral
echo ""
echo -e "${YELLOW}Ejecutando script de verificación y aserciones finales...${NC}"
mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${MYSQL_USER}" -p"${MYSQL_PASS}" "${MYSQL_DB}" < "${BASE_DIR}/tests/verify_solutions.sql"

echo ""
echo -e "${GREEN}========================================================================${NC}"
echo -e "${GREEN}  DESPLIEGUE Y PRUEBAS COMPLETADAS SATISFACTORIAMENTE AL 100%           ${NC}"
echo -e "${GREEN}========================================================================${NC}"
