# 1. Planteamiento del Problema y Formulación del Sistema

## 1.1. Título del Proyecto
**Diseño e implementación de una base de datos relacional normalizada hasta 4FN para la gestión de historias clínicas en el área de Oftalmología y Glaucoma.**

**Autor:** Deimer Caro  
**Motor de Base de Datos:** MySQL 8.0  
**Herramientas de Modelado:** StarUML (.mdj), Mermaid ERD  

---

## 1.2. Situación Problema
El área médica de oftalmología y, en particular, la subespecialidad de glaucoma, se caracteriza por el manejo intensivo de datos clínicos longitudinales, altamente estructurados y con estricta dependencia temporal. El glaucoma es una neuropatía óptica progresiva donde la preservación visual depende del monitoreo continuo de variables críticas como:

1. **Presión Intraocular (PIO):** Medida en milímetros de mercurio (mmHg), diferenciada obligatoriamente entre Ojo Derecho (OD) y Ojo Izquierdo (OI), con variaciones diurnas y respuesta a terapias hipotensoras.
2. **Paquimetría Corneal Central (CCT):** Espesor corneal en micrómetros (µm), factor determinante para corregir e interpretar el valor real de la PIO.
3. **Tomografía de Coherencia Óptica (OCT):** Medición del espesor de la capa de fibras nerviosas de la retina (RNFL) y complejo de células ganglionares.
4. **Campimetría Computarizada (Campo Visual):** Índices globales como Desviación Media (MD), Desviación Estándar del Patrón (PSD) y el Índice de Campo Visual (VFI).
5. **Gonioscopía:** Clasificación del ángulo iridocorneal (ej. Clasificación de Shaffer: grados 0 a IV).
6. **Farmacoterapia hipotensora:** Análogos de prostaglandinas, betabloqueantes, inhibidores de anhidrasa carbónica, alfa-agonistas y procedimientos láser/quirúrgicos (trabeculoplastia, trabeculectomía).

### Consecuencias de una gestión de datos no estructurada o desnormalizada
- **Duplicidad e inconsistencia:** Repetición innecesaria de antecedentes y datos demográficos en cada atención.
- **Pérdida de trazabilidad ocular:** Confusión entre mediciones y tratamientos aplicados a OD frente a OI.
- **Anomalías de modificación y eliminación:** Al registrar múltiples diagnósticos o medicamentos en una sola fila desnormalizada (separados por comas o columnas repetitivas `medicamento1`, `medicamento2`), se imposibilitan agregaciones, filtros y auditorías.
- **Inexistencia de control transaccional:** Pérdida de integridad referencial entre la historia clínica, las consultas y los exámenes diagnósticos.

---

## 1.3. Pregunta Problema
¿Cómo diseñar e implementar una base de datos relacional en MySQL 8.0, rigurosamente normalizada hasta la Cuarta Forma Normal (4FN), que permita almacenar, relacionar, consultar y procesar eficientemente la información de historias clínicas oftalmológicas garantizando integridad referencial, consistencia histórica y soporte para consultas y procedimientos clínicos avanzados?

---

## 1.4. Objetivos

### Objetivo General
Diseñar, normalizar e implementar una base de datos relacional en MySQL 8.0 para el área de Oftalmología y Glaucoma, cumpliendo con la Cuarta Forma Normal (4FN), restricciones de integridad y un banco integral de 250 componentes SQL (consultas, subconsultas, procedimientos, triggers y funciones).

### Objetivos Específicos
1. Identificar exhaustivamente las entidades, atributos atómicos y relaciones del dominio clínico oftalmológico.
2. Desarrollar formalmente el proceso de normalización paso a paso desde 0FN hasta 4FN, erradicando dependencias parciales, transitivas y multivaluadas independientes.
3. Construir los modelos conceptual, lógico y físico, generando los diagramas Entidad-Relación nativos en **StarUML** e integrados en **Mermaid**.
4. Implementar el modelo físico en MySQL con restricciones estrictas de integridad (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`, `DEFAULT`).
5. Poblar la base de datos con un conjunto de datos coherente y representativo (más de 20 pacientes, profesionales, consultas y exámenes especializados).
6. Desarrollar e implementar los 250 ejercicios técnicos requeridos:
   - 50 Consultas SQL (básicas, intermedias, avanzadas).
   - 50 Subconsultas SQL (escalares, operadores de conjunto, correlacionadas).
   - 50 Procedimientos almacenados con control transaccional y validaciones de negocio.
   - 50 Triggers para auditoría completa y restricciones de integridad.
   - 50 Funciones almacenadas para cálculo clínico y análisis estadístico.
7. Crear vistas consolidadas, eventos programados y una suite de pruebas automatizada para validar el correcto funcionamiento del sistema.

---

## 1.5. Alcance y Límites del Sistema
- **Incluye:** Modelado relacional completo, scripts DDL/DML, lógica de negocio en servidor (SP, Triggers, Funciones, Vistas, Eventos), auditoría integral, suite de pruebas automatizada, diagramas StarUML y documentación técnica exhaustiva.
- **Excluye:** Desarrollo de interfaces frontend (web, móvil, escritorio) o capas de servicios REST/GraphQL, las cuales consumirán directamente este motor de base de datos.
