
-- TYPES =======================================================================

CREATE TYPE OBJECT_TYPE AS ENUM (
  'crossroad',
  'signal',
  'direction',
  'gateway'
);

CREATE TYPE OBJECT_GEOLOCATION_TYPE AS ENUM (
  'local',
  'global'
);

--------------------------------------------------------------------------------

CREATE TYPE OBJECT_DIRECTION_DEFINITION AS ENUM (
  'internal',
  'external'
);

--------------------------------------------------------------------------------

CREATE TYPE OBJECT_SIGNAL_KIND AS ENUM (
  'traffic',
  'pedestrian'
);

-- TABLES ======================================================================

CREATE TABLE objects (
  id            SERIAL,
  object_type   OBJECT_TYPE NOT NULL,

  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  attributes    JSONB NOT NULL DEFAULT '{}',

  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id)
);

COMMENT ON COLUMN objects.attributes IS 'example { "is_dashed_direction": true }';

--------------------------------------------------------------------------------

CREATE TABLE object_type_mapping (
  table_name      TEXT,
  expected_type   OBJECT_TYPE NOT NULL,

  PRIMARY KEY (table_name)
);

-------------------------------------------------------------------------------

CREATE TABLE object_dependencies (
  master_id INTEGER NOT NULL,
  slave_id  INTEGER NOT NULL,

  PRIMARY KEY (master_id, slave_id),
  FOREIGN KEY (master_id) REFERENCES objects(id) ON DELETE CASCADE,
  FOREIGN KEY (slave_id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_object_dependencies_selflink CHECK (master_id <> slave_id)
);

--------------------------------------------------------------------------------

CREATE TABLE object_pictures (
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

--------------------------------------------------------------------------------

CREATE TABLE object_geometries (
  id          SERIAL,
  object_id   INTEGER NOT NULL,
  geotype     OBJECT_GEOLOCATION_TYPE NOT NULL,

  angle       DOUBLE PRECISION NOT NULL DEFAULT 0,
  figure      GEOMETRY NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (object_id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_geometries.angle IS 'Value in radians, need for geometry rotation';

--------------------------------------------------------------------------------

CREATE TABLE object_crossroads (
  id    INTEGER NOT NULL,
  name  TEXT, 

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_crossroads.name IS 'Human-readable identifier for the crossroad';

--------------------------------------------------------------------------------

CREATE TABLE object_gateways (
  id            INTEGER NOT NULL,

  is_inbound    BOOLEAN NOT NULL DEFAULT FALSE,
  is_outbound   BOOLEAN NOT NULL DEFAULT FALSE,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_gateway_valid_direction CHECK (is_inbound OR is_outbound)
);

--------------------------------------------------------------------------------

CREATE TABLE object_signal_standards(
  id     SERIAL,
  code   TEXT NOT NULL,

  PRIMARY KEY (id),
  UNIQUE (code)
);

--------------------------------------------------------------------------------

CREATE TABLE object_signals (
  id        INTEGER NOT NULL,

  standard  INTEGER, 
  kind      OBJECT_SIGNAL_KIND[] NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE,
  FOREIGN KEY (standard) REFERENCES object_signal_standards(id) ON DELETE SET NULL
);

COMMENT ON COLUMN object_signals.standard IS 'ДСТУ тип стандарта світлофорів';

--------------------------------------------------------------------------------

CREATE TABLE object_directions (
  id            INTEGER NOT NULL,
  definition    OBJECT_DIRECTION_DEFINITION NOT NULL DEFAULT 'internal',
  

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_directions.definition IS 'Displays relave at crossroad';

-- INSERTS ======================================================================


-- FUNCTIONS ===================================================================

CREATE FUNCTION tfunc__set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------

CREATE FUNCTION tfunc__validate_object_type_auto()
RETURNS TRIGGER AS $$
DECLARE
    v_expected_type TEXT;
    v_actual_type TEXT;
BEGIN
    SELECT expected_type INTO v_expected_type
    FROM object_type_mapping
    WHERE table_name = TG_TABLE_NAME;
    
    IF v_expected_type IS NULL THEN
        RAISE EXCEPTION 'No type mapping for table %', TG_TABLE_NAME;
    END IF;
    
    SELECT object_type INTO v_actual_type
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

-- TRIGGERS ====================================================================

CREATE TRIGGER trigger__set_updated_at__objects
BEFORE UPDATE ON objects
FOR EACH ROW
EXECUTE PROCEDURE tfunc__set_updated_at();

--------------------------------------------------------------------------------

CREATE TRIGGER trigger__validate_object_type__crossroads
AFTER INSERT OR UPDATE ON object_crossroads
FOR EACH ROW
EXECUTE PROCEDURE tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE TRIGGER trigger__validate_object_type__gateways
AFTER INSERT OR UPDATE ON object_gateways
FOR EACH ROW
EXECUTE PROCEDURE tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE TRIGGER trigger__validate_object_type__signals
AFTER INSERT OR UPDATE ON object_signals
FOR EACH ROW
EXECUTE PROCEDURE tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE TRIGGER trigger__validate_object_type__directions
AFTER INSERT OR UPDATE ON object_directions
FOR EACH ROW
EXECUTE PROCEDURE tfunc__validate_object_type_auto();

-- INDEXES =====================================================================

CREATE INDEX index_object_geometries_object_id ON object_geometries(object_id);
CREATE INDEX index_object_pictures_object_id ON object_pictures(object_id);
CREATE INDEX index_object_dependencies_slave_id ON object_dependencies(slave_id);

-- INSERTS ======================================================================

INSERT INTO object_type_mapping (table_name, expected_type) VALUES
  ('object_crossroads', 'crossroad'),
  ('object_signals',    'signal'),
  ('object_directions', 'direction'),
  ('object_gateways',   'gateway');
