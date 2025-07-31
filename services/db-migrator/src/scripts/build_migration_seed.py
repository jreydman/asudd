import json
import base64
from pathlib import Path

# -------------------------------------------------------------------------------

def build_migration_seed():
    root = Path(__file__).parents[2]
    seed_dir = root / "seed"
    sql_dir = root / "sql_src" / "seed"
    pictures_dir = seed_dir / "pictures"

    print(f"[INFO] Scanning seed directory: {seed_dir}")
    for seed_file in seed_dir.glob("*seed.json"):
        if seed_file.name.startswith("__"):
            continue

        print(f"[INFO] Processing seed file: {seed_file.name}")
        with open(seed_file, 'r') as f:
            data = json.load(f)

        sql = [f"-- Generated from {seed_file.name}", "BEGIN;", TEMP_TABLE_SQL]

        for obj in data['objects']:
            print(f"[DEBUG] Processing object id={obj['id']} type={obj['type']}")
            sql.extend(process_object(obj, pictures_dir))

        if 'dependencies' in data:
            print(f"[INFO] Adding {len(data['dependencies'])} dependency groups")
            for dep in data['dependencies']:
                for slave_id in dep['slave_ids']:
                    sql.append(DEPENDENCY_SQL.format(
                        master=dep['master_id'],
                        slave=slave_id
                    ))

        sql += ["DROP TABLE temp_id_mapping;", "COMMIT;"]

        sql_path = sql_dir / f"{seed_file.stem}.sql"
        sql_path.parent.mkdir(parents=True, exist_ok=True)
        sql_path.write_text("\n".join(sql), encoding="utf-8")

        print(f"[SUCCESS] SQL written to: {sql_path}")

# -------------------------------------------------------------------------------

TEMP_TABLE_SQL = """
CREATE TEMPORARY TABLE temp_id_mapping (
    seed_id INTEGER PRIMARY KEY,
    db_id INTEGER
);"""

DEPENDENCY_SQL = """
INSERT INTO object_dependencies (master_id, slave_id)
SELECT m.db_id, s.db_id
FROM temp_id_mapping m, temp_id_mapping s
WHERE m.seed_id = {master} AND s.seed_id = {slave};"""

# -------------------------------------------------------------------------------

def process_object(obj, pictures_dir: Path) -> list[str]:
    lines = [f"""
DO $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO objects (type, is_active, attributes)
    VALUES ('{obj['type']}', TRUE, '{{}}')
    RETURNING id INTO new_id;

    INSERT INTO temp_id_mapping (seed_id, db_id) VALUES ({obj['id']}, new_id);"""]

    if obj['type'] == 'crossroad':
        lines.append(f"""
    INSERT INTO object_crossroads (id, name)
    VALUES (new_id, {repr(obj.get('name'))});""")

    elif obj['type'] == 'signal':
        kinds = "{" + ",".join(obj.get('kind', [])) + "}"
        lines.append(f"""
    INSERT INTO object_signals (id, kind)
    VALUES (new_id, '{kinds}'::OBJECT_SIGNAL_KIND[]);""")

    elif obj['type'] == 'gateway':
        inbound = str(obj.get('is_inbound', False)).lower()
        outbound = str(obj.get('is_outbound', False)).lower()
        lines.append(f"""
    INSERT INTO object_gateways (id, is_inbound, is_outbound)
    VALUES (new_id, {inbound}, {outbound});""")

    elif obj['type'] == 'direction':
        definition = obj.get('definition', 'internal')
        lines.append(f"""
    INSERT INTO object_directions (id, definition)
    VALUES (new_id, '{definition}'::OBJECT_DIRECTION_DEFINITION);""")

    lines.extend(process_geometry(obj.get('geometry', [])))
    lines.extend(process_picture(obj.get('picture'), pictures_dir))

    lines.append("END $$;")
    return lines

# -------------------------------------------------------------------------------

def process_geometry(geometries: list) -> list[str]:
    sql = []
    for geom in geometries:
        if geom['figure']['type'] == 'Point':
            x, y = geom['figure']['coordinates']
            geom_sql = f"ST_SetSRID(ST_MakePoint({x}, {y}), 4326)"
            sql.append(f"""
    INSERT INTO object_geometries (object_id, geotype, angle, figure)
    VALUES (new_id, '{geom['geotype']}', {geom.get('angle', 0)}, {geom_sql});""")
        elif geom['figure']['type'] == 'LineString':
            coords = ", ".join([f"ST_MakePoint({x}, {y})" for x, y in geom['figure']['coordinates']])
            geom_sql = f"ST_SetSRID(ST_MakeLine(ARRAY[{coords}]), 4326)"
            sql.append(f"""
    INSERT INTO object_geometries (object_id, geotype, angle, figure)
    VALUES (new_id, '{geom['geotype']}', {geom.get('angle', 0)}, {geom_sql});""")
    return sql

# -------------------------------------------------------------------------------

def process_picture(pic: dict, pictures_dir: Path) -> list[str]:
    if not pic:
        return []

    path = pictures_dir / pic['picture_filename']
    if not path.exists():
        print(f"[WARN] Picture not found: {path.name}")
        return []

    with open(path, 'rb') as f:
        encoded = base64.b64encode(f.read()).decode('utf-8')

    return [f"""
    INSERT INTO object_pictures (object_id, buffer, axis_width, axis_height, scale, angle)
    VALUES (new_id, decode('{encoded}', 'base64'),
            {pic['axis_width']}, {pic['axis_height']},
            {pic.get('scale', 1)}, {pic.get('angle', 0)});"""]

# -------------------------------------------------------------------------------

if __name__ == "__main__":
    build_migration_seed()
