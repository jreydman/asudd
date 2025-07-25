import sql from "src/sql";

export default async function fetchCrossroadPoints() {
  const crossroad_points = await sql`
    SELECT 
    	objects.id,
    	objects.type,
    	ST_AsGeoJSON(object_geometries.geometry) AS geometry
    FROM objects
    JOIN object_crossroads ON object_crossroads.id = objects.id
    JOIN object_geometries ON object_geometries.object_id = objects.id

    WHERE objects.type = 'crossroad'
  `;

  if (!crossroad_points[0].id) return [];

  return crossroad_points.map((crossroad_point) => {
    if (crossroad_point.geometry) {
      crossroad_point.geometry = JSON.parse(crossroad_point.geometry);
    }

    return crossroad_point;
  });
}
