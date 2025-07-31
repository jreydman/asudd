import shutil
from pathlib import Path
from src.database import client

# ------------------------------------------------------------------------------

def up():
    terminal_width = shutil.get_terminal_size((100, 20)).columns
    root = Path(__file__).resolve().parents[2]
    up_sql_path = root / "sql_src" / "up.sql"
    up_sql = up_sql_path.read_text(encoding="utf-8")

    connection = client()

    with connection, connection.cursor() as cursor:
        cursor.execute(up_sql)
    connection.close()

    print("=" * terminal_width)
    print(f"Executed {up_sql_path} successfully")
    print("=" * terminal_width)

# ------------------------------------------------------------------------------

up()
