CREATE TYPE OBJECT_SIGNAL_KIND AS ENUM (
  'traffic'
  'pedestrian'
);

CREATE TYPE OBJECT_SIGNAL_STANDARD AS ENUM (
  't1.1',
  't1.2',
);

CREATE TABLE IF NOT EXISTS object_signals (
  id       INTEGER NOT NULL,

  standard OBJECT_SIGNAL_STANDARD, 
  kind     OBJECT_SIGNAL_KIND[] NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);

COMMENT ON COLUMN object_signals.standard IS 'ДСТУ тип стантарта светофоров';
