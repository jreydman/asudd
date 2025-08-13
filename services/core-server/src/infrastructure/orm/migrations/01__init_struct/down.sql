
-- TRIGGERS ====================================================================

DROP TRIGGER trigger__set_updated_at__objects ON objects;
DROP TRIGGER trigger__validate_object_type__crossroads ON object_crossroads;
DROP TRIGGER trigger__validate_object_type__gateways ON object_gateways;
DROP TRIGGER trigger__validate_object_type__signals ON object_signals;
DROP TRIGGER trigger__validate_object_type__directions ON object_directions;


-- TABLES ======================================================================

-- typed tables
DROP TABLE object_signals;
DROP TABLE object_directions;
DROP TABLE object_gateways;
DROP TABLE object_crossroads;

-- reference tables
DROP TABLE object_signal_standards;
DROP TABLE object_type_mapping;

-- generic tables
DROP TABLE object_pictures;
DROP TABLE object_geometries;
DROP TABLE object_dependencies;
DROP TABLE objects;

-- TYPES =======================================================================

DROP TYPE OBJECT_TYPE;
DROP TYPE OBJECT_GEOLOCATION_TYPE;
DROP TYPE OBJECT_DIRECTION_DEFINITION;
DROP TYPE OBJECT_SIGNAL_KIND;

-- FUNCTIONS ===================================================================

DROP FUNCTION tfunc__set_updated_at;
DROP FUNCTION tfunc__validate_object_type_auto;
