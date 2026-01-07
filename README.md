# 🏥 Sistema de Gestión de Datos Clínicos (SQL + Python)

## 📋 Descripción del Proyecto
Este proyecto simula el flujo de datos de una red de salud. Se diseñó un pipeline de Ingeniería de Datos que integra **Python** para la orquestación y **PostgreSQL** (corriendo sobre Linux) como motor de base de datos persistente.

El objetivo es demostrar cómo transformar datos transaccionales (Citas, Médicos, Pacientes) en información estratégica para la toma de decisiones (KPIs).

## 🛠️ Stack Tecnológico
* **Lenguaje:** Python 3.10
* **Base de Datos:** PostgreSQL 16 (Local en Linux Pop!_OS)
* **Orquestación & ETL:** SQLAlchemy & Pandas
* **Análisis:** SQL Avanzado (Window Functions, Aggregations)

## 🚀 Características Principales
1.  **Modelado de Datos (DDL):** Diseño de un esquema relacional con integridad referencial (Primary/Foreign Keys).
2.  **Ingesta de Datos (ETL):** Script de Python que conecta al servidor PostgreSQL local para poblar las tablas automáticamente.
3.  **Seguridad:** Gestión de roles y permisos (Grants) para el usuario de aplicación en el esquema `public`.
4.  **Business Intelligence:**
    * Cálculo de ingresos por médico.
    * Historial de visitas por paciente usando `ROW_NUMBER()` (Window Functions).

## 📂 Estructura del Repositorio
* `main_analysis.ipynb`: Notebook principal con la ejecución del pipeline y visualización de resultados.
* `queries.sql`: Scripts SQL puros utilizados para la creación de tablas y consultas de negocio.
* `requirements.txt`: Dependencias necesarias para ejecutar el entorno.

## 📊 Ejemplo de Consulta (Window Function)
Para analizar la recurrencia de pacientes sin mezclar historiales, se implementó la siguiente lógica:

```sql
SELECT 
    P.nombre,
    C.fecha,
    ROW_NUMBER() OVER(PARTITION BY P.id_paciente ORDER BY C.fecha) as Nro_Visita
FROM Citas C ...
```

**Nota de Seguridad:** *Las credenciales de base de datos están hardcodeadas únicamente para propósitos demostrativos en entorno local. En un entorno de producción, utilizaría variables de entorno (`os.environ`) o un gestor de secretos como AWS Secrets Manager.*
