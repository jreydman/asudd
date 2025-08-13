// ===========================================================================

use crate::{
    domain::seed::{error::Error as SeedError, schema as seed_schema},
    infrastructure::orm::entities::{
        inserts::{self as orm_inserts, InsertObjectCrossroad},
        types as orm_types,
    },
};

// == TYPE_MAPPINGS ==========================================================

fn map_object_type(obj: &seed_schema::Object) -> Result<orm_types::ObjectType, SeedError> {
    match obj {
        seed_schema::Object::Crossroad(_) => Ok(orm_types::ObjectType::Crossroad),
        seed_schema::Object::Signal(_) => Ok(orm_types::ObjectType::Signal),
        seed_schema::Object::Gateway(_) => Ok(orm_types::ObjectType::Gateway),
        seed_schema::Object::Direction(_) => Ok(orm_types::ObjectType::Direction),
        seed_schema::Object::Unknown => Err(SeedError::Validation("Unknown object type".into())),
    }
}

// ===========================================================================

fn map_signal_kinds(
    signal_kinds: &[seed_schema::types::ObjectSignalKind],
) -> Result<Vec<orm_types::ObjectSignalKind>, SeedError> {
    signal_kinds
        .iter()
        .map(|kind| match kind {
            seed_schema::types::ObjectSignalKind::Traffic => {
                Ok(orm_types::ObjectSignalKind::Traffic)
            },
            seed_schema::types::ObjectSignalKind::Pedestrian => {
                Ok(orm_types::ObjectSignalKind::Pedestrian)
            },
        })
        .collect()
}

// ===========================================================================

fn map_direction_definition(
    direction_definition: &seed_schema::types::ObjectDirectionDefinition,
) -> Result<orm_types::ObjectDirectionDefinition, SeedError> {
    match direction_definition {
        seed_schema::types::ObjectDirectionDefinition::Internal => {
            Ok(orm_types::ObjectDirectionDefinition::Internal)
        },
        seed_schema::types::ObjectDirectionDefinition::External => {
            Ok(orm_types::ObjectDirectionDefinition::External)
        },
    }
}

// ===========================================================================

fn map_geolocation_type(
    geolocation_type: &seed_schema::types::ObjectGeolocationType,
) -> Result<orm_types::ObjectGeolocationType, SeedError> {
    match geolocation_type {
        seed_schema::types::ObjectGeolocationType::Local => {
            Ok(orm_types::ObjectGeolocationType::Local)
        },
        seed_schema::types::ObjectGeolocationType::Global => {
            Ok(orm_types::ObjectGeolocationType::Global)
        },
    }
}

// ===========================================================================

fn map_figure_to_raw(f: &seed_schema::Figure) -> Result<GeometryRaw, SeedError> {
    match f {
        seed_schema::Figure::Point { coordinates } => Ok(GeometryRaw::Point(*coordinates)),
        seed_schema::Figure::LineString { coordinates } => {
            Ok(GeometryRaw::LineString(coordinates.clone()))
        },
    }
}

// == STAGE ==================================================================

pub enum GeometryRaw {
    Point([f64; 2]),
    LineString(Vec<[f64; 2]>),
}

// ===========================================================================

pub struct StagedGeometry {
    pub geotype: orm_types::ObjectGeolocationType,
    pub angle: f64,
    pub figure: GeometryRaw,
}

// ===========================================================================

pub struct StagedPicture {
    pub buffer_path: String,
    pub axis_width: i32,
    pub axis_height: i32,
    pub scale: f64,
    pub angle: f64,
}

// ===========================================================================

pub struct StagedObject {
    pub main: orm_inserts::InsertObject,
    pub geometries: Vec<StagedGeometry>,
    pub pictures: Vec<StagedPicture>,
    pub properties: StagedObjectProperties,
}

// ===========================================================================

pub enum StagedObjectProperties {
    Crossroad(orm_inserts::InsertObjectCrossroad),
    Signal(orm_inserts::InsertObjectSignal),
    Gateway(orm_inserts::InsertObjectGateway),
    Direction(orm_inserts::InsertObjectDirection),
}

// ===========================================================================

impl StagedObject {
    pub fn from_seed_object(object: &seed_schema::Object) -> Result<Self, SeedError> {
        let (object_type, properties, base) = match object {
            seed_schema::Object::Crossroad(boxed) => (
                orm_types::ObjectType::Crossroad,
                StagedObjectProperties::Crossroad(orm_inserts::InsertObjectCrossroad {
                    id: 0,
                    name: boxed.properties.name.clone(),
                }),
                &boxed.base,
            ),
            seed_schema::Object::Signal(boxed) => (
                orm_types::ObjectType::Signal,
                StagedObjectProperties::Signal(orm_inserts::InsertObjectSignal {
                    id: 0,
                    kind: map_signal_kinds(&boxed.properties.kind)?,
                }),
                &boxed.base,
            ),
            seed_schema::Object::Gateway(boxed) => (
                orm_types::ObjectType::Gateway,
                StagedObjectProperties::Gateway(orm_inserts::InsertObjectGateway {
                    id: 0,
                    is_inbound: boxed.properties.is_inbound,
                    is_outbound: boxed.properties.is_outbound,
                }),
                &boxed.base,
            ),
            seed_schema::Object::Direction(boxed) => (
                orm_types::ObjectType::Direction,
                StagedObjectProperties::Direction(orm_inserts::InsertObjectDirection {
                    id: 0,
                    definition: map_direction_definition(&boxed.properties.definition)?,
                }),
                &boxed.base,
            ),
            seed_schema::Object::Unknown => {
                return Err(SeedError::Validation("Unknown object type".into()));
            },
        };

        let main = orm_inserts::InsertObject {
            object_type,
            is_active: base.is_active,
            attributes: base.attributes.clone(),
        };

        let geometries = base
            .geometries
            .iter()
            .map(|g| {
                Ok(StagedGeometry {
                    geotype: map_geolocation_type(&g.geolocation_type)?,
                    angle: g.angle,
                    figure: map_figure_to_raw(&g.figure)?,
                })
            })
            .collect::<Result<Vec<_>, SeedError>>()?;

        let pictures = base
            .pictures
            .iter()
            .map(|p| {
                Ok(StagedPicture {
                    buffer_path: p.buffer_path.clone(),
                    axis_width: p.axis_width,
                    axis_height: p.axis_height,
                    scale: p.scale,
                    angle: p.angle,
                })
            })
            .collect::<Result<Vec<_>, SeedError>>()?;

        Ok(Self { main, geometries, pictures, properties })
    }
}

// ===========================================================================
