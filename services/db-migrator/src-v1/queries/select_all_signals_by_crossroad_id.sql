SELECT
  o.id AS signal_id,
  o.crossroad_id,
  o.type,
  o.is_active,
  o.attributes,
  o.created_at,
  o.updated_at,
  g.id AS geometry_id,
  ST_AsGeoJSON(g.geometry)::json AS geometry_geojson,
  ST_GeometryType(g.geometry) AS geometry_type,
  ST_X(g.geometry) AS lon,
  ST_Y(g.geometry) AS lat,
  geometry
FROM
  crossroad_objects o
LEFT JOIN
  crossroad_object_geometries g ON g.crossroad_object_id = o.id
WHERE
  o.crossroad_id = 2
  AND o.type = 'highway_signal';
