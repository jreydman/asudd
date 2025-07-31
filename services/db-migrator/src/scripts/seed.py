import shutil
from pathlib import Path
from src.database import client

# -------------------------------------------------------------------------------

def seed():
    root = Path(__file__).resolve().parents[2]
    seed_dir = root / "sql_src" / "seed"
    sql_files = sorted(seed_dir.glob("*.sql"))

    print(f"[INFO] Found {len(sql_files)} SQL file(s) in: {seed_dir}")

    connection = client()
    with connection, connection.cursor() as cursor:
        for path in sql_files:
            rel_path = path.relative_to(root)
            print(f"[INFO] Executing: {rel_path}")
            sql = path.read_text(encoding="utf-8")
            cursor.execute(sql)
            print(f"[SUCCESS] Executed: {rel_path}")

    print("=" * shutil.get_terminal_size((100, 20)).columns)
    print(f"[DONE] Seeded {len(sql_files)} file(s) from: {seed_dir.relative_to(root)}")

# -------------------------------------------------------------------------------

if __name__ == "__main__":
    seed()
