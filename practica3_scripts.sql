-- 1:
SELECT 
    z.NOM_ENT,
    max(poblacion_afectada) AS poblacion_afectada_total,
    COUNT(DISTINCT f.ID_sismo) AS cantidad_sismos
FROM fact_impacto_sismos_imputed f
INNER JOIN dim_sismos s
    ON f.ID_sismo = s.ID_sismo
INNER JOIN dim_zonas z
    ON f.ID_zonas = z.ID_zonas
WHERE s.Magnitud > 5.0
GROUP BY z.NOM_ENT
ORDER BY poblacion_afectada_total DESC
LIMIT 10;

-- 2:
-- Consulta para calcular el impacto económico de sismos con magnitud > 6.0
SELECT 
    e.nombre_entidad,
    SUM(impacto_economico) AS impacto_economico,
    AVG(s.Magnitud) AS magnitud_promedio,
    MAX(e.produccion_bruta_total) AS produccion_bruta_total,
    MAX(e.valor_agregado) AS valor_agregado,
    MAX(e.consumo_intermedio) AS consumo_intermedio,
    SUM(impacto_economico) / COUNT(DISTINCT f.ID_sismo) AS impacto_promedio_por_sismo,
    (SUM(impacto_economico) / MAX(e.produccion_bruta_total)) * 100 AS porcentaje_impacto
FROM fact_impacto_sismos_imputed f
INNER JOIN dim_sismos s
    ON f.ID_sismo = s.ID_sismo
INNER JOIN dim_economia e
    ON f.ID_economia = e.ID_economia
WHERE s.Magnitud > 6.0
GROUP BY e.nombre_entidad
ORDER BY impacto_economico DESC
LIMIT 10;

-- 3: 
SELECT 
    Nombre_Estado AS Estado,
    COUNT(*) AS Frecuencia,
    AVG(Magnitud) AS Magnitud_Promedio,
    (COUNT(*) * AVG(Magnitud)) / 100 AS Indice_Riesgo
FROM dim_sismos
JOIN dim_tiempo ON dim_sismos.ID_sismo = dim_tiempo.ID_tiempo
WHERE dim_tiempo.fecha >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR)
GROUP BY Nombre_Estado
ORDER BY Indice_Riesgo DESC
LIMIT 10;

-- 4:
WITH economia_balance AS (
    SELECT 
        nombre_entidad,
        produccion_bruta_total,
        consumo_intermedio,
        (consumo_intermedio - produccion_bruta_total) AS diferencia_consumo_produccion,
        (consumo_intermedio / produccion_bruta_total) * 100 AS porcentaje_consumo,
        CASE 
            WHEN consumo_intermedio > produccion_bruta_total THEN 'Deficitario'
            ELSE 'Superavitario'
        END AS balance_economico
    FROM dim_economia
),

actividad_sismica AS (
    SELECT 
        Nombre_Estado AS nombre_entidad,
        COUNT(*) AS cantidad_sismos,
        AVG(Magnitud) AS magnitud_promedio,
        MAX(Magnitud) AS magnitud_maxima
    FROM dim_sismos
    GROUP BY Nombre_Estado
)

SELECT 
    e.nombre_entidad,
    e.produccion_bruta_total,
    e.consumo_intermedio,
    e.diferencia_consumo_produccion,
    e.porcentaje_consumo,
    s.cantidad_sismos,
    s.magnitud_promedio,
    s.magnitud_maxima
FROM economia_balance e
LEFT JOIN actividad_sismica s ON e.nombre_entidad = s.nombre_entidad
WHERE e.balance_economico = 'Deficitario'
ORDER BY e.porcentaje_consumo DESC;

-- 5:
WITH actividad_sismica AS (
    SELECT 
        Nombre_Estado,
        AVG(Magnitud) AS magnitud_promedio
    FROM dim_sismos
    GROUP BY Nombre_Estado
),

economia_sismos AS (
    SELECT 
        e.nombre_entidad,
        (e.produccion_bruta_total - e.consumo_intermedio) AS excedente_produccion,
        s.magnitud_promedio
    FROM dim_economia e
    INNER JOIN actividad_sismica s 
        ON e.nombre_entidad = s.Nombre_Estado
)

SELECT 
    nombre_entidad,
    excedente_produccion,
    magnitud_promedio
FROM economia_sismos
ORDER BY excedente_produccion DESC;

