-- functions/00__tfunc__set_updated_at.sql
CREATE OR REPLACE FUNCTION tfunc__set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- functions/01__tfunc__validate_object_type_auto.sql
CREATE OR REPLACE FUNCTION tfunc__validate_object_type_auto()
RETURNS TRIGGER AS $$
DECLARE
    v_expected_type TEXT;
    v_actual_type TEXT;
BEGIN
    v_expected_type := CASE TG_TABLE_NAME
        WHEN 'object_crossroads' THEN 'crossroad'
        WHEN 'object_signals' THEN 'signal'
        WHEN 'object_directions' THEN 'direction'
        WHEN 'object_gateways' THEN 'gateway'
        ELSE NULL
    END;
    
    IF v_expected_type IS NULL THEN
        RAISE EXCEPTION 'No type mapping for table %', TG_TABLE_NAME;
    END IF;
    
    -- Get the actual type from objects table
    SELECT type INTO v_actual_type
    FROM objects
    WHERE id = NEW.id;
    
    IF v_actual_type IS NULL THEN
        RAISE EXCEPTION 'Object with id % does not exist', NEW.id;
    ELSIF v_actual_type <> v_expected_type THEN
        RAISE EXCEPTION 'Object type mismatch for id %. Expected: %, Actual: %',
            NEW.id, v_expected_type, v_actual_type;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- functions/02__func_get_route_by_points.sql
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

-- functions/03__func_get_gateways_by_points.sql
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

-- functions/04__func_get_directions_by_points.sql
CREATE OR REPLACE FUNCTION func__get_directions_by_points(points geometry[])
RETURNS TABLE (
  direction_id INTEGER,
  inbound_gateway_id INTEGER,
  outbound_gateway_id INTEGER
) AS $$
DECLARE
  rec RECORD;
  prev_inbound RECORD := NULL;
BEGIN
  FOR rec IN
    SELECT * FROM func__get_gateways_by_points(points)
  LOOP
    IF rec.is_inbound THEN
      prev_inbound := rec;

    ELSIF rec.is_outbound AND prev_inbound IS NOT NULL THEN

      RETURN QUERY
      SELECT d.id, prev_inbound.gateway_id, rec.gateway_id
      FROM object_directions d
      JOIN object_dependencies dep1
        ON dep1.master_id = d.id AND dep1.slave_id = prev_inbound.gateway_id
      JOIN object_dependencies dep2
        ON dep2.master_id = rec.gateway_id AND dep2.slave_id = d.id
      LIMIT 1;

      prev_inbound := NULL;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- functions/05__func_get_signals_by_points.sql
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

-- tables/00__tb_objects.sql
CREATE TYPE OBJECT_TYPE AS ENUM (
  'crossroad',
  'signal',
  'direction',
  'gateway'
);

CREATE TABLE IF NOT EXISTS objects (
  id            SERIAL,
  type          OBJECT_TYPE NOT NULL,

  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  attributes    JSONB NOT NULL DEFAULT '{}',

  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id)
);

COMMENT ON COLUMN objects.attributes IS 'example { "is_dashed_direction": true }';

-- tables/01__tb_object_dependencies.sql
CREATE TABLE IF NOT EXISTS object_dependencies (
  master_id INTEGER NOT NULL,
  slave_id  INTEGER NOT NULL,

  PRIMARY KEY (master_id, slave_id),
  FOREIGN KEY (master_id) REFERENCES objects(id) ON DELETE CASCADE,
  FOREIGN KEY (slave_id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_object_dependencies_selflink CHECK (master_id <> slave_id)
);

-- tables/10__tb_object_crossroads.sql
CREATE TABLE IF NOT EXISTS object_crossroads (
  id    INTEGER NOT NULL,
  name  TEXT, 

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

-- tables/11__tb_object_gateways.sql
CREATE TABLE IF NOT EXISTS object_gateways (
  id            INTEGER NOT NULL,

  is_inbound    BOOLEAN NOT NULL DEFAULT FALSE,
  is_outbound   BOOLEAN NOT NULL DEFAULT FALSE,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_gateway_valid_direction CHECK (is_inbound OR is_outbound)
);

-- tables/12__tb_object_directions.sql
CREATE TYPE OBJECT_DIRECTION_DEFINITION AS ENUM (
  'internal',
  'external'
);


CREATE TABLE IF NOT EXISTS object_directions (
  id         INTEGER NOT NULL,
  definition OBJECT_DIRECTION_DEFINITION NOT NULL DEFAULT 'internal',
  

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_directions.definition IS 'Displays relave at crossroad';

-- tables/13__tb_object_signals.sql
CREATE TYPE OBJECT_SIGNAL_KIND AS ENUM (
  'traffic',
  'pedestrian'
);

CREATE TYPE OBJECT_SIGNAL_STANDARD AS ENUM (
  't1.1',
  't1.2'
);

CREATE TABLE IF NOT EXISTS object_signals (
  id       INTEGER NOT NULL,

  standard OBJECT_SIGNAL_STANDARD, 
  kind     OBJECT_SIGNAL_KIND[] NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_signals.standard IS 'ДСТУ тип стандарта світлофорів';

-- tables/20__tb_object_geometries.sql
CREATE TYPE OBJECT_GEOMETRY_GEOTYPE AS ENUM (
  'local',
  'global'
);


CREATE TABLE IF NOT EXISTS object_geometries (
  id                SERIAL,
  object_id         INTEGER NOT NULL,
  geotype           OBJECT_GEOMETRY_GEOTYPE,

  angle             DOUBLE PRECISION NOT NULL DEFAULT 0,
  figure            GEOMETRY NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (object_id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_geometries.angle IS 'Value in radians, need for geometry rotation';

-- tables/21__tb_object_pictures.sql
CREATE TABLE IF NOT EXISTS object_pictures (
  id            SERIAL,
  object_id     INTEGER NOT NULL,

  buffer        BYTEA   NOT NULL,

  axis_width    INTEGER NOT NULL,
  axis_height   INTEGER NOT NULL,

  scale         DOUBLE PRECISION NOT NULL DEFAULT 1,
  angle         DOUBLE PRECISION NOT NULL DEFAULT 0,

  PRIMARY KEY (id),
  FOREIGN KEY (object_id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_pictures.angle IS 'Value in radians, need for picture rotation';
COMMENT ON COLUMN object_pictures.buffer IS 'Value as base64';

-- triggers/00__trg__set_updated_at__objects.sql
CREATE OR REPLACE TRIGGER trg__set_updated_at__objects
BEFORE UPDATE ON objects
FOR EACH ROW
EXECUTE FUNCTION tfunc__set_updated_at();

-- triggers/01__trg__validate_object_type__crossroads.sql
CREATE OR REPLACE TRIGGER trg__validate_object_type__crossroads
BEFORE INSERT OR UPDATE ON object_crossroads
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

-- triggers/02__trg__validate_object_type__gateways.sql
CREATE OR REPLACE TRIGGER trg__validate_object_type__gateways
BEFORE INSERT OR UPDATE ON object_gateways
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

-- triggers/03__trg__validate_object_type__signals.sql
CREATE OR REPLACE TRIGGER trg__validate_object_type__signals
BEFORE INSERT OR UPDATE ON object_signals
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

-- triggers/04__trg__validate_object_type__directions.sql
CREATE OR REPLACE TRIGGER trg__validate_object_type__directions
BEFORE INSERT OR UPDATE ON object_directions
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

