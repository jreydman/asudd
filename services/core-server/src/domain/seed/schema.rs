// ===========================================================================

use std::{fs, path};

use serde::{Deserialize, Serialize};

use crate::domain::seed::error;

// == TYPES ==================================================================

pub mod types {
    use super::*;

    #[derive(Debug, Deserialize, Serialize)]
    #[serde(rename_all = "snake_case")]
    pub enum ObjectGeolocationType {
        Global,
        Local,
    }

    #[derive(Debug, Deserialize, Serialize)]
    #[serde(rename_all = "snake_case")]
    pub enum ObjectDirectionDefinition {
        Internal,
        External,
    }

    #[derive(Debug, Deserialize, Serialize)]
    #[serde(rename_all = "snake_case")]
    pub enum ObjectSignalKind {
        Traffic,
        Pedestrian,
    }
}

// == DEFAULTS ===============================================================

pub mod defaults {
    pub fn default_angle() -> f64 {
        0.0
    }

    pub fn default_scale() -> f64 {
        1.0
    }

    pub fn default_attributes() -> serde_json::Value {
        serde_json::json!({})
    }
    pub fn default_active() -> bool {
        true
    }
}

// == OBJECT_PROPERTIES ======================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct CrossroadProperties {
    pub name: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct SignalProperties {
    pub kind: Vec<types::ObjectSignalKind>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct GatewayProperties {
    pub is_inbound: bool,
    pub is_outbound: bool,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct DirectionProperties {
    pub definition: types::ObjectDirectionDefinition,
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
pub enum ObjectProperties {
    Crossroad(CrossroadProperties),
    Signal(SignalProperties),
    Gateway(GatewayProperties),
    Direction(DirectionProperties),
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct Picture {
    pub buffer_path: String,
    pub axis_width: i32,
    pub axis_height: i32,
    #[serde(default = "defaults::default_angle")]
    pub angle: f64,
    #[serde(default = "defaults::default_scale")]
    pub scale: f64,
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
#[serde(tag = "figure_type")]
pub enum Figure {
    Point { coordinates: [f64; 2] },
    LineString { coordinates: Vec<[f64; 2]> },
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct Geometry {
    pub geolocation_type: types::ObjectGeolocationType,
    pub figure: Figure,
    #[serde(default = "defaults::default_angle")]
    pub angle: f64,
}

// == DATA_STRUCTURES ========================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct ObjectData {
    pub rel_id: u32,
    #[serde(default = "defaults::default_attributes")]
    pub attributes: serde_json::Value,
    #[serde(default = "defaults::default_active")]
    pub is_active: bool,
    #[serde(default)]
    pub geometries: Vec<Geometry>,
    #[serde(default)]
    pub pictures: Vec<Picture>,
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct ObjectWithProperties<T> {
    #[serde(flatten)]
    pub base: ObjectData,
    pub properties: T,
}

pub type CrossroadData = ObjectWithProperties<CrossroadProperties>;
pub type SignalData = ObjectWithProperties<SignalProperties>;
pub type GatewayData = ObjectWithProperties<GatewayProperties>;
pub type DirectionData = ObjectWithProperties<DirectionProperties>;

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
#[serde(tag = "object_type", rename_all = "snake_case")]
pub enum Object {
    Crossroad(Box<CrossroadData>),
    Signal(Box<SignalData>),
    Gateway(Box<GatewayData>),
    Direction(Box<DirectionData>),
    #[serde(other)]
    Unknown,
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct ObjectDependent {
    pub master_id: u32,
    #[serde(default)]
    pub slave_ids: Vec<u32>,
}

// ===========================================================================

#[derive(Debug, Deserialize, Serialize)]
pub struct Seed {
    #[serde(default)]
    pub objects: Vec<Object>,
    #[serde(default)]
    pub dependencies: Vec<ObjectDependent>,
}

// ===========================================================================

impl Seed {
    pub fn from_file(path: &path::PathBuf) -> Result<Self, error::Error> {
        let seed_string = fs::read_to_string(path)?;
        let seed: Self = serde_json::from_str(&seed_string)?;

        Ok(seed)
    }
}

// ===========================================================================
