@echo off
REM ==============================================================================
REM PROYECTO: Sistema de Gestion de Historias Clinicas (Oftalmologia y Glaucoma)
REM AUTOR: Deimer Caro
REM ARCHIVO: tests/run_all.cmd
REM DESCRIPCION: Lanzador para Windows (doble clic o CMD). Ejecuta run_all.ps1
REM              sin necesidad de cambiar la politica de ejecucion de PowerShell.
REM ==============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_all.ps1" %*
set EXIT_CODE=%ERRORLEVEL%

REM Si se abrio con doble clic, mantener la ventana abierta para ver el resultado
if not defined NO_PAUSE echo %CMDCMDLINE% | find /i "%~0" >nul && pause

exit /b %EXIT_CODE%
