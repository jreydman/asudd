import shutil
from pathlib import Path

# ------------------------------------------------------------------------------

def build_migration_up():

    root = Path(__file__).resolve().parents[2]
    sql_src = root / 'sql_src'
    output_file = sql_src / 'up.sql'
    terminal_width = shutil.get_terminal_size((80, 20)).columns

    sql_files = sorted(
        f for d in ['tables', 'functions', 'triggers']
        for f in (sql_src / d).glob('*.sql')
        if f.name[:2].isdigit()
    )

    with output_file.open('w', encoding='utf-8') as out:
        for path in sql_files:
            out.write(f"-- {path.relative_to(sql_src)}\n")
            out.write(path.read_text(encoding='utf-8').strip() + "\n\n")

    print('=' * terminal_width)
    print(f"Composed {len(sql_files)} files into: {output_file.relative_to(root)}")
    print('=' * terminal_width)

# ------------------------------------------------------------------------------

build_migration_up()
