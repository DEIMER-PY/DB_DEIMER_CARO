#!/usr/bin/env bash
# ==============================================================================
# PROYECTO: Sistema de Gestión de Historias Clínicas (Oftalmología y Glaucoma)
# AUTOR: Deimer Caro
# ARCHIVO: open_staruml.sh
# DESCRIPCIÓN: Script para iniciar StarUML con el modelo y cardinalidades cargadas
# ==============================================================================

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_FILE="${PROJECT_DIR}/diagrams/oftalmologia_model.mdj"

if [ ! -f "${MODEL_FILE}" ]; then
    echo "Error: No se encontró el archivo de modelo en ${MODEL_FILE}"
    exit 1
fi

echo "========================================================================"
echo "  Abriendo StarUML - Modelo Oftalmología & Glaucoma (Deimer Caro)"
echo "========================================================================"
echo "Archivo: ${MODEL_FILE}"
echo "Diagramas incluidos:"
echo "  1. Diagrama Entidad-Relacion (Fisico 4FN) [Con cardinalidades Crow's Foot]"
echo "  2. Modelo Logico Relacional [Estructura relacional y dependencias FK]"
echo "========================================================================"

staruml "${MODEL_FILE}" &
echo "StarUML lanzado en segundo plano con PID: $!"
