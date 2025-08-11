use crate::orm::helpers::seed_insertable::{ChildInsertable, Insertable};
use crate::orm::models;
use crate::orm::schema;
use crate::orm::seed::schema as seed_schema;
use diesel::{Connection, RunQueryDsl};

pub fn insert_seed(
    root: seed_schema::SeedRoot,
    connection: &mut diesel::PgConnection,
) -> diesel::QueryResult<()> {
    connection.transaction(move |connection| {
        for seed_object in &root.objects {
            // ---------------------------------------------------------------------------------

            let insert_object = seed_object.to_insert();
            let object_id: i32 = diesel::insert_into(schema::objects::table)
                .values(&insert_object)
                .on_conflict_do_nothing()
                .returning(schema::objects::id) // важно возвращать id!
                .get_result(connection)
                .unwrap();

            // ---------------------------------------------------------------------------------

            match &seed_object {
                seed_schema::SeedObject::Crossroad(crossroad) => {
                    let insert_object_crossroad = crossroad.properties.to_insert(object_id);
                    diesel::insert_into(schema::object_crossroads::table)
                        .values(&insert_object_crossroad)
                        .on_conflict_do_nothing()
                        .execute(connection)
                        .unwrap();
                }
                seed_schema::SeedObject::Gateway(gateway) => {
                    let insert_object_gateway = gateway.properties.to_insert(object_id);
                    diesel::insert_into(schema::object_gateways::table)
                        .values(&insert_object_gateway)
                        .on_conflict_do_nothing()
                        .execute(connection)
                        .unwrap();
                }
                seed_schema::SeedObject::Signal(signal) => {
                    let insert_object_signal = signal.properties.to_insert(object_id);
                    diesel::insert_into(schema::object_signals::table)
                        .values(&insert_object_signal)
                        .on_conflict_do_nothing()
                        .execute(connection)
                        .unwrap();
                }
                seed_schema::SeedObject::Unknown => {}
            }

            // ---------------------------------------------------------------------------------

            let seed_object_trait = seed_object.as_trait().unwrap();

            // ---------------------------------------------------------------------------------

            for picture in seed_object_trait.pictures() {
                let insert_object_picture = picture.to_insert(object_id);
                diesel::insert_into(schema::object_pictures::table)
                    .values(&insert_object_picture)
                    .on_conflict_do_nothing()
                    .execute(connection)
                    .unwrap();
            }

            // ---------------------------------------------------------------------------------

            for geometry in seed_object_trait.geometries() {
                use models::types::ObjectGeometryType;
                use postgis_diesel::types::{LineString, Point};
                if geometry.figure.figure_type != ObjectGeometryType::Point {
                    continue;
                }
                let insert_object_geometry: models::object_geometry::InsertObjectGeometry<Point> =
                    geometry.to_insert(object_id);

                diesel::insert_into(schema::object_geometries::table)
                    .values(&insert_object_geometry)
                    .on_conflict_do_nothing()
                    .execute(connection)
                    .unwrap();
            }

            // ---------------------------------------------------------------------------------
        }

        Ok(())
    })
}
