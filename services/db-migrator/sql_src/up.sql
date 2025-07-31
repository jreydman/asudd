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

