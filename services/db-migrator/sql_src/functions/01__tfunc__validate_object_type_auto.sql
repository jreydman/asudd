CREATE OR REPLACE FUNCTION tfunc__validate_object_type_auto()
RETURNS TRIGGER AS $$
DECLARE
    v_expected_type TEXT;
    v_actual_type TEXT;
BEGIN
    v_expected_type := CASE TG_TABLE_NAME
        WHEN 'object_crossroads' THEN 'crossroad'
        WHEN 'object_signals' THEN 'signal'
        WHEN 'object_directions' THEN 'direction'
        WHEN 'object_gateways' THEN 'gateway'
        ELSE NULL
    END;
    
    IF v_expected_type IS NULL THEN
        RAISE EXCEPTION 'No type mapping for table %', TG_TABLE_NAME;
    END IF;
    
    -- Get the actual type from objects table
    SELECT type INTO v_actual_type
    FROM objects
    WHERE id = NEW.id;
    
    IF v_actual_type IS NULL THEN
        RAISE EXCEPTION 'Object with id % does not exist', NEW.id;
    ELSIF v_actual_type <> v_expected_type THEN
        RAISE EXCEPTION 'Object type mismatch for id %. Expected: %, Actual: %',
            NEW.id, v_expected_type, v_actual_type;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
