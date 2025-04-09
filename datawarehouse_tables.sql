CREATE DATABASE IF NOT EXISTS datawarehouse;
USE datawarehouse;

CREATE TABLE IF NOT EXISTS dim_economia (
    id_economia INT PRIMARY KEY,
    nombre_entidad VARCHAR(100),
    entidad DOUBLE,
    produccion_bruta_total DOUBLE,
    insumos_utilizados DOUBLE,
    consumo_intermedio DOUBLE,
    valor_agregado DOUBLE,
    formacion_capital DOUBLE,
    activos_fijos_adquiridos DOUBLE
);

CREATE TABLE IF NOT EXISTS dim_sismos (
    id_sismo INT PRIMARY KEY,
    magnitud DOUBLE,
    latitud DOUBLE,
    longitud DOUBLE,
    profundidad DOUBLE,
    referencia_de_localizacion VARCHAR(100),
    estado VARCHAR(100),
    nombre_estado VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    hora_utc TIME,
    fecha DATE,
    anio INT,
    mes INT,
    dia INT,
    trimestre INT
);

CREATE TABLE IF NOT EXISTS dim_zonas (
    id_zonas INT PRIMARY KEY,
    entidad INT,
    nom_ent VARCHAR(100),
    pobtot BIGINT,
    pobfem BIGINT,
    pobmas BIGINT
);

CREATE TABLE fact_impacto_sismos_imputed (
    id_sismo INT,
    id_zonas INT,
    id_economia INT,
    id_tiempo INT,
    poblacion_afectada BIGINT,
    impacto_economico DOUBLE,
    determinante_de_riesgo DOUBLE,
    riesgo_proporcional DOUBLE,
    indice_zscore DOUBLE,
    FOREIGN KEY (id_sismo) REFERENCES dim_sismos(id_sismo),
    FOREIGN KEY (id_zonas) REFERENCES dim_zonas(id_zonas),
    FOREIGN KEY (id_economia) REFERENCES dim_economia(id_economia),
    FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo)
);

-- IMPORTANTE ------------------------------------------------------------------------------
-- ANTES DE CARGAR LOS DATOS DE FACT_IMPACTO_SISMOS_IMPUTED, 
-- SE DEBE CARGAR LOS DATOS EN LAS TABLAS 
-- DIM_ECONOMIA, DIM_SISMOS, DIM_TIEMPO Y DIM_ZONAS
-- PARA QUE LAS CLAVES FORANEAS FUNCIONEN CORRECTAMENTE.
-- :) ------------------------------------------------------------------------------