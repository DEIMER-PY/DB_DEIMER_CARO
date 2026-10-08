# ==============================================================================
# PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
# AUTOR: Deimer Caro
# ARCHIVO: tests/run_all.ps1
# DESCRIPCIÓN: Script de ejecución integral y automatizada de la suite de base de datos
# SISTEMAS:    Windows (PowerShell 5.1+ / PowerShell 7+)
#              Equivalente de tests/run_all.sh para Linux y macOS
#
# USO:
#   powershell -ExecutionPolicy Bypass -File tests\run_all.ps1
#   tests\run_all.cmd                       (atajo, también con doble clic)
#
# MODO DE CONEXIÓN (variable de entorno MYSQL_MODE):
#   auto   -> usa el cliente 'mysql' local si existe; si no, usa Docker (por defecto)
#   local  -> fuerza el cliente 'mysql' instalado en el equipo (host:puerto)
#   docker -> ejecuta el cliente 'mysql' dentro del contenedor MYSQL_CONTAINER
# ==============================================================================

$ErrorActionPreference = 'Stop'

function Get-EnvOrDefault([string]$Name, [string]$Default) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrEmpty($value)) { return $Default }
    return $value
}

# Configuración de Conexión (Sobrescribible por variables de entorno)
$MysqlHost      = Get-EnvOrDefault 'MYSQL_HOST' '127.0.0.1'
$MysqlPort      = Get-EnvOrDefault 'MYSQL_PORT' '3307'
$MysqlUser      = Get-EnvOrDefault 'MYSQL_USER' 'root'
$MysqlPass      = Get-EnvOrDefault 'MYSQL_PASS' 'root2026'
$MysqlDb        = Get-EnvOrDefault 'MYSQL_DB' 'oftalmologia_glaucoma_db'
$MysqlMode      = Get-EnvOrDefault 'MYSQL_MODE' 'auto'
$MysqlContainer = Get-EnvOrDefault 'MYSQL_CONTAINER' 'mysql_db'

$BaseDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# Resolución del modo de conexión
if ($MysqlMode -eq 'auto') {
    if (Get-Command mysql -ErrorAction SilentlyContinue) {
        $MysqlMode = 'local'
    } elseif (Get-Command docker -ErrorAction SilentlyContinue) {
        $MysqlMode = 'docker'
    } else {
        Write-Host "No se encontró el cliente 'mysql' ni 'docker' en el PATH." -ForegroundColor Red
        Write-Host 'Instale uno de los dos o configure $env:MYSQL_MODE manualmente.'
        exit 1
    }
}

if ($MysqlMode -eq 'docker') {
    cmd /c "docker exec $MysqlContainer true >nul 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "El contenedor '$MysqlContainer' no está en ejecución." -ForegroundColor Red
        Write-Host "Inícielo con: docker start $MysqlContainer  (o docker compose up -d)"
        exit 1
    }
    $Target = "contenedor $MysqlContainer"
    $MysqlCmd = "docker exec -i -e MYSQL_PWD=$MysqlPass $MysqlContainer mysql --default-character-set=utf8mb4 -u $MysqlUser"
} else {
    $Target = "${MysqlHost}:${MysqlPort}"
    $env:MYSQL_PWD = $MysqlPass
    $MysqlCmd = "mysql --default-character-set=utf8mb4 -h $MysqlHost -P $MysqlPort -u $MysqlUser"
}

# Ejecuta el cliente mysql redirigiendo el archivo SQL byte a byte con cmd.exe
# (evita que PowerShell 5.1 re-codifique los acentos al usar tuberías).
function Invoke-MysqlFile([string]$FilePath, [string]$Database, [switch]$ShowOutput) {
    $fullPath = Join-Path $BaseDir $FilePath
    $line = "$MysqlCmd $Database < `"$fullPath`""
    if ($ShowOutput) {
        cmd /c "chcp 65001 >nul & $line 2>&1" | Out-Host
        return @{ ExitCode = $LASTEXITCODE; Output = $null }
    }
    $output = cmd /c "$line 2>&1"
    return @{ ExitCode = $LASTEXITCODE; Output = $output }
}

function Invoke-SqlStep([string]$StepName, [string]$FilePath, [bool]$UseDb) {
    Write-Host " [EJECUTANDO] $StepName ($FilePath)... " -NoNewline
    $db = ''
    if ($UseDb) { $db = $MysqlDb }
    $result = Invoke-MysqlFile $FilePath $db
    if ($result.ExitCode -eq 0) {
        Write-Host '[OK]' -ForegroundColor Green
    } else {
        Write-Host '[ERROR]' -ForegroundColor Red
        Write-Host "Falló la ejecución de: $FilePath" -ForegroundColor Red
        $result.Output | ForEach-Object { Write-Host $_ }
        exit 1
    }
}

Write-Host '========================================================================' -ForegroundColor Blue
Write-Host '  SUITE DE DESPLIEGUE Y PRUEBAS AUTOMATIZADAS - TALLERDB_DEIMER_CARO   ' -ForegroundColor Blue
Write-Host '========================================================================' -ForegroundColor Blue
Write-Host "Modo: $MysqlMode | Destino: $Target | Usuario: $MysqlUser | BD: $MysqlDb"
Write-Host "Directorio Base: $BaseDir"
Write-Host ''

# 1. Inicialización de la Base de Datos
Invoke-SqlStep 'Paso 1: Inicialización de Base de Datos'       'sql\00_init_database.sql'    $false
# 2. Esquema DDL (25 Tablas + Backups)
Invoke-SqlStep 'Paso 2: Creación de Esquema Físico DDL'         'sql\01_ddl_schema.sql'       $true
# 3. Datos Semilla DML
Invoke-SqlStep 'Paso 3: Carga de Datos Semilla DML'             'sql\02_dml_seed_data.sql'    $true
# 4. Parte I: 50 Consultas SQL
Invoke-SqlStep 'Paso 4: Verificación de 50 Consultas SQL'       'sql\03_part1_queries.sql'    $true
# 5. Parte II: 50 Subconsultas SQL
Invoke-SqlStep 'Paso 5: Verificación de 50 Subconsultas SQL'    'sql\04_part2_subqueries.sql' $true
# 6. Parte III: 50 Procedimientos Almacenados
Invoke-SqlStep 'Paso 6: Compilación de 50 Procedimientos'       'sql\05_part3_procedures.sql' $true
# 7. Parte IV: 50 Triggers
Invoke-SqlStep 'Paso 7: Compilación de 50 Triggers'             'sql\06_part4_triggers.sql'   $true
# 8. Parte V: 50 Funciones Almacenadas
Invoke-SqlStep 'Paso 8: Compilación de 50 Funciones'            'sql\07_part5_functions.sql'  $true
# 9. Vistas y Eventos
Invoke-SqlStep 'Paso 9: Creación de Vistas y Eventos'           'sql\08_views_and_events.sql' $true

# 10. Aserciones y Comprobación Integral
Write-Host ''
Write-Host 'Ejecutando script de verificación y aserciones finales...' -ForegroundColor Yellow
$verify = Invoke-MysqlFile 'tests\verify_solutions.sql' $MysqlDb -ShowOutput
if ($verify.ExitCode -ne 0) {
    Write-Host 'Falló la verificación final (tests\verify_solutions.sql).' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '========================================================================' -ForegroundColor Green
Write-Host '  DESPLIEGUE Y PRUEBAS COMPLETADAS SATISFACTORIAMENTE AL 100%           ' -ForegroundColor Green
Write-Host '========================================================================' -ForegroundColor Green
