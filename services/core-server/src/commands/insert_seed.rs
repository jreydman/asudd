use crate::orm::model as orm_model;
use crate::orm::schema as orm_schema;
use crate::seed::schema as seed_schema;

// ===========================================================================

use crate::orm::convertion::TryFromWithID;
use crate::seed::insertable::{ChildInsertable, Insertable};
use diesel::ExpressionMethods;
use diesel::{Connection, RunQueryDsl};
use std::error::Error;

// ===========================================================================

pub fn insert_seed(
    path: &str,
    connection: &mut diesel::PgConnection,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    let seed_string = std::fs::read_to_string(path)?;
    let seed = serde_json::from_str::<seed_schema::Seed>(&seed_string)?;

    let mut inserted_object_relmap = std::collections::HashMap::<u32, i32>::new();

    for object in seed.objects.into_iter() {
        let object_id = object.insert(connection)?;

        match &object {
            seed_schema::Object::Crossroad(data) => {
                inserted_object_relmap.insert(data.rel_id, object_id);
                data.insert(object_id, connection)?;
                for picture in &data.pictures {
                    picture.insert(object_id, connection)?;
                }
                for geometry in &data.geometries {
                    geometry.insert(object_id, connection)?;
                }
            }
            seed_schema::Object::Signal(data) => {
                inserted_object_relmap.insert(data.rel_id, object_id);
                data.insert(object_id, connection)?;
                for picture in &data.pictures {
                    picture.insert(object_id, connection)?;
                }
                for geometry in &data.geometries {
                    geometry.insert(object_id, connection)?;
                }
            }
            seed_schema::Object::Gateway(data) => {
                inserted_object_relmap.insert(data.rel_id, object_id);
                data.insert(object_id, connection)?;
                for picture in &data.pictures {
                    picture.insert(object_id, connection)?;
                }
                for geometry in &data.geometries {
                    geometry.insert(object_id, connection)?;
                }
            }
            seed_schema::Object::Direction(data) => {
                inserted_object_relmap.insert(data.rel_id, object_id);
                data.insert(object_id, connection)?;
                for picture in &data.pictures {
                    picture.insert(object_id, connection)?;
                }
                for geometry in &data.geometries {
                    geometry.insert(object_id, connection)?;
                }
            }
        }
    }

    println!("Inserted seed objects: {:?}", inserted_object_relmap);

    for dependency in seed.dependencies.into_iter() {
        let master_id = *inserted_object_relmap
            .get(&dependency.master_id)
            .ok_or_else(|| format!("master rel_id {} not found", dependency.master_id))?;

        for slave_rel_id in dependency.slave_ids {
            let slave_id = *inserted_object_relmap
                .get(&slave_rel_id)
                .ok_or_else(|| format!("slave rel_id {} not found", slave_rel_id))?;

            diesel::insert_into(orm_schema::object_dependencies::table)
                .values((
                    orm_schema::object_dependencies::master_id.eq(master_id),
                    orm_schema::object_dependencies::slave_id.eq(slave_id),
                ))
                .execute(connection)?;
        }
    }

    println!("Inserted seed object dependencies",);

    inserted_object_relmap.clear();

    Ok(())
}

// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use std::error::Error;

    #[test]
    fn seed_insertion() -> Result<(), Box<dyn Error + Send + Sync>> {
        // Given

        dotenvy::dotenv().unwrap();

        let path = "data/seed/00__seed.json".to_owned();
        let client = crate::orm::database::DatabaseClient::new()?;
        let mut connection = client.get_connection()?;

        // When

        connection.test_transaction(move |connection| insert_seed(&path, connection));

        // Then

        Ok(())
    }
}
