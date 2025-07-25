CREATE OR REPLACE FUNCTION add_port_connection(
  p_source_port_id INTEGER,
  p_destination_port_id INTEGER,
  p_attributes JSONB DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  source_dir RECORD;
  dest_dir RECORD;
  conn_type PORT_CONNECTION_TYPE;
  new_connection_obj_id INTEGER;
BEGIN
  SELECT is_inbound, is_outbound INTO source_dir FROM crossroad_ports WHERE id = p_source_port_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Source port % not found', p_source_port_id;
  END IF;

  SELECT is_inbound, is_outbound INTO dest_dir FROM crossroad_ports WHERE id = p_destination_port_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Destination port % not found', p_destination_port_id;
  END IF;

  IF source_dir.is_inbound AND dest_dir.is_outbound THEN
    conn_type := 'internal';
  ELSIF source_dir.is_outbound AND dest_dir.is_inbound THEN
    conn_type := 'external';
  ELSE
    RAISE EXCEPTION 'Invalid port directions for connection between % and %', p_source_port_id, p_destination_port_id;
  END IF;

  IF conn_type = 'internal' THEN
    INSERT INTO crossroad_objects (crossroad_id, type, attributes)
    SELECT co.crossroad_id, 'crossroad_direction', COALESCE(p_attributes, '{}'::jsonb)
    FROM crossroad_objects co WHERE co.id = p_source_port_id
    RETURNING id INTO new_connection_obj_id;
  ELSE
    new_connection_obj_id := NULL;
  END IF;

  INSERT INTO port_connections (
    id,
    crossroad_object_source_id,
    crossroad_object_destination_id,
    connection_type
  ) VALUES (
    new_connection_obj_id,
    p_source_port_id,
    p_destination_port_id,
    conn_type
  );
END;
$$;
