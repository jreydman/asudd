-- прямые линии

SELECT 
    pc.id AS connection_id,
    pc.crossroad_object_source_id AS source_port_id,
    pc.crossroad_object_destination_id AS destination_port_id,
    ST_MakeLine(
        src_geom.geometry, 
        dst_geom.geometry
    )::geometry(LINESTRING, 4326) AS connection_geometry
FROM 
    port_connections pc
JOIN 
    crossroad_objects src_port ON pc.crossroad_object_source_id = src_port.id
JOIN 
    crossroad_objects dst_port ON pc.crossroad_object_destination_id = dst_port.id
JOIN 
    crossroad_object_geometries src_geom ON src_port.id = src_geom.crossroad_object_id
JOIN 
    crossroad_object_geometries dst_geom ON dst_port.id = dst_geom.crossroad_object_id
WHERE 
    src_port.crossroad_id = 2
    AND dst_port.crossroad_id = 2
    AND pc.connection_type = 'internal';

--------------------------------------------------------------------------------

-- автопросчет геометрии

WITH 
port_connections AS (
    SELECT 
        pc.id,
        pc.crossroad_object_source_id AS source_port_id,
        pc.crossroad_object_destination_id AS target_port_id,
        src_geom.geometry AS source_geom,
        dst_geom.geometry AS target_geom
    FROM 
        port_connections pc
    JOIN crossroad_objects src_port ON pc.crossroad_object_source_id = src_port.id
    JOIN crossroad_objects dst_port ON pc.crossroad_object_destination_id = dst_port.id
    JOIN crossroad_object_geometries src_geom ON src_port.id = src_geom.crossroad_object_id
    JOIN crossroad_object_geometries dst_geom ON dst_port.id = dst_geom.crossroad_object_id
    WHERE 
        src_port.crossroad_id = 2
        AND dst_port.crossroad_id = 2
        AND pc.connection_type = 'internal'
),

nearest_vertices AS (
    SELECT
        pc.id AS connection_id,
        pc.source_port_id,
        pc.target_port_id,
        (SELECT v.id FROM ways_vertices_pgr v 
         ORDER BY v.the_geom <-> pc.source_geom LIMIT 1) AS source_vertex_id,
        (SELECT v.id FROM ways_vertices_pgr v 
         ORDER BY v.the_geom <-> pc.target_geom LIMIT 1) AS target_vertex_id
    FROM port_connections pc
)

SELECT
    nv.connection_id,
    nv.source_port_id,
    nv.target_port_id,
    ST_LineMerge(ST_Collect(w.the_geom)) AS route_geometry,
    SUM(w.length_m) AS total_length_meters
FROM 
    nearest_vertices nv
CROSS JOIN LATERAL
    pgr_dijkstra(
        'SELECT gid AS id, source, target, length_m AS cost 
         FROM ways',
        nv.source_vertex_id,
        nv.target_vertex_id,
        directed := false
    ) AS di
JOIN ways w ON di.edge = w.gid
GROUP BY nv.connection_id, nv.source_port_id, nv.target_port_id;
