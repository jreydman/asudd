import sql from "src/sql";

export default async function fetchObjectsByCrossroadId(crossroad_id: number) {
  const objects = await sql`
    WITH input_params (crossroad_id) AS (
        VALUES (${crossroad_id}::integer)
    )
    
    SELECT 
        objects.id,
        objects.type,
        object_signals.standard,
        object_signals.kind,
    	  ST_AsGeoJSON(object_geometries.geometry) AS geometry,
        object_geometries.angle as geometry_angle
    FROM object_dependencies
    JOIN objects ON objects.id = object_dependencies.slave_id
    LEFT JOIN object_signals ON objects.id = object_signals.id
    LEFT JOIN object_geometries ON objects.id = object_geometries.object_id
    JOIN input_params ON TRUE
    
    WHERE object_dependencies.master_id = input_params.crossroad_id
      AND object_geometries.geotype = 'local'
    `;

  if (!objects[0].id) return [];

  return objects.map((object) => {
    if (object.geometry) {
      object.geometry = JSON.parse(object.geometry);
    }

    object.geometry.angle = object.geometry_angle;

    delete object.geometry_angle;

    return object;
  });
}
