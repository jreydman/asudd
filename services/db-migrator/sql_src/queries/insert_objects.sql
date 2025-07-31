SELECT func__add_gateway(
------------------------
1::INTEGER,                  -- crossroad_id
------------------------
ST_SetSRID(ST_MakePoint(
  {perinf.location.lat},
  {perinf.location.lon}
), 4326 )::GEOMETRY,        -- global location
------------------------
ST_SetSRID(ST_MakePoint(
  {perinf.location.lat},
  {perinf.location.lon}
), 4326 )::GEOMETRY,         -- local location
------------------------
TRUE::BOOLEAN,               -- is_inbound
------------------------
FALSE::BOOLEAN               -- is outbound
------------------------
);

--------------------------------------------------------------------------------
