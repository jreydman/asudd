// ===========================================================================

use diesel::{Connection, ExpressionMethods, PgConnection, RunQueryDsl};
use postgis_diesel::types as postgis_types;

use crate::{
    domain::seed::{
        error::Error as SeedError, repository::Repository as SeedRepository, schema::Seed,
    },
    infrastructure::orm::{
        conversions::seed::stage_converter::{
            GeometryRaw as StagedGeometryRaw, StagedObject, StagedObjectProperties,
        },
        entities::{inserts as orm_inserts, types as orm_types},
        error::RepositoryError,
        schema as orm_schema,
    },
};

// ===========================================================================

pub struct DieselRepository<'a> {
    connection: &'a mut diesel::PgConnection,
}

// ===========================================================================

impl<'a> DieselRepository<'a> {
    pub fn new(connection: &'a mut diesel::PgConnection) -> Self {
        Self { connection }
    }

    pub fn insert_dependency_relation(
        &mut self,
        master_id: i32,
        slave_id: i32,
    ) -> Result<(), RepositoryError> {
        diesel::insert_into(orm_schema::object_dependencies::table)
            .values((
                orm_schema::object_dependencies::master_id.eq(master_id),
                orm_schema::object_dependencies::slave_id.eq(slave_id),
            ))
            .execute(self.connection)?;
        Ok(())
    }

    pub fn insert_staged_object(
        &mut self,
        staged_object: &mut StagedObject,
    ) -> Result<i32, RepositoryError> {
        let object_id: i32 = diesel::insert_into(orm_schema::objects::table)
            .values(&staged_object.main)
            .returning(orm_schema::objects::id)
            .get_result(self.connection)?;

        match &mut staged_object.properties {
            StagedObjectProperties::Crossroad(properties) => properties.id = object_id,
            StagedObjectProperties::Signal(properties) => properties.id = object_id,
            StagedObjectProperties::Gateway(properties) => properties.id = object_id,
            StagedObjectProperties::Direction(properties) => properties.id = object_id,
        }

        for picture in &staged_object.pictures {
            diesel::insert_into(orm_schema::object_pictures::table)
                .values(orm_inserts::InsertObjectPicture {
                    object_id,
                    buffer: std::fs::read(picture.buffer_path.clone())?,
                    axis_width: picture.axis_width,
                    axis_height: picture.axis_height,
                    scale: picture.scale,
                    angle: picture.angle,
                })
                .execute(self.connection)?;
        }

        for geometry in &staged_object.geometries {
            let figure: postgis_types::GeometryContainer<postgis_types::Point> =
                match &geometry.figure {
                    StagedGeometryRaw::Point(coordinates) => {
                        postgis_types::GeometryContainer::Point(postgis_types::Point {
                            x: coordinates[0],
                            y: coordinates[1],
                            srid: Some(4326),
                        })
                    },
                    StagedGeometryRaw::LineString(coordinates) => {
                        let points: Vec<postgis_types::Point> = coordinates
                            .iter()
                            .map(|coord| postgis_types::Point {
                                x: coord[0],
                                y: coord[1],
                                srid: Some(4326),
                            })
                            .collect();

                        postgis_types::GeometryContainer::LineString(postgis_types::LineString {
                            points,
                            srid: Some(4326),
                        })
                    },
                };

            diesel::insert_into(orm_schema::object_geometries::table)
                .values(orm_inserts::InsertObjectGeometry {
                    object_id,
                    geotype: geometry.geotype.clone(),
                    angle: geometry.angle,
                    figure,
                })
                .execute(self.connection)?;
        }

        Ok(object_id)
    }
}

// ===========================================================================

impl<'a> SeedRepository for DieselRepository<'a> {
    fn insert(&mut self, seed: &Seed) -> Result<(), SeedError> {
        let mut id_map = std::collections::HashMap::<u32, i32>::new();

        for object in &seed.objects {
            let mut staged = StagedObject::from_seed_object(object)?;
            let object_id = self
                .insert_staged_object(&mut staged)
                .map_err(|e| SeedError::Infrastructure(format!("DB insert failed: {}", e)))?;

            id_map.insert(object.rel_id(), object_id);
        }

        for dep in &seed.dependencies {
            let master_id = id_map.get(&dep.master_id).ok_or_else(|| {
                SeedError::Infrastructure(format!(
                    "Master rel_id {} not found in inserted objects",
                    dep.master_id
                ))
            })?;

            for slave_rel_id in &dep.slave_ids {
                let slave_id = id_map.get(slave_rel_id).ok_or_else(|| {
                    SeedError::Infrastructure(format!(
                        "Slave rel_id {} not found in inserted objects",
                        slave_rel_id
                    ))
                })?;
                self.insert_dependency_relation(*master_id, *slave_id).map_err(|e| {
                    SeedError::Infrastructure(format!("Dependency insert failed: {}", e))
                })?;
            }
        }

        Ok(())
    }

    fn insert_many(&mut self, seeds: &[Seed]) -> Result<(), SeedError> {
        for seed in seeds {
            self.insert(seed)?;
        }

        Ok(())
    }
}

// ===========================================================================
