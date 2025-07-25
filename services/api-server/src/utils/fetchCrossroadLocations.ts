import sql from "src/sql";

export default async function fetchCrossroadLocations() {
  const crossroad_locations = await sql`
    SELECT 
      object_geometries.object_id as id,
      object_crossroads.name,
    	ST_AsGeoJSON(object_geometries.geometry) AS geometry,
      object_geometries.angle
    FROM object_geometries
    JOIN object_crossroads ON object_geometries.object_id = object_crossroads.id
    WHERE object_geometries.geotype = 'global'
  `;

  if (!crossroad_locations[0].id) return [];

  return crossroad_locations.map((crossroad_location) => {
    if (crossroad_location.geometry) {
      crossroad_location.geometry = JSON.parse(crossroad_location.geometry);
    }

    return crossroad_location;
  });
}
