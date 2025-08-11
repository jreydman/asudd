use crate::orm::models::types::{
    ObjectDirectionDefinition, ObjectGeometryGeotype, ObjectGeometryType, ObjectSignalKind,
    ObjectType,
};
use serde::{Deserialize, Serialize};

mod defaults {
    use super::SeedObjectAttributes;

    pub fn scale() -> f64 {
        1.0
    }
    pub fn angle() -> f64 {
        0.0
    }
    pub fn empty_attributes() -> SeedObjectAttributes {
        SeedObjectAttributes::default()
    }
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize, Default)]
pub struct SeedObjectAttributes {
    #[serde(default)]
    pub metadata: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectPicture {
    pub buffer_path: String,
    pub axis_width: i32,
    pub axis_height: i32,
    #[serde(default = "defaults::scale")]
    pub scale: f64,
    #[serde(default = "defaults::angle")]
    pub angle: f64,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectGeometryFigure {
    #[serde(rename = "type")]
    pub figure_type: ObjectGeometryType,
    #[serde(default)]
    pub coordinates: serde_json::Value,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectGeometry {
    pub geotype: ObjectGeometryGeotype,
    pub figure: SeedObjectGeometryFigure,
    #[serde(default = "defaults::angle")]
    pub angle: f64,
}

pub trait SeedObjectTrait {
    fn rel_id(&self) -> i32;
    fn object_type(&self) -> &ObjectType;
    fn attributes(&self) -> &SeedObjectAttributes;
    fn pictures(&self) -> &[SeedObjectPicture];
    fn geometries(&self) -> &[SeedObjectGeometry];
}

// ------------------- Direction -------------------

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectDirectionProperties {
    pub definition: ObjectDirectionDefinition,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectDirection {
    pub rel_id: i32,
    #[serde(default = "default_direction_object_type")]
    pub object_type: ObjectType,
    #[serde(default = "defaults::empty_attributes")]
    pub attributes: SeedObjectAttributes,
    pub properties: SeedObjectDirectionProperties,
    #[serde(default)]
    pub pictures: Vec<SeedObjectPicture>,
    #[serde(default)]
    pub geometries: Vec<SeedObjectGeometry>,
}

fn default_direction_object_type() -> ObjectType {
    ObjectType::Direction
}

impl SeedObjectTrait for SeedObjectDirection {
    fn rel_id(&self) -> i32 {
        self.rel_id
    }
    fn object_type(&self) -> &ObjectType {
        &self.object_type
    }
    fn attributes(&self) -> &SeedObjectAttributes {
        &self.attributes
    }
    fn pictures(&self) -> &[SeedObjectPicture] {
        &self.pictures
    }
    fn geometries(&self) -> &[SeedObjectGeometry] {
        &self.geometries
    }
}

// ------------------- Signal ----------------------

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectSignalProperties {
    pub kind: Vec<ObjectSignalKind>,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectSignal {
    pub rel_id: i32,
    #[serde(default = "default_signal_object_type")]
    pub object_type: ObjectType,
    #[serde(default = "defaults::empty_attributes")]
    pub attributes: SeedObjectAttributes,
    pub properties: SeedObjectSignalProperties,
    #[serde(default)]
    pub pictures: Vec<SeedObjectPicture>,
    #[serde(default)]
    pub geometries: Vec<SeedObjectGeometry>,
}

fn default_signal_object_type() -> ObjectType {
    ObjectType::Signal
}

impl SeedObjectTrait for SeedObjectSignal {
    fn rel_id(&self) -> i32 {
        self.rel_id
    }
    fn object_type(&self) -> &ObjectType {
        &self.object_type
    }
    fn attributes(&self) -> &SeedObjectAttributes {
        &self.attributes
    }
    fn pictures(&self) -> &[SeedObjectPicture] {
        &self.pictures
    }
    fn geometries(&self) -> &[SeedObjectGeometry] {
        &self.geometries
    }
}

// ------------------- Crossroad -------------------

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize, Default)]
pub struct SeedObjectCrossroadProperties {
    #[serde(default)]
    pub name: String,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectCrossroad {
    pub rel_id: i32,
    #[serde(default = "default_crossroad_object_type")]
    pub object_type: ObjectType,
    #[serde(default = "defaults::empty_attributes")]
    pub attributes: SeedObjectAttributes,
    pub properties: SeedObjectCrossroadProperties,
    #[serde(default)]
    pub pictures: Vec<SeedObjectPicture>,
    #[serde(default)]
    pub geometries: Vec<SeedObjectGeometry>,
}

fn default_crossroad_object_type() -> ObjectType {
    ObjectType::Crossroad
}

impl SeedObjectTrait for SeedObjectCrossroad {
    fn rel_id(&self) -> i32 {
        self.rel_id
    }
    fn object_type(&self) -> &ObjectType {
        &self.object_type
    }
    fn attributes(&self) -> &SeedObjectAttributes {
        &self.attributes
    }
    fn pictures(&self) -> &[SeedObjectPicture] {
        &self.pictures
    }
    fn geometries(&self) -> &[SeedObjectGeometry] {
        &self.geometries
    }
}

// ------------------- Gateway -------------------

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize, Default)]
pub struct SeedObjectGatewayProperties {
    #[serde(default)]
    pub is_inbound: bool,
    #[serde(default)]
    pub is_outbound: bool,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct SeedObjectGateway {
    pub rel_id: i32,
    #[serde(default = "default_gateway_object_type")]
    pub object_type: ObjectType,
    #[serde(default = "defaults::empty_attributes")]
    pub attributes: SeedObjectAttributes,
    pub properties: SeedObjectGatewayProperties,
    #[serde(default)]
    pub pictures: Vec<SeedObjectPicture>,
    #[serde(default)]
    pub geometries: Vec<SeedObjectGeometry>,
}

fn default_gateway_object_type() -> ObjectType {
    ObjectType::Gateway
}

impl SeedObjectTrait for SeedObjectGateway {
    fn rel_id(&self) -> i32 {
        self.rel_id
    }
    fn object_type(&self) -> &ObjectType {
        &self.object_type
    }
    fn attributes(&self) -> &SeedObjectAttributes {
        &self.attributes
    }
    fn pictures(&self) -> &[SeedObjectPicture] {
        &self.pictures
    }
    fn geometries(&self) -> &[SeedObjectGeometry] {
        &self.geometries
    }
}

// ------------------- SeedObject enum -------------------

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "object_type", rename_all = "snake_case")]
pub enum SeedObject {
    Crossroad(SeedObjectCrossroad),
    Gateway(SeedObjectGateway),
    Signal(SeedObjectSignal),
    #[serde(other)]
    Unknown,
}

impl SeedObject {
    pub fn as_trait(&self) -> Option<&dyn SeedObjectTrait> {
        match self {
            SeedObject::Crossroad(o) => Some(o),
            SeedObject::Gateway(o) => Some(o),
            SeedObject::Signal(o) => Some(o),
            SeedObject::Unknown => None,
        }
    }
}

// ------------------- SeedObjectDependency -------------------

#[derive(Debug, Clone, Deserialize, Serialize, Default)]
pub struct SeedObjectDependency {
    pub master_id: i32,
    #[serde(default)]
    pub slave_ids: Vec<i32>,
}

// ------------------- SeedRoot -------------------

#[derive(Debug, Clone, Deserialize, Serialize, Default)]
pub struct SeedRoot {
    #[serde(default)]
    pub objects: Vec<SeedObject>,
    #[serde(default)]
    pub object_dependencies: Vec<SeedObjectDependency>,
}
