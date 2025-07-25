SQL_CONFIG = "host=localhost port=5432 dbname=assud user=admin password=admin"

PSQL = psql -d $(SQL_CONFIG)
DUMP = pg_dump -d $(SQL_CONFIG) --schema-only

VERSION = 1

clear:
	@clear

# V1 ---------------------------------------------------------------------------

up: clear
	@$(PSQL) -f ./src-${VERSION}/tables/tb_crossroads.sql
	@$(PSQL) -f ./src-${VERSION}/tables/tb_crossroad_objects.sql
	@$(PSQL) -f ./src-${VERSION}/tables/tb_crossroad_ports.sql
	@$(PSQL) -f ./src-${VERSION}/tables/tb_crossroad_signals.sql
	@$(PSQL) -f ./src-${VERSION}/tables/tb_port_connections.sql
	@$(PSQL) -f ./src-${VERSION}/tables/tb_crossroad_signal_connection_controls.sql
	@$(PSQL) -f ./src-${VERSION}/tables/tb_crossroad_object_geometries.sql
	@$(PSQL) -f ./src-${VERSION}/functions/func__set_updated_at_timestamp.sql
	@$(PSQL) -f ./src-${VERSION}/functions/func__add_crossroad_port.sql
	@$(PSQL) -f ./src-${VERSION}/functions/func__add_crossroad_signal.sql
	@$(PSQL) -f ./src-${VERSION}/functions/func__add_port_connection.sql
	@$(PSQL) -f ./src-${VERSION}/functions/tfunc__create_internal_connections.sql
	@$(PSQL) -f ./src-${VERSION}/triggres.sql

down: clear
	@$(PSQL) -f ./src-${VERSION}/down.sql

seed: clear
	@$(PSQL) -f ./src-${VERSION}/seed.sql

# V2 ---------------------------------------------------------------------------

# ------------------------------------------------------------------------------

%:
	@:
