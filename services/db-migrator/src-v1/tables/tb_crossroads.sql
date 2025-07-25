CREATE TABLE crossroads (
  id          SERIAL,

  name        VARCHAR(100),
  description TEXT,

  is_active   BOOLEAN DEFAULT TRUE,

  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  attributes  JSONB,

  --------------------------------------------------------------------------------

  PRIMARY KEY (id)
);
