CREATE OR REPLACE FUNCTION func__get_signals_by_points(points geometry[])
RETURNS TABLE (
  signal_id INTEGER,
  direction_id INTEGER,
  geom geometry
) AS $$
DECLARE
  i int;
  src_id int;
  tgt_id int;
  pt1 geometry;
  pt2 geometry;
  route_edge RECORD;
  merged_route geometry;
  g_row RECORD;

  prev_inbound BOOLEAN := FALSE;
  inbound_gateway_id INTEGER := NULL;

  dir_rec RECORD;
BEGIN
  IF array_length(points, 1) < 2 THEN
    RAISE EXCEPTION 'At least two points required';
  END IF;

  CREATE TEMP TABLE temp_route_geom(tmp_geom geometry(LineString, 4326)) ON COMMIT DROP;

  FOR i IN 1..array_length(points, 1) - 1 LOOP
    pt1 := points[i];
    pt2 := points[i+1];

    SELECT id INTO src_id FROM osm_ukraine_kyiv.ways_vertices_pgr
    ORDER BY the_geom <-> pt1
    LIMIT 1;

    SELECT id INTO tgt_id FROM osm_ukraine_kyiv.ways_vertices_pgr
    ORDER BY the_geom <-> pt2
    LIMIT 1;

    FOR route_edge IN
      SELECT * FROM pgr_dijkstra(
        'SELECT gid AS id, source, target, cost, reverse_cost FROM osm_ukraine_kyiv.ways',
        src_id, tgt_id, true
      )
    LOOP
      INSERT INTO temp_route_geom(tmp_geom)
      SELECT w.the_geom
      FROM osm_ukraine_kyiv.ways w
      WHERE w.gid = route_edge.edge;
    END LOOP;
  END LOOP;

  SELECT ST_LineMerge(ST_Union(tmp_geom)) INTO merged_route FROM temp_route_geom;

  FOR g_row IN
    SELECT 
      g.id AS gateway_id, g.is_inbound, g.is_outbound, og.figure,
      ST_LineLocatePoint(merged_route, ST_Centroid(og.figure)) AS pos_on_route
    FROM object_gateways g
    JOIN object_geometries og ON og.object_id = g.id AND og.geotype = 'global'
    WHERE ST_DWithin(og.figure::geography, merged_route::geography, 5)
    ORDER BY pos_on_route
  LOOP
    IF prev_inbound THEN
      IF g_row.is_outbound THEN
        RETURN QUERY
          SELECT s.id, d.id, og2.figure
          FROM object_directions d
          JOIN object_dependencies dep1 ON dep1.master_id = d.id AND dep1.slave_id = inbound_gateway_id
          JOIN object_dependencies dep2 ON dep2.master_id = g_row.gateway_id AND dep2.slave_id = d.id
          JOIN object_signals s ON TRUE
          JOIN object_dependencies d_sig ON d_sig.master_id = s.id AND d_sig.slave_id = d.id
          JOIN object_geometries og2 ON og2.object_id = s.id AND og2.geotype = 'local'
          WHERE d.id = d_sig.slave_id
          LIMIT ALL;

        prev_inbound := FALSE;
      END IF;

    ELSE
      IF g_row.is_inbound THEN
        inbound_gateway_id := g_row.gateway_id;
        prev_inbound := TRUE;
      END IF;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
