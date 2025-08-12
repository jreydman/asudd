use crate::orm::schema as orm_schema;
use diesel::prelude::*;
use diesel_derive_enum::DbEnum;
use serde::{Deserialize, Serialize};

// == TYPES ==================================================================

#[derive(DbEnum, Debug, Clone, PartialEq)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "orm_schema::sql_types::ObjectType"]
pub enum ObjectType {
    Crossroad,
    Signal,
    Direction,
    Gateway,
}

// ===========================================================================

#[derive(diesel_derive_enum::DbEnum, Debug, Clone, PartialEq, Deserialize, Serialize)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "orm_schema::sql_types::ObjectDirectionDefinition"]
pub enum ObjectDirectionDefinition {
    #[serde(rename = "internal")]
    Internal,
    #[serde(rename = "external")]
    External,
}

// ===========================================================================

#[derive(diesel_derive_enum::DbEnum, Debug, Clone, PartialEq, Deserialize, Serialize)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "orm_schema::sql_types::ObjectGeolocationType"]
pub enum ObjectGeolocationType {
    #[serde(rename = "local")]
    Local,
    #[serde(rename = "global")]
    Global,
}

// ===========================================================================

#[derive(diesel_derive_enum::DbEnum, Debug, Clone, PartialEq, Deserialize, Serialize)]
#[DbValueStyle = "snake_case"]
#[ExistingTypePath = "orm_schema::sql_types::ObjectSignalKind"]
pub enum ObjectSignalKind {
    #[serde(rename = "traffic")]
    Traffic,
    #[serde(rename = "pedestrian")]
    Pedestrian,
}

// == INSERT OBJECTS =========================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::objects)]
pub struct InsertObject {
    pub object_type: ObjectType,
    pub is_active: bool,
    pub attributes: serde_json::Value,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_dependencies)]
pub struct InsertObjectDependency {
    pub master_id: i32,
    pub slave_id: i32,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_pictures)]
pub struct InsertObjectPicture {
    pub object_id: i32,
    pub buffer: Vec<u8>,
    pub axis_width: i32,
    pub axis_height: i32,
    pub scale: f64,
    pub angle: f64,
}

// ===========================================================================

use postgis_diesel::types::{GeometryContainer, LineString, Point};

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_geometries)]
pub struct InsertObjectGeometry {
    pub object_id: i32,
    pub geotype: ObjectGeolocationType,
    pub angle: f64,
    pub figure: GeometryContainer<Point>,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_crossroads)]
pub struct InsertObjectCrossroad {
    pub id: i32,
    pub name: String,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_signals)]
pub struct InsertObjectSignal {
    pub id: i32,
    pub kind: Vec<ObjectSignalKind>,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_gateways)]
pub struct InsertObjectGateway {
    pub id: i32,
    pub is_inbound: bool,
    pub is_outbound: bool,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=orm_schema::object_directions)]
pub struct InsertObjectDirection {
    pub id: i32,
    pub definition: ObjectDirectionDefinition,
}

// ===========================================================================
