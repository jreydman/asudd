import json
import base64
import shutil

from pathlib import Path
from shapely.geometry import shape
from shapely.wkb import dumps as wkb_dumps

# ------------------------------------------------------------------------------

def to_pg_geom(geojson):
    return f"ST_GeomFromWKB('\\x{wkb_dumps(shape(geojson), hex=True)}', 4326)"

def b64(path):
    return base64.b64encode(path.read_bytes()).decode("ascii")

def insert_objects(obj_id, obj_type):
    return f"INSERT INTO objects (id, type) VALUES ({obj_id}, '{obj_type}');"

def insert_object_table(obj_id, obj_type, data):
    table = f"object_{obj_type}s"
    fields = []
    values = []

    if obj_type == "gateway":
        fields = ["id", "is_inbound", "is_outbound"]
        values = [obj_id, str(data["is_inbound"]).upper(), str(data["is_outbound"]).upper()]

    elif obj_type == "signal":
        fields = ["id", "standard", "kind"]
        values = [
            obj_id,
            f"'{data.get('standard')}'" if data.get("standard") else "NULL",
            f"ARRAY{data.get('kind', [])}::OBJECT_SIGNAL_KIND[]"
        ]

    elif obj_type == "direction":
        fields = ["id", "definition"]
        values = [obj_id, f"'{data.get('definition', 'internal')}'"]

    else:
        return f"-- Unsupported object type: {obj_type}"

    fields_str = ", ".join(fields)
    values_str = ", ".join(str(v) for v in values)
    return f"INSERT INTO {table} ({fields_str}) VALUES ({values_str});"

def insert_geometries(obj_id, geometries):
    stmts = []
    for g in geometries:
        geotype = g["geotype"]
        angle = g.get("angle", 0)  # <-- изменено: angle на уровне геометрии, а не figure
        figure_sql = to_pg_geom(g["figure"])
        if angle != 0:
            stmts.append(
                f"""INSERT INTO object_geometries (object_id, geotype, figure, angle)
VALUES ({obj_id}, '{geotype}', {figure_sql}, {angle});"""
            )
        else:
            stmts.append(
                f"""INSERT INTO object_geometries (object_id, geotype, figure)
VALUES ({obj_id}, '{geotype}', {figure_sql});"""
            )
    return stmts

def insert_crossroad_data(crossroad_id, name, picture, geometry, seed_dir):
    sql = [
        insert_objects(crossroad_id, "crossroad"),
        f"INSERT INTO object_crossroads (id, name) VALUES ({crossroad_id}, $$ {name} $$);",
        f"""INSERT INTO object_pictures (
  object_id, buffer, axis_width, axis_height, scale, angle
) VALUES (
  {crossroad_id}, decode('{b64(seed_dir / 'pictures' / picture["picture_filename"])}', 'base64'),
  {picture["axis_width"]}, {picture["axis_height"]},
  {picture["scale"]}, {picture.get("angle", 0)}
);"""
    ]
    sql += insert_geometries(crossroad_id, geometry)
    return sql

# ------------------------------------------------------------------------------

def build():
    term_width = shutil.get_terminal_size((100, 20)).columns
    root = Path(__file__).resolve().parents[2]
    seed_dir = root / "seed"
    out_dir = root / "sql_src/seed"
    out_dir.mkdir(parents=True, exist_ok=True)

    for json_file in sorted(seed_dir.glob("seed__crossroad-*.json")):
        data = json.loads(json_file.read_text(encoding="utf-8"))
        name = data["name"]
        geometry = data["geometry"]
        picture = data["picture"]
        objects = data["objects"]

        crossroad_id = 1
        object_id = crossroad_id + 1
        sql = [f"-- {json_file.name}"]

        sql += insert_crossroad_data(crossroad_id, name, picture, geometry, seed_dir)

        for obj in objects:
            obj_type = obj["type"]
            obj_id = object_id
            object_id += 1

            sql.append(insert_objects(obj_id, obj_type))
            sql.append(insert_object_table(obj_id, obj_type, obj))
            sql.append(f"INSERT INTO object_dependencies (master_id, slave_id) VALUES ({crossroad_id}, {obj_id});")
            sql += insert_geometries(obj_id, obj.get("geometry", []))

        out_path = out_dir / json_file.name.replace(".json", ".sql")
        out_path.write_text("\n".join(sql), encoding="utf-8")
        print(f"Built: {out_path.relative_to(root)}")

    print("=" * term_width)
    print(f"Seed migration built for {len(list(seed_dir.glob('seed__crossroad-*.json')))} crossroad(s)")
    print("=" * term_width)

# ------------------------------------------------------------------------------

build()
