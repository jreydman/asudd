CREATE OR REPLACE FUNCTION func__add_crossroad(
    p_name TEXT,
    p_geometry GEOMETRY,
    p_geometry_angle DOUBLE PRECISION,
    p_picture_base64 TEXT,
    p_picture_axis_width INTEGER,
    p_picture_axis_height INTEGER,
    p_picture_scale DOUBLE PRECISION,
    p_picture_angle DOUBLE PRECISION
)
RETURNS INTEGER
AS $$
DECLARE
    v_object_id INTEGER;
BEGIN
    INSERT INTO objects (type) VALUES (
        'crossroad'
    )
    RETURNING id INTO v_object_id;

    INSERT INTO object_crossroads (id, name) VALUES (
        v_object_id,
        p_name
    );

    INSERT INTO object_geometries (object_id, geotype, angle, geometry) VALUES (
        v_object_id,
        'global',
        COALESCE(p_geometry_angle, 0),
        p_geometry
    );

    INSERT INTO object_pictures (object_id, buffer, axis_width, axis_height, scale, angle) VALUES (
        v_object_id,
        decode(p_picture_base64, 'base64'),
        p_picture_axis_width,
        p_picture_axis_height,
        p_picture_scale,
        p_picture_angle
    );

    RETURN v_object_id;
END;
$$ LANGUAGE plpgsql;
