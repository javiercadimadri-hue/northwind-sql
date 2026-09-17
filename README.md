# Práctica de Modelado y Consultas SQL - Northwind

**Autor:** Javier Abadia Alfaro
**Entorno de desarrollo:**
* Servidor: PostgreSQL 18
* Cliente: pgAdmin 4
* Base de Datos: Northwind (UTF-8)

---

## 1. Descripción del Proyecto
Este repositorio contiene la resolución práctica sobre la base de datos relacional Northwind, desplegada sobre PostgreSQL 18. Se han ejecutado consultas de extracción, filtrado, agregación y análisis de datos respetando las restricciones de integridad y la codificación UTF-8.

---

## 2. Instrucciones de Instalación y Carga

Para reproducir este entorno de trabajo desde cero:

1. **Creación de la Base de Datos:**
   Conéctate a PostgreSQL mediante pgAdmin o psql y crea la base de datos forzando la codificación UTF-8:
   ```sql
   CREATE DATABASE northwind
       WITH ENCODING = 'UTF8'
            TEMPLATE = template0;