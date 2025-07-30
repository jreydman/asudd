-- Combined SQL file generated on Wed Jul 30 11:51:31 AM UTC 2025

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

CREATE TABLE IF NOT EXISTS object_crossroads (
  id    INTEGER NOT NULL,
  name  TEXT, 

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

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

CREATE TABLE IF NOT EXISTS object_gateways (
  id            INTEGER NOT NULL,

  is_inbound    BOOLEAN NOT NULL DEFAULT FALSE,
  is_outbound   BOOLEAN NOT NULL DEFAULT FALSE,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_gateway_valid_direction CHECK (is_inbound OR is_outbound)
);

CREATE TYPE OBJECT_GEOMETRY_GEOTYPE AS ENUM (
  'local',
  'global'
);


CREATE TABLE IF NOT EXISTS object_geometries (
  id                SERIAL,
  object_id         INTEGER NOT NULL,
  geotype           OBJECT_GEOMETRY_GEOTYPE,

  angle             DOUBLE PRECISION NOT NULL DEFAULT 0,
  geometry          GEOMETRY NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (object_id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_geometries.angle IS 'Value in radians, need for geometry rotation';


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

CREATE TABLE IF NOT EXISTS object_dependencies (
  master_id INTEGER NOT NULL,
  slave_id  INTEGER NOT NULL,

  PRIMARY KEY (master_id, slave_id),
  FOREIGN KEY (master_id) REFERENCES objects(id) ON DELETE CASCADE,
  FOREIGN KEY (slave_id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_object_dependencies_selflink CHECK (master_id <> slave_id)
);

CREATE OR REPLACE FUNCTION tfunc__set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION func__add_crossroad(
    p_name TEXT,
    p_geometry GEOMETRY,
    p_geometry_angle DOUBLE PRECISION,
    p_picture_base64 TEXT,
    p_picture_axis_width INTEGER,
    p_picture_axis_height INTEGER,
    p_picture_scale DOUBLE PRECISION,
    p_picture_angle DOUBLE PRECISION
)
RETURNS INTEGER
AS $$
DECLARE
    v_object_id INTEGER;
BEGIN
    INSERT INTO objects (type) VALUES (
        'crossroad'
    )
    RETURNING id INTO v_object_id;

    INSERT INTO object_crossroads (id, name) VALUES (
        v_object_id,
        p_name
    );

    INSERT INTO object_geometries (object_id, geotype, angle, geometry) VALUES (
        v_object_id,
        'global',
        COALESCE(p_geometry_angle, 0),
        p_geometry
    );

    INSERT INTO object_pictures (object_id, buffer, axis_width, axis_height, scale, angle) VALUES (
        v_object_id,
        decode(p_picture_base64, 'base64'),
        p_picture_axis_width,
        p_picture_axis_height,
        p_picture_scale,
        p_picture_angle
    );

    RETURN v_object_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg__set_updated_at__objects
BEFORE UPDATE ON objects
FOR EACH ROW
EXECUTE FUNCTION tfunc__set_updated_at();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_type__crossroads
BEFORE INSERT OR UPDATE ON object_crossroads
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_type__gateways
BEFORE INSERT OR UPDATE ON object_gateways
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_type__signals
BEFORE INSERT OR UPDATE ON object_signals
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_type__directions
BEFORE INSERT OR UPDATE ON object_directions
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

