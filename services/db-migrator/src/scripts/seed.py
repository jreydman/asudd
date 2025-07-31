import shutil
from pathlib import Path
from src.database import client

# ------------------------------------------------------------------------------

def seed():
    terminal_width = shutil.get_terminal_size((100, 20)).columns
    root = Path(__file__).resolve().parents[2]
    seed_dir = root / "sql_src" / "seed"
    connection = client()

    sql_files = sorted(seed_dir.glob("*.sql"))

    with connection, connection.cursor() as cursor:
        for path in sql_files:
            sql = path.read_text(encoding="utf-8")
            cursor.execute(sql)
            print(f"Executed {path.relative_to(root)}")

    connection.close()
    print("=" * terminal_width)
    print(f"Seeded {len(sql_files)} files from {seed_dir.relative_to(root)}")
    print("=" * terminal_width)

# ------------------------------------------------------------------------------

seed()
