use diesel_derive_enum::DbEnum;
use serde::{Deserialize, Serialize};

// ------------------------------------------------------------------------------------------------

#[derive(DbEnum, Deserialize, PartialEq, Serialize, Debug, Clone, Copy)]
#[serde(rename_all = "snake_case")]
#[ExistingTypePath = "crate::orm::schema::sql_types::ObjectType"]
pub enum ObjectType {
    Crossroad,
    Signal,
    Direction,
    Gateway,
}

// ------------------------------------------------------------------------------------------------

#[derive(DbEnum, Deserialize, PartialEq, Serialize, Debug, Clone, Copy)]
#[serde(rename_all = "snake_case")]
#[ExistingTypePath = "crate::orm::schema::sql_types::ObjectGeometryGeotype"]
pub enum ObjectGeometryGeotype {
    Local,
    Global,
}

// ------------------------------------------------------------------------------------------------

#[derive(DbEnum, Deserialize, PartialEq, Serialize, Debug, Clone, Copy)]
#[serde(rename_all = "snake_case")]
#[ExistingTypePath = "crate::orm::schema::sql_types::ObjectSignalKind"]
pub enum ObjectSignalKind {
    Traffic,
    Pedestrian,
}

// ------------------------------------------------------------------------------------------------

#[derive(DbEnum, Deserialize, PartialEq, Serialize, Debug, Clone, Copy)]
#[serde(rename_all = "snake_case")]
#[ExistingTypePath = "crate::orm::schema::sql_types::ObjectDirectionDefinition"]
pub enum ObjectDirectionDefinition {
    Internal,
    External,
}

// ------------------------------------------------------------------------------------------------

#[derive(Deserialize, PartialEq, Serialize, Debug, Clone, Copy)]
pub enum ObjectGeometryType {
    Point,
    LineString
}
