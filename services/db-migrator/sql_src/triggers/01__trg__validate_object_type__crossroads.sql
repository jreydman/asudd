CREATE OR REPLACE TRIGGER trg__validate_object_type__crossroads
BEFORE INSERT OR UPDATE ON object_crossroads
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();
