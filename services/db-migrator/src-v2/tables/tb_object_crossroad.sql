CREATE TABLE IF NOT EXISTS object_crossroads (
  id    INTEGER NOT NULL,
  name  TEXT, 

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE
);
