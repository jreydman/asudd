CREATE TYPE OBJECT_TYPE AS ENUM (
  'crossroad',
  'signal',
  'direction'
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
