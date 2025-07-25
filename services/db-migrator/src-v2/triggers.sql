CREATE OR REPLACE TRIGGER trg__set_updated_at__objects
BEFORE UPDATE ON objects
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_signal_type
BEFORE INSERT OR UPDATE ON object_signals
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_crossroad_type
BEFORE INSERT OR UPDATE ON object_crossroads
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg__validate_object_direction_type
BEFORE INSERT OR UPDATE ON object_directions
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();

--------------------------------------------------------------------------------

