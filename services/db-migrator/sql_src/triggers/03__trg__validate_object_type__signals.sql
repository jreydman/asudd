CREATE OR REPLACE TRIGGER trg__validate_object_type__signals
BEFORE INSERT OR UPDATE ON object_signals
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();
