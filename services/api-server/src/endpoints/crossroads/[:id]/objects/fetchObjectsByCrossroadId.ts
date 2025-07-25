import sql from "src/sql";

export default async function getObjectsByCrossroadId(crossroad_id: number) {
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
        object_geometries.angle,
        object_geometries.geotype
    FROM objects
    JOIN object_dependencies ON objects.id = object_dependencies.slave_id
    LEFT JOIN object_signals ON objects.id = object_signals.id
    LEFT JOIN object_geometries ON object_geometries.object_id = objects.id
    JOIN input_params ON TRUE
    
    WHERE object_dependencies.master_id = input_params.crossroad_id
    `;

  if (!objects[0].id) return [];

  return objects.map((object) => {
    if (object.geometry) {
      object.geometry = JSON.parse(object.geometry);
    }

    return object;
  });
}
