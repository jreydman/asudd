SELECT * FROM osm__ukraine_kyiv.func__get_route_by_points(ARRAY[
  -- start mark (50.4445150, 30.4988571)
  ST_SetSRID(ST_MakePoint(30.4988571, 50.4445150), 4326),
  -- end mark (50.4452792, 30.5131049)
  ST_SetSRID(ST_MakePoint(30.5131049, 50.4452792), 4326)
]);
