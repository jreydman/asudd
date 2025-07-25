CREATE TYPE CROSSROAD_OBJECT_TYPE AS ENUM (
  'highway_signal',
  'crossroad_port',
  'crossroad_direction'
);

CREATE TABLE crossroad_objects (
  id            SERIAL,
  crossroad_id  INTEGER NOT NULL,

  type          CROSSROAD_OBJECT_TYPE NOT NULL,
  is_active     BOOLEAN DEFAULT TRUE,

  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  attributes    JSONB,

  --------------------------------------------------------------------------------

  PRIMARY KEY (id),
  FOREIGN KEY (crossroad_id) REFERENCES crossroads(id) ON DELETE CASCADE
);
