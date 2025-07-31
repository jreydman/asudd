CREATE OR REPLACE TRIGGER trg__validate_object_type__directions
BEFORE INSERT OR UPDATE ON object_directions
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();
