// ===========================================================================

use diesel::Insertable;

use crate::infrastructure::orm::{entities::types, schema};

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::objects)]
pub struct InsertObject {
    pub object_type: types::ObjectType,
    pub is_active: bool,
    pub attributes: serde_json::Value,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::object_dependencies)]
pub struct InsertObjectDependency {
    pub master_id: i32,
    pub slave_id: i32,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::object_pictures)]
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
#[diesel(table_name=schema::object_geometries)]
pub struct InsertObjectGeometry {
    pub object_id: i32,
    pub geotype: types::ObjectGeolocationType,
    pub angle: f64,
    pub figure: GeometryContainer<Point>,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::object_crossroads)]
pub struct InsertObjectCrossroad {
    pub id: i32,
    pub name: String,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::object_signals)]
pub struct InsertObjectSignal {
    pub id: i32,
    pub kind: Vec<types::ObjectSignalKind>,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::object_gateways)]
pub struct InsertObjectGateway {
    pub id: i32,
    pub is_inbound: bool,
    pub is_outbound: bool,
}

// ===========================================================================

#[derive(Debug, Insertable)]
#[diesel(table_name=schema::object_directions)]
pub struct InsertObjectDirection {
    pub id: i32,
    pub definition: types::ObjectDirectionDefinition,
}

// ===========================================================================

pub enum InsertAny {
    Object(InsertObject),
    ObjectDependency(InsertObjectDependency),
    ObjectPicture(InsertObjectPicture),
    ObjectGeometry(InsertObjectGeometry),
    ObjectCrossroad(InsertObjectCrossroad),
    ObjectSignal(InsertObjectSignal),
    ObjectGateway(InsertObjectGateway),
    ObjectDirection(InsertObjectDirection),
}
