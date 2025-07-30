SQL_CONFIG = "host=localhost port=5432 dbname=assud user=admin password=admin"

PGQUERY = psql -d $(SQL_CONFIG)
PGDUMP = pg_dump -d $(SQL_CONFIG) --schema-only

SQL_DIR = ./src-v2

clear:
	@clear

# ------------------------------------------------------------------------------

up: clear combine
	@$(PGQUERY) -f ${SQL_DIR}/up.sql

down: clear
	@$(PGQUERY) -f ${SQL_DIR}/down.sql

seed: clear
	@$(PGQUERY) -f ${SQL_DIR}/seed.sql

# ------------------------------------------------------------------------------

combine:
	@echo "-- Combined SQL file generated on $(shell date)" > ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_objects.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_crossroads.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_signals.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_directions.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_gateways.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_geometries.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_pictures.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/tables/tb_object_dependencies.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/functions/tfunc__set_updated_at.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/functions/tfunc__validate_object_type_auto.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/functions/func__add_crossroad.sql >> ${SQL_DIR}/up.sql
	@echo "" >> ${SQL_DIR}/up.sql

	@cat ${SQL_DIR}/triggers.sql >> ${SQL_DIR}/up.sql

	@echo "Combined SQL file created at ${SQL_DIR}/up.sql"

# ------------------------------------------------------------------------------

%:
	@:
