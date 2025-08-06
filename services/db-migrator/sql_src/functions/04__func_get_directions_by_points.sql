CREATE OR REPLACE FUNCTION func__get_directions_by_points(points geometry[])
RETURNS TABLE (
  direction_id INTEGER,
  inbound_gateway_id INTEGER,
  outbound_gateway_id INTEGER
) AS $$
DECLARE
  i INT;
  src_id INT;
  tgt_id INT;
  merged_route geometry;
  route_edge RECORD;
  gateways RECORD;
  outbound_gateway RECORD;
BEGIN
  IF array_length(points, 1) < 2 THEN
    RAISE EXCEPTION 'At least two points required';
  END IF;

  DROP TABLE IF EXISTS temp_route_geom;
  CREATE TEMP TABLE temp_route_geom(tmp_geom geometry(LineString, 4326)) ON COMMIT DROP;

  FOR i IN 1..array_length(points, 1) - 1 LOOP
    SELECT id INTO src_id
      FROM osm_ukraine_kyiv.ways_vertices_pgr
      ORDER BY the_geom <-> points[i]
      LIMIT 1;

    SELECT id INTO tgt_id
      FROM osm_ukraine_kyiv.ways_vertices_pgr
      ORDER BY the_geom <-> points[i+1]
      LIMIT 1;

    FOR route_edge IN
      SELECT * FROM pgr_dijkstra(
        'SELECT gid AS id, source, target, cost, reverse_cost FROM osm_ukraine_kyiv.ways',
        src_id, tgt_id, true
      )
    LOOP
      INSERT INTO temp_route_geom(tmp_geom)
      SELECT the_geom FROM osm_ukraine_kyiv.ways WHERE gid = route_edge.edge;
    END LOOP;
  END LOOP;

  SELECT ST_LineMerge(ST_Union(tmp_geom)) INTO merged_route FROM temp_route_geom;

  DROP TABLE IF EXISTS temp_gateways;
  CREATE TEMP TABLE temp_gateways AS
  SELECT 
    g.id,
    g.is_inbound,
    g.is_outbound,
    ST_LineLocatePoint(merged_route, ST_Centroid(og.figure)) AS pos
  FROM object_gateways g
  JOIN object_geometries og ON og.object_id = g.id AND og.geotype = 'global'
  WHERE ST_DWithin(og.figure::geography, merged_route::geography, 5)
  ORDER BY pos;

  FOR gateways IN SELECT * FROM temp_gateways WHERE is_inbound ORDER BY pos LOOP
    FOR outbound_gateway IN
      SELECT * FROM temp_gateways WHERE is_outbound AND pos > gateways.pos ORDER BY pos
    LOOP
      RETURN QUERY
      SELECT d.id, gateways.id, outbound_gateway.id
      FROM object_directions d
      JOIN object_dependencies dep1 ON dep1.master_id = d.id AND dep1.slave_id = gateways.id
      JOIN object_dependencies dep2 ON dep2.master_id = outbound_gateway.id AND dep2.slave_id = d.id;
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
