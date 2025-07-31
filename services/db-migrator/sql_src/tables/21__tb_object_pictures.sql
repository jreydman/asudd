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
