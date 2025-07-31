SELECT
  master_objects.id as master_id,
  master_objects.type as master_type,
  master_object_geometries.figure as master_geometry,
  slave_objects.id as slave_id,
  slave_objects.type as slave_type,
  slave_object_geometries.figure as slave_geometry
FROM public.object_dependencies
JOIN objects as master_objects on object_dependencies.master_id = master_objects.id
JOIN objects as slave_objects on object_dependencies.slave_id = slave_objects.id
LEFT JOIN object_geometries as master_object_geometries on master_objects.id = master_object_geometries.object_id
LEFT JOIN object_geometries as slave_object_geometries on slave_objects.id = slave_object_geometries.object_id


--------------------------------------------------------------------------------

WHERE master_objects.type = 'gateway'
AND master_object_geometries.geotype = 'global'
AND slave_object_geometries.geotype = 'global'



---

SELECT
  master_objects.id AS id,
  'master' AS dependency_type,
  master_object_geometries.figure AS geometry
FROM public.object_dependencies
JOIN objects AS master_objects ON object_dependencies.master_id = master_objects.id
LEFT JOIN object_geometries AS master_object_geometries ON master_objects.id = master_object_geometries.object_id
WHERE master_objects.type = 'gateway'
  AND master_object_geometries.geotype = 'global'

UNION ALL

SELECT
  slave_objects.id AS id,
  'slave' AS dependency_type,
  slave_object_geometries.figure AS geometry
FROM public.object_dependencies
JOIN objects AS master_objects ON object_dependencies.master_id = master_objects.id
JOIN objects AS slave_objects ON object_dependencies.slave_id = slave_objects.id
LEFT JOIN object_geometries AS slave_object_geometries ON slave_objects.id = slave_object_geometries.object_id
WHERE master_objects.type = 'gateway'
  AND slave_object_geometries.geotype = 'global';

