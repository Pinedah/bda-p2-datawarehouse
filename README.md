# BDA-P2-DATAWAREHOUSE

## Data Warehouse - Práctica 2 de Bases de Datos Avanzadas

Este proyecto implementa un **Data Warehouse** utilizando **Python**, en el cual se integran bases de datos obtenidas del **INEGI** y del **SSN**.

Los datos originales fueron extraídos de los siguientes archivos:
- `conjunto_de_datos_iter00CSV20.csv`
- `economia_normalizada.csv`
- `SSNMX_catalogo_19000101_20250213.csv`

Posteriormente, estos datos fueron **procesados y limpiados** en Python con herramientas como `pandas`, `numpy`, entre otras.

### 📂 Datasets Procesados
Tras la limpieza y transformación de los datos, se obtuvieron los siguientes datasets estructurados:
- **poblacion**
- **sismos**
- **economia_municipios**
- **economia_estados**

Estos datasets fueron convertidos a **SQL** utilizando funciones integradas en el notebook y luego insertados en un **Data Warehouse** llamado:

**`DP_DATAWAREHOUSE`**

## 📊 Visualizaciones y Análisis
Las visualizaciones, consultas y gráficas fueron generadas en **Python** utilizando:
- `matplotlib`
- `seaborn`
- `folium` (para visualizaciones en OpenStreetMap)

Las visualizaciones fueron diseñadas siguiendo las especificaciones académicas de la práctica.

## 🚀 Pasos para Ejecutar el Proyecto

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu_usuario/bda-p2-datawarehouse.git
   ```
2. **Descargar los datos desde Google Drive**: [Enlace a Drive](https://drive.google.com/drive/folders/1cA1QMhuDvF5LAtu3wX5zY4jkewegi0oj?usp=sharing)
   - Carpeta `raw_data`
   - Carpeta `raw_data_limpio`
   - Carpeta `SQLs`
   
   Asegúrate de colocarlas al mismo nivel que el archivo `datawarehouse.ipynb`.

3. **Verificar la versión de Python**
   - Versión utilizada en el proyecto: **Python 3.12.3** 

4. **Instalar los requerimientos del proyecto**
   ```bash
   pip install -r requirements.txt
   ```

5. **Ejecutar las celdas del notebook**
   - Abre `datawarehouse.ipynb` en **Jupyter Notebook** o **Jupyter Lab**.
   - Ejecuta las celdas deseadas para realizar las consultas y visualizaciones.

## 📌 Comandos para Importar las Bases de Datos en MySQL
Para cargar los datos en **MySQL** usando **XAMPP**, sigue estos pasos:

1. Abre la terminal de MySQL desde XAMPP.
2. Crea la base de datos:
   ```sql
   CREATE DATABASE P2_DATAWAREHOUSE;
   ```
3. Importa cada archivo SQL usando el siguiente comando:
   ```bash
   mysql -u root -p P2_DATAWAREHOUSE < SQLs/poblacion.sql
   mysql -u root -p P2_DATAWAREHOUSE < SQLs/sismos.sql
   mysql -u root -p P2_DATAWAREHOUSE < SQLs/economia_municipios.sql
   mysql -u root -p P2_DATAWAREHOUSE < SQLs/economia_estados.sql
   ```

   - **Nota:** Reemplaza `root` con tu usuario de MySQL si es diferente.
   - Ingresa tu contraseña cuando se te solicite.

## 📧 Contacto
- **Nombre:** Francisco Pineda Hernández
- **Institución:** Instituto Politécnico Nacional - ESCOM
- **Materia:** Bases de Datos Avanzadas
- **LinkedIn:** [Francisco Pineda](https://www.linkedin.com/in/pinedah/)

Si tienes dudas o sugerencias, no dudes en contactarme. 😊