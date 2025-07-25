-- Получение обьектов по id перекрестка

-- PARAMS ----------------------------------------------------------------------

WITH input_params (crossroad_id) AS (
    VALUES (1::INTEGER)
)

-- QUERY -----------------------------------------------------------------------

SELECT 
    objects.id,
    objects.type,
    objects.created_at,
    objects.updated_at,
    object_signals.standard,
    object_signals.kind,
    object_geometries.geometry,
    object_geometries.geotype
FROM objects
JOIN object_dependencies ON objects.id = object_dependencies.slave_id
LEFT JOIN object_geometries ON  objects.id object_geometries.object_id
LEFT JOIN object_signals ON objects.id = object_signals.id
JOIN input_params ON TRUE

-- FILTERS ---------------------------------------------------------------------
WHERE object_dependencies.master_id = input_params.crossroad_id
-- AND 'signal' = objects.type
-- AND 'traffic' = ANY(object_signals.kind)
