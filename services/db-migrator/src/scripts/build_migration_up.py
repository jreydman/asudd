import shutil
from pathlib import Path

# -------------------------------------------------------------------------------


def build_migration_up():
    root = Path(__file__).resolve().parents[2]
    sql_src = root / "sql_src"
    output_file = sql_src / "up.sql"

    directories = ["tables", "functions", "triggers"]
    sql_files = sorted(
        f
        for d in directories
        for f in (sql_src / d).glob("*.sql")
        if f.name[:2].isdigit()
    )

    print(f"[INFO] Found {len(sql_files)} SQL file(s) from: {', '.join(directories)}")

    with output_file.open("w", encoding="utf-8") as out:
        for path in sql_files:
            rel_path = path.relative_to(sql_src)
            out.write(f"-- {rel_path}\n")
            out.write(path.read_text(encoding="utf-8").strip() + "\n\n")
            print(f"[SUCCESS] Added: {rel_path}")

    print("=" * shutil.get_terminal_size((80, 20)).columns)
    print(
        f"[DONE] Composed {len(sql_files)} file(s) into: {output_file.relative_to(root)}"
    )


# -------------------------------------------------------------------------------

if __name__ == "__main__":
    build_migration_up()
