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


-- 6:
WITH datos_completos AS (
  SELECT
    f.ID_sismo,
    f.ID_zonas,
    f.poblacion_afectada,
    z.POBTOT,
    s.Magnitud,
    
    FLOOR(z.POBTOT / 3.0) AS viviendas_estimadas_registro,

    -- Porcentaje de afectación basado en magnitud cuadrática (ajustable)
    POWER(s.Magnitud / 10.0, 2) * 0.5 AS porcentaje_afectacion,

    -- Clasificación por rango
    CASE
      WHEN s.Magnitud < 4.0 THEN 'Leve'
      WHEN s.Magnitud < 5.0 THEN 'Moderado'
      WHEN s.Magnitud < 6.0 THEN 'Fuerte'
      WHEN s.Magnitud < 7.0 THEN 'Muy fuerte'
      ELSE 'Severo'
    END AS rango_magnitud

  FROM fact_impacto_sismos_imputed f
  JOIN dim_zonas z ON f.ID_zonas = z.ID_zonas
  JOIN dim_sismos s ON f.ID_sismo = s.ID_sismo
),
con_viviendas_afectadas AS (
  SELECT 
    *,
    (viviendas_estimadas_registro * porcentaje_afectacion) AS viviendas_afectadas_estimadas
  FROM datos_completos
),
agrupado AS (
  SELECT 
    rango_magnitud,
    SUM(viviendas_afectadas_estimadas) AS total_afectadas,
    SUM(viviendas_estimadas_registro) AS total_estimadas
  FROM con_viviendas_afectadas
  GROUP BY rango_magnitud
)
SELECT 
  rango_magnitud,
  ROUND((total_afectadas / NULLIF(total_estimadas, 0)) * 100, 2) AS porcentaje_afectadas
FROM agrupado
ORDER BY 
  CASE rango_magnitud
    WHEN 'Leve' THEN 1
    WHEN 'Moderado' THEN 2
    WHEN 'Fuerte' THEN 3
    WHEN 'Muy fuerte' THEN 4
    WHEN 'Severo' THEN 5
  END;


-- 7:
WITH clasificacion_estados AS (
  SELECT 'Ciudad de Mexico' AS estado, 'Urbano' AS tipo_zona UNION ALL
  SELECT 'Nuevo Leon', 'Urbano' UNION ALL
  SELECT 'Jalisco', 'Urbano' UNION ALL
  SELECT 'Mexico', 'Urbano' UNION ALL
  SELECT 'Baja California', 'Urbano' UNION ALL
  SELECT 'Coahuila', 'Urbano' UNION ALL
  SELECT 'Colima', 'Urbano' UNION ALL
  SELECT 'Aguascalientes', 'Urbano' UNION ALL
  SELECT 'Quintana Roo', 'Urbano' UNION ALL

  SELECT 'Oaxaca', 'Rural' UNION ALL
  SELECT 'Chiapas', 'Rural' UNION ALL
  SELECT 'Guerrero', 'Rural' UNION ALL
  SELECT 'Hidalgo', 'Rural' UNION ALL
  SELECT 'Tabasco', 'Rural' UNION ALL
  SELECT 'Veracruz', 'Rural' UNION ALL
  SELECT 'Zacatecas', 'Rural' UNION ALL
  SELECT 'San Luis Potosi', 'Rural' UNION ALL
  SELECT 'Michoacan', 'Rural' UNION ALL
  SELECT 'Puebla', 'Rural'
),

magnitudes_clasificadas AS (
  SELECT 
    s.ID_sismo,
    s.Magnitud,
    CASE
      WHEN s.Magnitud < 4.0 THEN 'Leve'
      WHEN s.Magnitud < 5.0 THEN 'Moderado'
      WHEN s.Magnitud < 6.0 THEN 'Fuerte'
      WHEN s.Magnitud < 7.0 THEN 'Muy fuerte'
      ELSE 'Severo'
    END AS rango_magnitud
  FROM dim_sismos s
),

vulnerabilidad_completa AS (
  SELECT 
    f.ID_sismo,
    f.ID_zonas,
    z.nom_ent,
    z.POBTOT,
    FLOOR(z.POBTOT / 3) AS viviendas_estimadas_registro,
    f.poblacion_afectada,
    f.impacto_economico,
    m.Magnitud,
    m.rango_magnitud,
    c.tipo_zona
  FROM fact_impacto_sismos_imputed f
  JOIN dim_zonas z ON f.ID_zonas = z.ID_zonas
  JOIN magnitudes_clasificadas m ON f.ID_sismo = m.ID_sismo
  LEFT JOIN clasificacion_estados c ON z.nom_ent = c.estado
),

vulnerabilidad_con_impacto AS (
  SELECT 
    *,
    (FLOOR(POBTOT / 3) * POW(Magnitud / 10, 2)) AS viviendas_afectadas_estimadas
  FROM vulnerabilidad_completa
  WHERE tipo_zona IS NOT NULL
)

SELECT 
  tipo_zona,
  rango_magnitud,
  COUNT(ID_sismo) AS cantidad_sismos,
  avg(viviendas_estimadas_registro) AS total_viviendas_estimadas,
  AVG(viviendas_afectadas_estimadas) AS total_viviendas_afectadas,
  ROUND(SUM(viviendas_afectadas_estimadas) / SUM(viviendas_estimadas_registro) * 100, 2) AS porcentaje_afectacion,
  ROUND(100 / (AVG(impacto_economico) / 1000000000 + 1), 2) AS resiliencia_economica
FROM vulnerabilidad_con_impacto
GROUP BY tipo_zona, rango_magnitud
ORDER BY tipo_zona, FIELD(rango_magnitud, 'Leve', 'Moderado', 'Fuerte', 'Muy fuerte', 'Severo');
