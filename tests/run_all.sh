#!/usr/bin/env bash
# ==============================================================================
# PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
# AUTOR: Deimer Caro
# ARCHIVO: tests/run_all.sh
# DESCRIPCIÓN: Script de ejecución integral y automatizada de la suite de base de datos
# SISTEMAS:    Linux, macOS, Windows (Git Bash / WSL)
#              En Windows nativo use tests/run_all.ps1 o tests/run_all.cmd
#
# MODO DE CONEXIÓN (MYSQL_MODE):
#   auto   -> usa el cliente 'mysql' local si existe; si no, usa Docker (por defecto)
#   local  -> fuerza el cliente 'mysql' instalado en el equipo (host:puerto)
#   docker -> ejecuta el cliente 'mysql' dentro del contenedor MYSQL_CONTAINER
# ==============================================================================

set -e

# Configuración de Conexión (Sobrescribible por variables de entorno)
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3307}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASS="${MYSQL_PASS:-root2026}"
MYSQL_DB="${MYSQL_DB:-oftalmologia_glaucoma_db}"
MYSQL_MODE="${MYSQL_MODE:-auto}"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-mysql_db}"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colores para salida en terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Resolución del modo de conexión
if [ "$MYSQL_MODE" = "auto" ]; then
    if command -v mysql > /dev/null 2>&1; then
        MYSQL_MODE="local"
    elif command -v docker > /dev/null 2>&1; then
        MYSQL_MODE="docker"
    else
        echo -e "${RED}No se encontró el cliente 'mysql' ni 'docker' en el PATH.${NC}"
        echo "Instale uno de los dos o configure MYSQL_MODE manualmente."
        exit 1
    fi
fi

if [ "$MYSQL_MODE" = "docker" ]; then
    if ! docker exec "${MYSQL_CONTAINER}" true > /dev/null 2>&1; then
        echo -e "${RED}El contenedor '${MYSQL_CONTAINER}' no está en ejecución.${NC}"
        echo "Inícielo con: docker start ${MYSQL_CONTAINER}  (o docker compose up -d)"
        exit 1
    fi
    TARGET="contenedor ${MYSQL_CONTAINER}"
else
    TARGET="${MYSQL_HOST}:${MYSQL_PORT}"
fi

# Ejecuta el cliente mysql (local o dentro del contenedor) leyendo SQL de stdin.
# Uso: mysql_cli [base_de_datos]
mysql_cli() {
    if [ "$MYSQL_MODE" = "docker" ]; then
        MSYS_NO_PATHCONV=1 docker exec -i -e MYSQL_PWD="${MYSQL_PASS}" "${MYSQL_CONTAINER}" \
            mysql --default-character-set=utf8mb4 -u "${MYSQL_USER}" "$@"
    else
        MYSQL_PWD="${MYSQL_PASS}" mysql --default-character-set=utf8mb4 \
            -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${MYSQL_USER}" "$@"
    fi
}

echo -e "${BLUE}========================================================================${NC}"
echo -e "${BLUE}  SUITE DE DESPLIEGUE Y PRUEBAS AUTOMATIZADAS - TALLERDB_DEIMER_CARO   ${NC}"
echo -e "${BLUE}========================================================================${NC}"
echo -e "Modo: ${MYSQL_MODE} | Destino: ${TARGET} | Usuario: ${MYSQL_USER} | BD: ${MYSQL_DB}"
echo -e "Directorio Base: ${BASE_DIR}"
echo ""

run_sql_file() {
    local step_name="$1"
    local file_path="$2"
    local use_db="$3"
    local db_arg=""

    if [ "$use_db" = "true" ]; then
        db_arg="${MYSQL_DB}"
    fi

    echo -ne " [EJECUTANDO] ${step_name} (${file_path})... "

    local output
    if output=$(mysql_cli ${db_arg} < "${BASE_DIR}/${file_path}" 2>&1); then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[ERROR]${NC}"
        echo -e "${RED}Falló la ejecución de: ${file_path}${NC}"
        echo "${output}"
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
mysql_cli "${MYSQL_DB}" < "${BASE_DIR}/tests/verify_solutions.sql"

echo ""
echo -e "${GREEN}========================================================================${NC}"
echo -e "${GREEN}  DESPLIEGUE Y PRUEBAS COMPLETADAS SATISFACTORIAMENTE AL 100%           ${NC}"
echo -e "${GREEN}========================================================================${NC}"
