CREATE TABLE IF NOT EXISTS object_dependencies (
  master_id INTEGER NOT NULL,
  slave_id INTEGER NOT NULL,

  PRIMARY KEY (master_id, slave_id),
  FOREIGN KEY (master_id) REFERENCES objects(id) ON DELETE CASCADE,
  FOREIGN KEY (slave_id) REFERENCES objects(id) ON DELETE CASCADE,
  CONSTRAINT object_dependencies_selflink CHECK (master_id <> slave_id)
);
