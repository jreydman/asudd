CREATE TABLE crossroad_signals (
  id INTEGER NOT NULL,

--------------------------------------------------------------------------------

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES crossroad_objects(id) ON DELETE CASCADE
);
