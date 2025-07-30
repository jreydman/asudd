CREATE TABLE IF NOT EXISTS object_gateways (
  id            INTEGER NOT NULL,

  is_inbound    BOOLEAN NOT NULL DEFAULT FALSE,
  is_outbound   BOOLEAN NOT NULL DEFAULT FALSE,

  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES objects(id) ON DELETE CASCADE,

  CONSTRAINT check_gateway_valid_direction CHECK (is_inbound OR is_outbound)
);
