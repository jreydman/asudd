import shutil
from pathlib import Path
from src.database import client

# ------------------------------------------------------------------------------


def truncate():
    root = Path(__file__).resolve().parents[2]
    truncate_sql_path = root / "sql_src" / "queries" / "truncate_tables.sql"
    rel_path = truncate_sql_path.relative_to(root)

    print(f"[INFO] Executing truncate script: {rel_path}")
    sql = truncate_sql_path.read_text(encoding="utf-8")

    connection = client()
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

    print("=" * shutil.get_terminal_size((100, 20)).columns)
    print(f"[DONE] Executed {rel_path} successfully")


# ------------------------------------------------------------------------------

if __name__ == "__main__":
    truncate()
