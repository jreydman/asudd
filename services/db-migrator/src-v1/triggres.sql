CREATE TRIGGER trg_set_updated_at__crossroads
BEFORE UPDATE ON crossroads
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();

--------------------------------------------------------------------------------

CREATE TRIGGER trg_set_updated_at__crossroad_objects
BEFORE UPDATE ON crossroad_objects
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();

--------------------------------------------------------------------------------

CREATE TRIGGER trg_after_insert_crossroad_port
AFTER INSERT ON crossroad_ports
FOR EACH ROW
EXECUTE FUNCTION trg_create_internal_connections();

