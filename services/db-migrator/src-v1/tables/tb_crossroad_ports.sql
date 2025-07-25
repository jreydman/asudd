CREATE TABLE crossroad_ports (
  id INTEGER NOT NULL,

  is_inbound    BOOLEAN NOT NULL DEFAULT FALSE,
  is_outbound   BOOLEAN NOT NULL DEFAULT FALSE,

  --------------------------------------------------------------------------------

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES crossroad_objects(id) ON DELETE CASCADE,
  CONSTRAINT chk_valid_direction CHECK (is_inbound OR is_outbound)
);
