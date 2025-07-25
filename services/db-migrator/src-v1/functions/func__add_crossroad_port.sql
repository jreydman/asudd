CREATE OR REPLACE FUNCTION add_crossroad_port(
  p_crossroad_id INTEGER,
  p_is_inbound BOOLEAN,
  p_is_outbound BOOLEAN,
  p_attributes JSONB DEFAULT NULL,
  p_geometry GEOMETRY DEFAULT NULL
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  new_port_id INTEGER;
BEGIN
  IF NOT (p_is_inbound OR p_is_outbound) THEN
    RAISE EXCEPTION 'At least one direction (is_inbound or is_outbound) must be TRUE';
  END IF;

  INSERT INTO crossroad_objects (crossroad_id, type, attributes)
  VALUES (p_crossroad_id, 'crossroad_port', COALESCE(p_attributes, '{}'::jsonb))
  RETURNING id INTO new_port_id;

  INSERT INTO crossroad_ports (id, is_inbound, is_outbound)
  VALUES (new_port_id, p_is_inbound, p_is_outbound);

  IF p_geometry IS NOT NULL THEN
    INSERT INTO crossroad_object_geometries (crossroad_object_id, geometry)
    VALUES (new_port_id, p_geometry);
  END IF;

  RETURN new_port_id;
END;
$$;
