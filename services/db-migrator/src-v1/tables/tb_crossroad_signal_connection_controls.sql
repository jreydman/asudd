CREATE TABLE crossroad_signal_connection_controls (
  signal_id INTEGER NOT NULL,
  port_connection_id INTEGER NOT NULL,

  is_active BOOLEAN NOT NULL DEFAULT TRUE,

--------------------------------------------------------------------------------
  PRIMARY KEY (signal_id, port_connection_id)
);
