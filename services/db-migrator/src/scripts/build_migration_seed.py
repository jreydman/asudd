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

def build_migration_seed():
    term_width = shutil.get_terminal_size((100, 20)).columns
    root = Path(__file__).resolve().parents[2]
    seed_dir = root / "seed"
    out_dir = root / "sql_src/seed"
    out_dir.mkdir(parents=True, exist_ok=True)

    for json_file in sorted(seed_dir.glob("seed__crossroad-*.json")):
        data = json.loads(json_file.read_text(encoding="utf-8"))
        name, geometry, picture, objects = data["name"], data["geometry"], data["picture"], data["objects"]
        crossroad_id, object_id = 1, 2
        sql = [f"-- {json_file.name}"]

        sql.append(f"INSERT INTO objects (id, type) VALUES ({crossroad_id}, 'crossroad');")
        sql.append(f"INSERT INTO object_crossroads (id, name) VALUES ({crossroad_id}, $$ {name} $$);")

        sql.append(f"""INSERT INTO object_pictures (
  object_id, buffer, axis_width, axis_height, scale, angle
) VALUES (
  {crossroad_id}, decode('{b64(seed_dir / 'pictures' / picture["picture_filename"])}', 'base64'),
  {picture["axis_width"]}, {picture["axis_height"]},
  {picture["scale"]}, {picture.get("angle", 0)}
);""")

        for g in geometry:
            sql.append(f"""INSERT INTO object_geometries (
  object_id, geotype, figure, angle
) VALUES (
  {crossroad_id}, '{g["geotype"]}', {to_pg_geom(g["figure"])}, {g["figure"].get("angle", 0)}
);""")

        for obj in objects:
            obj_id = object_id
            object_id += 1
            sql.append(f"INSERT INTO objects (id, type) VALUES ({obj_id}, '{obj['type']}');")
            if obj["type"] == "gateway":
                sql.append(f"""INSERT INTO object_gateways (
  id, is_inbound, is_outbound
) VALUES (
  {obj_id}, {str(obj["is_inbound"]).upper()}, {str(obj["is_outbound"]).upper()}
);""")
            sql.append(f"INSERT INTO object_dependencies (master_id, slave_id) VALUES ({crossroad_id}, {obj_id});")

            for g in obj.get("geometry", []):
                sql.append(f"""INSERT INTO object_geometries (
  object_id, geotype, figure
) VALUES (
  {obj_id}, '{g["geotype"]}', {to_pg_geom(g["figure"])}
);""")

        out_path = out_dir / json_file.name.replace(".json", ".sql")
        out_path.write_text("\n".join(sql), encoding="utf-8")
        print(f"{json_file.name} → {out_path.relative_to(root)}")

    print("=" * term_width)
    print(f"Built {len(list(seed_dir.glob('seed__crossroad-*.json')))} seed migrations")
    print("=" * term_width)

# ------------------------------------------------------------------------------

build_migration_seed()
