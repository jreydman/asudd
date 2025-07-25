WITH input_crossroad_params(crossroad_name) AS (
    VALUES ('Название перекрестка')
),
new_object_crossroad AS (
    INSERT INTO objects (type, name)
    SELECT 'crossroad', crossroad_name
    FROM input_crossroad_params
    RETURNING *
),
insert_crossroads AS (
    INSERT INTO object_crossroads (id)
    SELECT id FROM new_object_crossroad
)
SELECT id, name 
FROM new_object_crossroad;

--------------------------------------------------------------------------------

WITH input_direction_params(crossroad_id) AS (
    VALUES (1::INTEGER)
),
new_object_direction AS (
    INSERT INTO objects (type)
    VALUES ('direction')
    RETURNING *
),
insert_directions AS (
    INSERT INTO object_directions (id)
    SELECT id FROM new_object_direction
)
INSERT INTO object_dependencies (master_id, slave_id)
SELECT input_direction_params.crossroad_id, new_object_direction.id
FROM input_direction_params, new_object_direction;

--------------------------------------------------------------------------------

WITH input_signal_params(crossroad_id, signal_kinds) AS (
    VALUES (1::INTEGER, ARRAY['traffic']::OBJECT_SIGNAL_KIND[])
),
new_object_signal AS (
    INSERT INTO objects (type)
    VALUES ('signal'::OBJECT_TYPE)
    RETURNING *
),
insert_signal AS (
    INSERT INTO object_signals (id, kind)
    SELECT new_object_signal.id, input_signal_params.signal_kinds
    FROM new_object_signal, input_signal_params
)
INSERT INTO object_dependencies (master_id, slave_id)
SELECT input_signal_params.crossroad_id, new_object_signal.id
FROM input_signal_params, new_object_signal;
