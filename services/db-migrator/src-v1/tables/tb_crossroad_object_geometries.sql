CREATE TABLE crossroad_object_geometries (
  id SERIAL,
  crossroad_object_id INTEGER NOT NULL,
  geometry GEOMETRY(GEOMETRY, 4326) NOT NULL,

--------------------------------------------------------------------------------

  PRIMARY KEY (id),
  FOREIGN KEY (crossroad_object_id) REFERENCES crossroad_objects(id) ON DELETE CASCADE,
  UNIQUE (crossroad_object_id, geometry)
);
