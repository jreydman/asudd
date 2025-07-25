import sql from "src/sql";

export default async function fetchCrossroadById(crossroad_id: number) {
  const crossroads = await sql`
      WITH input_params (crossroad_id) AS (
        VALUES (${crossroad_id}::integer)
      )

      SELECT 
	      object_crossroads.id,
       	object_crossroads.name,
       	object_pictures.buffer as picture_buffer,
       	object_pictures.axis_width as picture_axis_width,
       	object_pictures.axis_height as picture_axis_height,
       	object_pictures.scale as picture_scale,
       	object_pictures.angle as picture_angle
      FROM object_crossroads
      LEFT JOIN object_pictures ON object_crossroads.id = object_pictures.object_id
      JOIN input_params ON TRUE

      WHERE object_crossroads.id = input_params.crossroad_id
    `;

  let crossroad = crossroads[0];

  if (!crossroad.id) return undefined;

  crossroad = {
    id: crossroad.id,
    name: crossroad.name,
    picture: {
      buffer: crossroad.picture_buffer,
      axis_width: crossroad.picture_axis_width,
      axis_height: crossroad.picture_axis_height,
      scale: crossroad.picture_scale,
      angle: crossroad.picture_angle,
    },
  };

  return crossroad;
}
