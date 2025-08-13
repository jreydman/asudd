// ===========================================================================

use diesel_derive_enum::DbEnum;

use crate::infrastructure::orm::schema;

// ===========================================================================

#[derive(DbEnum, Debug, Clone, PartialEq)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "schema::sql_types::ObjectType"]
pub enum ObjectType {
    Crossroad,
    Signal,
    Direction,
    Gateway,
}

// ===========================================================================

#[derive(DbEnum, Debug, Clone, PartialEq)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "schema::sql_types::ObjectDirectionDefinition"]
pub enum ObjectDirectionDefinition {
    Internal,
    External,
}

// ===========================================================================

#[derive(DbEnum, Debug, Clone, PartialEq)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "schema::sql_types::ObjectGeolocationType"]
pub enum ObjectGeolocationType {
    Local,
    Global,
}

// ===========================================================================

#[derive(DbEnum, Debug, Clone, PartialEq)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "schema::sql_types::ObjectSignalKind"]
pub enum ObjectSignalKind {
    Traffic,
    Pedestrian,
}

// ===========================================================================
