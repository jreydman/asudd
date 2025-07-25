CREATE TYPE OBJECT_GEOMETRY_GEOTYPE AS ENUM (
  'local',
  'global'
);


CREATE TABLE IF NOT EXISTS object_geometries (
  id                SERIAL,
  object_id         INTEGER NOT NULL,

  angle             DOUBLE PRECISION NOT NULL DEFAULT 0,

  geometry          GEOMETRY NOT NULL,
  geotype           OBJECT_GEOMETRY_GEOTYPE,

  PRIMARY KEY (id),
  FOREIGN KEY (object_id) REFERENCES objects(id) ON DELETE CASCADE,
  UNIQUE (object_id, geometry)
);

COMMENT ON COLUMN object_geometries.angle IS 'Value in radians, need for geometry rotation';

