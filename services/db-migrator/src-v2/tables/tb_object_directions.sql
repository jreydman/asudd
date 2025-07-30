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
