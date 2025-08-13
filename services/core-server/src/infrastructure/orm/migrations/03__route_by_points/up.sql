CREATE FUNCTION public.func__get_route_by_points(
    schema_name text,
    points geometry[]
)
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
    sql_vertices text;
    sql_ways text;
BEGIN
    IF array_length(points, 1) < 2 THEN
        RAISE EXCEPTION 'At least two points required';
    END IF;

    sql_vertices := format('%I.ways_vertices_pgr', schema_name);
    sql_ways := format('%I.ways', schema_name);

    FOR i IN 1..array_length(points, 1) - 1 LOOP
        pt1 := points[i];
        pt2 := points[i+1];

        EXECUTE format(
            'SELECT id FROM %s ORDER BY the_geom <-> $1 LIMIT 1',
            sql_vertices
        )
        INTO src_id
        USING pt1;

        EXECUTE format(
            'SELECT id FROM %s ORDER BY the_geom <-> $1 LIMIT 1',
            sql_vertices
        )
        INTO tgt_id
        USING pt2;

        FOR route IN
            EXECUTE format(
                'SELECT * FROM pgr_dijkstra(
                    ''SELECT gid AS id, source, target, cost, reverse_cost FROM %s'',
                    $1, $2, true
                )',
                sql_ways
            )
            USING src_id, tgt_id
        LOOP
            RETURN QUERY EXECUTE format(
                'SELECT $1::int, $2::bigint, $3::bigint, $4::double precision, the_geom
                 FROM %s WHERE gid = $3',
                sql_ways
            )
            USING route.seq, route.node, route.edge, route.cost;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
