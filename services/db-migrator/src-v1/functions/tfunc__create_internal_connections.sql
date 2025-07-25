CREATE OR REPLACE FUNCTION trg_create_internal_connections()
RETURNS TRIGGER AS
$$
DECLARE
  other_port RECORD;
BEGIN
  FOR other_port IN
    SELECT p.id, co.crossroad_id, p.is_inbound, p.is_outbound
    FROM crossroad_ports p
    JOIN crossroad_objects co ON p.id = co.id
    WHERE co.crossroad_id = (SELECT crossroad_id FROM crossroad_objects WHERE id = NEW.id)
      AND p.id <> NEW.id
  LOOP
    IF NEW.is_inbound AND other_port.is_outbound THEN
      PERFORM add_port_connection(NEW.id, other_port.id, NULL);
    ELSIF NEW.is_outbound AND other_port.is_inbound THEN
      PERFORM add_port_connection(other_port.id, NEW.id, NULL);
    END IF;
  END LOOP;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
