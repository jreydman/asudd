SELECT
  o.id AS port_id,
  o.crossroad_id,
  o.type,
  o.is_active,
  o.attributes,
  o.created_at,
  o.updated_at,
  p.is_inbound,
  p.is_outbound,
  g.id AS geometry_id,
  g.geometry
FROM
  crossroad_objects o
JOIN
  crossroad_ports p ON o.id = p.id
LEFT JOIN
  crossroad_object_geometries g ON g.crossroad_object_id = o.id
WHERE
  o.crossroad_id = 2
  AND o.type = 'crossroad_port';
