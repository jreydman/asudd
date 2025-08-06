CREATE OR REPLACE FUNCTION func__get_gateways_by_points(points geometry[])
RETURNS TABLE (
  gateway_id INTEGER,
  is_inbound BOOLEAN,
  is_outbound BOOLEAN,
  gateway_geom geometry
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
BEGIN
  IF array_length(points, 1) < 2 THEN
    RAISE EXCEPTION 'At least two points required';
  END IF;

  DROP TABLE IF EXISTS temp_route_geom;
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
      g.id, g.is_inbound, g.is_outbound, og.figure,
      ST_LineLocatePoint(merged_route, ST_Centroid(og.figure)) AS pos_on_route
    FROM object_gateways g
    JOIN object_geometries og ON og.object_id = g.id AND og.geotype = 'global'
    WHERE ST_DWithin(og.figure::geography, merged_route::geography, 5)
    ORDER BY pos_on_route
  LOOP
    IF prev_inbound THEN
      IF g_row.is_outbound THEN
        gateway_id := g_row.id;
        is_inbound := FALSE;
        is_outbound := TRUE;
        gateway_geom := g_row.figure;
        RETURN NEXT;
        prev_inbound := FALSE;
      END IF;
    ELSE
      IF g_row.is_inbound THEN
        gateway_id := g_row.id;
        is_inbound := TRUE;
        is_outbound := FALSE;
        gateway_geom := g_row.figure;
        RETURN NEXT;
        prev_inbound := TRUE;
      END IF;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
