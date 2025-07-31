CREATE OR REPLACE TRIGGER trg__validate_object_type__gateways
BEFORE INSERT OR UPDATE ON object_gateways
FOR EACH ROW EXECUTE FUNCTION tfunc__validate_object_type_auto();
