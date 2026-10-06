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
