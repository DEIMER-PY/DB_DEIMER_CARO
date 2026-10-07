# 4. Guía Maestra de Pruebas y Despliegue del Sistema

Esta guía técnica proporciona el procedimiento detallado paso a paso para:
1. **Desplegar y probar la base de datos en el contenedor Docker (`mysqlcontainer`) y phpMyAdmin**.
2. **Visualizar e inspeccionar el modelo en StarUML** con cardinalidades completas (Crow's Foot), DER físico y modelo lógico.
3. **Cargar y construir el Modelo Conceptual en draw.io (diagrams.net)** paso a paso.

---

## 4.1. Pruebas con el Contenedor Docker (`mysqlcontainer`) y phpMyAdmin

El proyecto fue diseñado para ejecutarse en el contenedor MySQL + phpMyAdmin compartido para el entorno de desarrollo:

- **Ubicación del contenedor en el equipo:** `/home/camper/Documents/mysqlcontainer/`
- **Motor:** MySQL 8.4 Server en el contenedor `mysql_db` (puerto host: **`3307`**)
- **Interfaz Web:** phpMyAdmin en el contenedor `phpmyadmin` (puerto host: **`8081`**)
- **Credenciales:**
  - **Host:** `127.0.0.1` (o `localhost`)
  - **Puerto MySQL:** `3307`
  - **Usuario Administrador:** `root`
  - **Contraseña Root:** `root2026`
  - **Usuario Aplicación:** `bkseducate`
  - **Contraseña Aplicación:** `bkseducate2026`
  - **Base de Datos:** `oftalmologia_glaucoma_db`

### Paso 1: Iniciar el contenedor con Docker Compose
Abra una terminal y ejecute:

```bash
cd /home/camper/Documents/mysqlcontainer
docker compose up -d mysql_db phpmyadmin
```

> **Verificación:** Ejecute `docker ps` o `docker compose ps` y confirme que:
> - `mysql_db` se encuentra en estado `healthy` en el puerto `0.0.0.0:3307->3306/tcp`.
> - `phpmyadmin` se encuentra en estado `Up` en el puerto `0.0.0.0:8081->80/tcp`.

---

### Paso 2: Desplegar la Base de Datos en el Contenedor
Desde la carpeta del proyecto `DB_DEIMER_CARO`, ejecute la suite de inicialización automatizada apuntando al puerto `3307`:

```bash
cd /home/camper/Documents/DB_DEIMER_CARO
bash tests/run_all.sh
```

El script ejecutará automáticamente en el contenedor:
1. `00_init_database.sql`: Crea la base de datos `oftalmologia_glaucoma_db` con codificación `utf8mb4`.
2. `01_ddl_schema.sql`: Crea las 25 tablas relacionales en 4FN, 4 tablas de backup, llaves primarias, foráneas e índices.
3. `02_dml_seed_data.sql`: Carga el dataset clínico de prueba con pacientes, antecedentes, visitas, exámenes paraclínicos, tratamientos y controles.
4. `03_part1_queries.sql`: Ejecuta las 50 consultas SQL.
5. `04_part2_subqueries.sql`: Ejecuta las 50 subconsultas SQL.
6. `05_part3_procedures.sql`: Compila los 50 Procedimientos Almacenados.
7. `06_part4_triggers.sql`: Compila los 50 Triggers (disparadores de auditoría y validación).
8. `07_part5_functions.sql`: Compila las 50 Funciones Almacenadas clínicas y estadísticas.
9. `08_views_and_events.sql`: Compila las 8 Vistas analíticas y los 2 Eventos programados.
10. `verify_solutions.sql`: Verifica la integridad del catálogo y comprueba el 100% de éxito.

---

### Paso 3: Acceder y Realizar Pruebas en phpMyAdmin
1. Abra su navegador web (Google Chrome, Firefox, etc.) e ingrese a:
   ```
   http://localhost:8081
   ```
2. Ingrese las siguientes credenciales en la pantalla de inicio de sesión:
   - **Servidor:** `mysql_db` (configurado por defecto)
   - **Usuario:** `root`
   - **Contraseña:** `root2026`
3. En el panel izquierdo de phpMyAdmin, haga clic en la base de datos **`oftalmologia_glaucoma_db`**.

#### Pruebas interactivas recomendadas en phpMyAdmin:

##### A. Inspeccionar Tablas y Datos
- Haga clic en cualquier tabla (por ejemplo, `patients`, `intraocular_pressures`, `medical_visits`).
- En la pestaña **Examinar (Browse)** podrá visualizar las filas con datos clínicos reales.
- En la pestaña **Estructura (Structure)** podrá verificar los tipos de datos, llaves primarias (`PK`), foráneas (`FK`) y restricciones.

##### B. Visualizar el Diagrama de Relaciones en phpMyAdmin
- Seleccione la base de datos `oftalmologia_glaucoma_db`.
- En el menú superior horizontal, haga clic en **Más (More)** -> **Diseñador (Designer)**.
- Verá el mapa gráfico relacional generado automáticamente por phpMyAdmin a partir de las llaves foráneas de InnoDB.

##### C. Probar Procedimientos Almacenados (Pestaña "Rutinas")
- En el menú superior, haga clic en la pestaña **Rutinas (Routines)**.
- Seleccione cualquier procedimiento, por ejemplo `sp_obtener_historia_completa`, haga clic en **Ejecutar (Execute)**, ingrese como parámetro `p_paciente_id = 1` y presione **Continuar**.
- Podrá ver la historia clínica del paciente con sus antecedentes familiares y personales en 4FN.

##### D. Probar Triggers y Auditoría en Tiempo Real
- En la pestaña **SQL** de phpMyAdmin, ejecute una actualización sobre un tratamiento activo:
  ```sql
  UPDATE treatments 
  SET is_active = FALSE, end_date = CURRENT_DATE() 
  WHERE id = 1;
  ```
- Luego, consulte la tabla de auditoría:
  ```sql
  SELECT * FROM audit_logs WHERE table_name = 'treatments' ORDER BY id DESC LIMIT 5;
  ```
- Observará el registro inmediato insertado automáticamente por el trigger con los valores en formato JSON.

---

### Paso 4: Detener o Reiniciar el Contenedor
- Para detener el contenedor preservando los datos:
  ```bash
  cd /home/camper/Documents/mysqlcontainer
  docker compose stop
  ```
- Para volver a levantarlo en cualquier momento:
  ```bash
  docker compose start
  ```
- Para reiniciar desde cero eliminando volúmenes temporales:
  ```bash
  docker compose down -v
  docker compose up -d mysql_db phpmyadmin
  ```

---

## 4.2. Inspección y Manejo de StarUML

El proyecto incluye el archivo nativo [`diagrams/oftalmologia_model.mdj`](file:///home/camper/Documents/DB_DEIMER_CARO/diagrams/oftalmologia_model.mdj) completamente modelado.

### Paso 1: Abrir el Modelo en StarUML
Abra una terminal y ejecute cualquiera de las dos alternativas:

```bash
# Alternativa A: Mediante el script lanzador
cd /home/camper/Documents/DB_DEIMER_CARO
bash open_staruml.sh

# Alternativa B: Comando directo
staruml /home/camper/Documents/DB_DEIMER_CARO/diagrams/oftalmologia_model.mdj &
```

### Paso 2: Explorar los Diagramas Incluidos
En el panel derecho superior (**Model Explorer**):
1. Expanda el proyecto `DB_DEIMER_CARO`.
2. Expanda el paquete de datos `OftalmologiaGlaucomaModel`.
3. Encontrará los dos diagramas principales:
   - **`Diagrama Entidad-Relacion (Fisico 4FN)`**:
     - Diagrama físico completo con **las 25 tablas**, tipos de datos SQL, llaves primarias (`PK`), llaves foráneas (`FK`), columnas únicas (`UK`) y cardinalidad en los extremos de las relaciones.
   - **`Modelo Logico Relacional`**:
     - Diagrama enfocado en las entidades lógicas del dominio y su interconexión relacional.

### Paso 3: Verificación y Modificación de Cardinalidades
En StarUML, las cardinalidades están modeladas mediante relaciones `ERDRelationship`:
1. Haga clic sobre cualquier línea de relación en el lienzo (por ejemplo, entre `medical_visits` e `intraocular_pressures`).
2. En el panel inferior izquierdo (**Properties**):
   - **`end1.cardinality`**: Muestra la cardinalidad del origen (`1` o `0..1`).
   - **`end2.cardinality`**: Muestra la cardinalidad del destino (`0..*`, `1..*`, `1` o `0..1`).
3. Puede modificar cualquiera de las cardinalidades haciendo clic en el menú desplegable del campo `cardinality`.
4. El estilo de terminación (Crow's Foot: pata de gallo para `Many`, barra simple para `One`, círculo para `Zero`) se ajustará automáticamente en pantalla.

### Paso 4: Exportar los Diagramas
Si desea exportar imágenes desde la interfaz de StarUML:
- Vaya al menú superior: **File** -> **Export Diagram As** -> **PNG...** (o **SVG...** / **PDF...**).
- También puede exportarlos por línea de comandos sin abrir la interfaz:
  ```bash
  staruml image diagrams/oftalmologia_model.mdj -o diagrams/erd_exported.png
  ```

---

## 4.3. Paso a Paso para el Modelo Conceptual en draw.io

El modelo conceptual del sistema clínico puede visualizarse y editarse en draw.io de tres maneras diferentes:

### Opción 1: Abrir el archivo `.drawio` Preconfigurado
El repositorio contiene el archivo XML nativo listo para usar:
- Archivo: [`diagrams/modelo_conceptual.drawio`](file:///home/camper/Documents/DB_DEIMER_CARO/diagrams/modelo_conceptual.drawio)

#### Pasos:
1. Abra su navegador e ingrese a [https://app.diagrams.net/](https://app.diagrams.net/).
2. Seleccione **"Abrir diagrama existente" (Open Existing Diagram)**.
3. Navegue y seleccione el archivo: `/home/camper/Documents/DB_DEIMER_CARO/diagrams/modelo_conceptual.drawio`.
4. El diagrama se cargará de inmediato con:
   - Nodos categorizados por color (Azul: Paciente e Historia, Verde: Consultas, Naranja: Exámenes Oftalmológicos, Morado: Glaucoma, Rojo: Tratamientos, Gris: Catálogos).
   - Relaciones con cardinalidades explícitas (`1:1`, `1:N`) y verbos clínicos.

---

### Opción 2: Importar desde Código Mermaid en draw.io
draw.io permite generar diagramas automáticamente a partir de código Mermaid:

1. Abra [https://app.diagrams.net/](https://app.diagrams.net/) y cree un diagrama en blanco.
2. En el menú superior de draw.io, haga clic en:
   **Disposición (Arrange)** -> **Insertar (Insert)** -> **Avanzado (Advanced)** -> **Mermaid**.
3. Copie y pegue el contenido del archivo [`diagrams/conceptual_model.mmd`](file:///home/camper/Documents/DB_DEIMER_CARO/diagrams/conceptual_model.mmd):
   ```mermaid
   flowchart TD
       PACIENTE["PACIENTE\n(Datos Personales, Contacto)"]
       HISTORIA["HISTORIA CLÍNICA\n(Expediente Único)"]
       PROFESIONAL["PROFESIONAL DE SALUD\n(Especialistas, Oftalmólogos)"]
       ESPECIALIDAD["ESPECIALIDAD\n(Glaucoma, Oftalmología General)"]
       
       CONSULTA["CONSULTA MÉDICA\n(Evaluación, Plan, Cierre)"]
       DIAGNOSTICO["DIAGNÓSTICO\n(CIE-10, Tipos de Glaucoma)"]
       
       EXAMEN_OFTALMOLOGICO["EXÁMENES OFTALMOLÓGICOS\n(Paraclínicos Especializados)"]
       PIO["PRESIÓN INTRAOCULAR\n(Tonometría OD / OI)"]
       PAQUIMETRIA["PAQUIMETRÍA CORNEAL\n(Espesor CCT)"]
       GONIOSCOPIA["GONIOSCOPÍA\n(Ángulo Iridocorneal)"]
       OCT["TOMOGRAFÍA OCT\n(RNFL, Células Ganglionares)"]
       CAMPO_VISUAL["CAMPO VISUAL\n(Campimetría MD, PSD, VFI)"]
       
       TRATAMIENTO["TRATAMIENTO FARMACOLÓGICO\n(Prescripciones Activas)"]
       MEDICAMENTO["MEDICAMENTO\n(Hipotensores Oculares)"]
       PROCEDIMIENTO["PROCEDIMIENTOS Y CIRUGÍAS\n(Láser SLT, Trabeculectomía)"]
       
       REGISTRO_GLAUCOMA["REGISTRO DE GLAUCOMA\n(Presión Objetivo, Estadio)"]
       CONTROL_GLAUCOMA["CONTROLES DE GLAUCOMA\n(Evolución, Adherencia)"]
       
       PACIENTE -->|"1 : 1 tiene"| HISTORIA
       PACIENTE -->|"1 : 1 posee"| REGISTRO_GLAUCOMA
       ESPECIALIDAD -->|"1 : N agrupa"| PROFESIONAL
       PROFESIONAL -->|"1 : N atiende"| CONSULTA
       HISTORIA -->|"1 : N registra"| CONSULTA
       
       CONSULTA -->|"1 : N asigna"| DIAGNOSTICO
       CONSULTA -->|"1 : N incluye"| EXAMEN_OFTALMOLOGICO
       
       EXAMEN_OFTALMOLOGICO --> PIO
       EXAMEN_OFTALMOLOGICO --> PAQUIMETRIA
       EXAMEN_OFTALMOLOGICO --> GONIOSCOPIA
       EXAMEN_OFTALMOLOGICO --> OCT
       EXAMEN_OFTALMOLOGICO --> CAMPO_VISUAL
       
       CONSULTA -->|"1 : N prescribe"| TRATAMIENTO
       MEDICAMENTO -->|"1 : N suministra"| TRATAMIENTO
       CONSULTA -->|"1 : N realiza"| PROCEDIMIENTO
       
       REGISTRO_GLAUCOMA -->|"1 : N monitorea"| CONTROL_GLAUCOMA
       CONSULTA -->|"1 : 1 asocia"| CONTROL_GLAUCOMA
   ```
4. Haga clic en el botón azul **Insertar (Insert)**. draw.io renderizará todos los nodos y conectores de forma instantánea.

---

### Opción 3: Construcción Manual Paso a Paso desde Cero en draw.io
Si debe sustentar o recrear el diagrama conceptual en vivo:

1. **Habilitar librerías de formas:**
   - En el panel lateral izquierdo, haga clic en **+ Más formas (+ More Shapes)**.
   - Active la casilla **Entidad-Relación (Entity Relation)** y **General**. Haga clic en **Aplicar**.

2. **Dibujar las Entidades Conceptuales:**
   - Arrastre rectángulos de esquinas redondeadas (`Rounded Rectangle`) para cada entidad.
   - Aplique la codificación por colores para comunicar la arquitectura:
     - **Azul Claro (`#DAE8FC`):** Entidades demográficas (`PACIENTE`, `HISTORIA CLÍNICA`, `PROFESIONAL DE LA SALUD`).
     - **Verde Claro (`#D5E8D4`):** Proceso clínico operativo (`CONSULTA MÉDICA`, `DIAGNÓSTICOS`).
     - **Naranja Claro (`#FFE6CC`):** Batería de exámenes oftalmológicos (`PIO`, `PAQUIMETRÍA`, `GONIOSCOPÍA`, `OCT`, `CAMPO VISUAL`).
     - **Púrpura Claro (`#E1D5E7`):** Gestión especializada de glaucoma (`REGISTRO DE GLAUCOMA`, `CONTROLES DE GLAUCOMA`).
     - **Rojo/Salmón Claro (`#F8CECC`):** Terapéutica y cirugía (`TRATAMIENTOS`, `MEDICAMENTOS`, `PROCEDIMIENTOS`).

3. **Conectar y Establecer Cardinalidades:**
   - Pase el cursor sobre el borde de una entidad hasta que aparezca una flecha azul.
   - Arrastre la flecha hacia la entidad de destino.
   - En el panel derecho de propiedades de la línea:
     - Cambie el estilo de línea a **Ortogonal (Orthogonal)**.
     - En el punto de inicio y finalización, seleccione las terminaciones según la cardinalidad:
       - `1:1` -> Terminación simple o flecha con etiqueta `1:1`.
       - `1:N` -> Terminación pata de gallo (Crow's Foot) o flecha con etiqueta `1:N`.
   - Haga doble clic sobre la línea para escribir el verbo relacional (ej: `prescribe`, `monitorea`, `mide`).

4. **Exportar el resultado:**
   - Vaya a **Archivo (File)** -> **Exportar como (Export as)** -> **PNG / PDF / SVG**.
