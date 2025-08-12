use crate::orm::model as orm_model;
use crate::orm::schema as orm_schema;

// ===========================================================================

use serde::{Deserialize, Serialize};

// ===========================================================================

mod defaults {
    use super::*;
    pub fn default_angle() -> f64 {
        0.0
    }

    pub fn default_scale() -> f64 {
        1.0
    }

    pub fn default_attributes() -> serde_json::Value {
        serde_json::json!({})
    }
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Seed {
    #[serde(default)]
    pub objects: Vec<Object>,
    #[serde(default)]
    pub dependencies: Vec<Dependency>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Dependency {
    pub master_id: u32,
    pub slave_ids: Vec<u32>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct CrossroadProperties {
    pub name: String,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct SignalProperties {
    #[serde(default)]
    pub kind: Vec<orm_model::ObjectSignalKind>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct GatewayProperties {
    pub is_inbound: bool,
    pub is_outbound: bool,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct DirectionProperties {
    pub definition: orm_model::ObjectDirectionDefinition,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
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

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Geometry {
    pub geolocation_type: orm_model::ObjectGeolocationType,
    pub figure: Figure,
    #[serde(default = "defaults::default_angle")]
    pub angle: f64,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
#[serde(tag = "figure_type")]
pub enum Figure {
    #[serde(rename = "Point")]
    Point { coordinates: [f64; 2] },
    #[serde(rename = "LineString")]
    LineString { coordinates: Vec<[f64; 2]> },
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct CrossroadData {
    pub rel_id: u32,
    #[serde(default = "defaults::default_attributes")]
    pub attributes: serde_json::Value,
    #[serde(default)]
    pub is_active: bool,
    pub properties: CrossroadProperties,
    #[serde(default)]
    pub geometries: Vec<Geometry>,
    #[serde(default)]
    pub pictures: Vec<Picture>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct SignalData {
    pub rel_id: u32,
    #[serde(default = "defaults::default_attributes")]
    pub attributes: serde_json::Value,
    #[serde(default)]
    pub is_active: bool,
    pub properties: SignalProperties,
    #[serde(default)]
    pub geometries: Vec<Geometry>,
    #[serde(default)]
    pub pictures: Vec<Picture>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct GatewayData {
    pub rel_id: u32,
    #[serde(default = "defaults::default_attributes")]
    pub attributes: serde_json::Value,
    #[serde(default)]
    pub is_active: bool,
    pub properties: GatewayProperties,
    #[serde(default)]
    pub geometries: Vec<Geometry>,
    #[serde(default)]
    pub pictures: Vec<Picture>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct DirectionData {
    pub rel_id: u32,
    #[serde(default = "defaults::default_attributes")]
    pub attributes: serde_json::Value,
    #[serde(default)]
    pub is_active: bool,
    pub properties: DirectionProperties,
    #[serde(default)]
    pub geometries: Vec<Geometry>,
    #[serde(default)]
    pub pictures: Vec<Picture>,
}

// ===========================================================================

#[derive(Deserialize, Serialize, Debug, Clone)]
#[serde(tag = "object_type")]
pub enum Object {
    #[serde(rename = "crossroad")]
    Crossroad(Box<CrossroadData>),
    #[serde(rename = "signal")]
    Signal(Box<SignalData>),
    #[serde(rename = "gateway")]
    Gateway(Box<GatewayData>),
    #[serde(rename = "direction")]
    Direction(Box<DirectionData>),
}

// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use std::error::Error;

    #[test]
    fn seed_deserialization() -> Result<(), Box<dyn Error>> {
        // Given
        let seed_string = std::fs::read_to_string("data/seed/00__seed.json")?;

        // When
        let seed = serde_json::from_str::<Seed>(&seed_string);

        // Then
        assert!(seed.is_ok(), "Seed cannot be deserialized");

        Ok(())
    }
}

// ===========================================================================
