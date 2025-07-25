CREATE TYPE PORT_CONNECTION_TYPE AS ENUM ('internal', 'external');

CREATE TABLE port_connections (
  id INTEGER,

  crossroad_object_source_id INTEGER NOT NULL,
  crossroad_object_destination_id INTEGER NOT NULL,

  connection_type PORT_CONNECTION_TYPE NOT NULL,

  --------------------------------------------------------------------------------

  PRIMARY KEY (crossroad_object_source_id, crossroad_object_destination_id),
  UNIQUE (id, crossroad_object_source_id, crossroad_object_destination_id),

  FOREIGN KEY (crossroad_object_source_id) REFERENCES crossroad_objects(id) ON DELETE CASCADE,
  FOREIGN KEY (crossroad_object_destination_id) REFERENCES crossroad_objects(id) ON DELETE CASCADE,
  FOREIGN KEY (id) REFERENCES crossroad_objects(id) ON DELETE CASCADE,

  CONSTRAINT chk_no_self_connection CHECK (crossroad_object_source_id <> crossroad_object_destination_id),

  CONSTRAINT chk_internal_id CHECK (
    (connection_type = 'internal' AND id IS NOT NULL)
    OR
    (connection_type = 'external' AND id IS NULL)
  )
);
