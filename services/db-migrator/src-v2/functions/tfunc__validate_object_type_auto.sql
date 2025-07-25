CREATE OR REPLACE FUNCTION tfunc__validate_object_type_auto()
RETURNS TRIGGER AS $$
DECLARE
    v_expected_type TEXT;
BEGIN
    v_expected_type := CASE TG_TABLE_NAME
        WHEN 'object_crossroads' THEN 'crossroad'
        WHEN 'object_signals' THEN 'signal'
        WHEN 'object_directions' THEN 'direction'
        ELSE NULL
    END;
    
    IF v_expected_type IS NULL THEN
        RAISE EXCEPTION 'No type mapping for table %', TG_TABLE_NAME;
    END IF;
    
    PERFORM tfunc__validate_object_type(
        TG_TABLE_NAME,
        v_expected_type,
        NEW.id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
