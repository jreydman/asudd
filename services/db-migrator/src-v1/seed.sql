
-- ST_SetSRID(ST_MakePoint(), 4326)

--------------------------------------------------------------------------------

INSERT INTO crossroads (id, name) VALUES
(2, 'бульв. Т.Шевченка - вул. Володимирська');

SELECT add_crossroad_port(2, TRUE, FALSE, NULL, ST_SetSRID(ST_MakePoint(30.5119847, 50.4435532), 4326));   -- порт 1: вход юго-запад

SELECT add_crossroad_port(2, FALSE, TRUE, NULL, ST_SetSRID(ST_MakePoint(30.5127663, 50.4434215), 4326));   -- порт 2: выход юго-восток

SELECT add_crossroad_port(2, TRUE, FALSE, NULL, ST_SetSRID(ST_MakePoint(30.5128578, 50.4436427), 4326));   -- порт 3: вход северо-восток

SELECT add_crossroad_port(2, FALSE, TRUE, NULL, ST_SetSRID(ST_MakePoint(30.5120841, 50.4437714), 4326));   -- порт 4: выход северо-запад

SELECT add_crossroad_port(2, TRUE, TRUE, NULL, ST_SetSRID(ST_MakePoint(30.5125626, 50.4438846), 4326));    -- порт 5: вход+выход север

SELECT add_crossroad_port(2, TRUE, TRUE, NULL, ST_SetSRID(ST_MakePoint(30.5123310, 50.4433113), 4326));    -- порт 6: вход+выход юг

SELECT add_crossroad_signal(2, NULL, ST_SetSRID(ST_MakePoint(30.5120848, 50.4435366), 4326));

SELECT add_crossroad_signal(2, NULL, ST_SetSRID(ST_MakePoint(30.5123609, 50.4433820), 4326));

SELECT add_crossroad_signal(2, NULL, ST_SetSRID(ST_MakePoint(30.5127432, 50.4436614), 4326));

SELECT add_crossroad_signal(2, NULL, ST_SetSRID(ST_MakePoint(30.5125438, 50.4438363), 4326));

--------------------------------------------------------------------------------
