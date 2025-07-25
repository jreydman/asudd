-- получение перекрестка по id

-- PARAMS ----------------------------------------------------------------------

WITH input_params (crossroad_id) AS (
    VALUES (1::INTEGER)
)

-- QUERY -----------------------------------------------------------------------

SELECT 
	objects.id,
	objects.type,
	object_crossroads.name,
	object_geometries.geometry,
	object_pictures.buffer,
	object_pictures.axis_width,
	object_pictures.axis_height,
	object_pictures.scale,
	object_pictures.angle

FROM objects
JOIN object_crossroads ON object_crossroads.id = objects.id
LEFT JOIN object_geometries ON object_geometries.object_id = objects.id
LEFT JOIN object_pictures ON object_pictures.object_id = objects.id
JOIN input_params ON TRUE

-- FILTERS ---------------------------------------------------------------------
WHERE objects.id = input_params.crossroad_id
