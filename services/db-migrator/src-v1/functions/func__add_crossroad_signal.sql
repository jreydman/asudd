CREATE OR REPLACE FUNCTION add_crossroad_signal(
  p_crossroad_id INTEGER,
  p_attributes JSONB DEFAULT NULL,
  p_geometry GEOMETRY DEFAULT NULL
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  new_signal_id INTEGER;
BEGIN
  INSERT INTO crossroad_objects (crossroad_id, type, attributes)
  VALUES (p_crossroad_id, 'highway_signal', COALESCE(p_attributes, '{}'::jsonb))
  RETURNING id INTO new_signal_id;

  INSERT INTO crossroad_signals (id) VALUES (new_signal_id);

  IF p_geometry IS NOT NULL THEN
    INSERT INTO crossroad_object_geometries (crossroad_object_id, geometry)
    VALUES (new_signal_id, p_geometry);
  END IF;

  RETURN new_signal_id;
END;
$$;
