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


