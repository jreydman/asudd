SQL_CONFIG = "host=localhost port=5432 dbname=assud user=admin password=admin"

PGQUERY = psql -d $(SQL_CONFIG)
PGDUMP = pg_dump -d $(SQL_CONFIG) --schema-only

SQL_DIR = ./sql_sqc

clear:
	@clear

# ------------------------------------------------------------------------------

build-migration-up: clear
	@uv run python -m src.scripts.build_migration_up

build-migration-seed: clear
	@uv run python -m src.scripts.build_migration_seed

up: clear build-migration-up
	@uv run python -m src.scripts.up

seed: clear build-migration-seed
	@uv run python -m src.scripts.seed

truncate: clear
	@uv run python -m src.scripts.truncate

# ------------------------------------------------------------------------------

%:
	@:
