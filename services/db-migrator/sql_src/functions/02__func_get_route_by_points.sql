CREATE OR REPLACE FUNCTION func__get_route_by_points(points geometry[])
RETURNS TABLE (
  seq integer,
  node bigint,
  edge bigint,
  cost double precision,
  geom geometry
) AS $$
DECLARE
  i int;
  src_id int;
  tgt_id int;
  route RECORD;
  pt1 geometry;
  pt2 geometry;
BEGIN
  IF array_length(points, 1) < 2 THEN
    RAISE EXCEPTION 'At least two points required';
  END IF;

  FOR i IN 1..array_length(points, 1) - 1 LOOP
    pt1 := points[i];
    pt2 := points[i+1];

    SELECT id INTO src_id FROM osm_ukraine_kyiv.ways_vertices_pgr
    ORDER BY the_geom <-> pt1
    LIMIT 1;

    SELECT id INTO tgt_id FROM osm_ukraine_kyiv.ways_vertices_pgr
    ORDER BY the_geom <-> pt2
    LIMIT 1;

    FOR route IN
      SELECT * FROM pgr_dijkstra(
        'SELECT gid AS id, source, target, cost, reverse_cost FROM osm_ukraine_kyiv.ways',
        src_id, tgt_id, true
      ) LOOP

      RETURN QUERY
      SELECT route.seq, route.node, route.edge, route.cost, w.the_geom
      FROM osm_ukraine_kyiv.ways w
      WHERE w.gid = route.edge;

    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
