use crate::orm::model as orm_model;
use crate::orm::schema as orm_schema;
use crate::seed::schema as seed_schema;
use postgis_diesel::types as postgis_model;

// ===========================================================================

pub trait TryFromWithID<T>: Sized {
    type Error;
    fn try_from_with_id(value: T, object_id: i32) -> Result<Self, Self::Error>;
}

// ===========================================================================

impl TryFrom<&seed_schema::Object> for orm_model::InsertObject {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from(value: &seed_schema::Object) -> Result<Self, Self::Error> {
        let (object_type, is_active, attributes) = match &value {
            seed_schema::Object::Crossroad(data) => (
                orm_model::ObjectType::Crossroad,
                data.is_active,
                data.attributes.to_owned(),
            ),
            seed_schema::Object::Signal(data) => (
                orm_model::ObjectType::Signal,
                data.is_active,
                data.attributes.to_owned(),
            ),
            seed_schema::Object::Gateway(data) => (
                orm_model::ObjectType::Gateway,
                data.is_active,
                data.attributes.to_owned(),
            ),
            seed_schema::Object::Direction(data) => (
                orm_model::ObjectType::Direction,
                data.is_active,
                data.attributes.to_owned(),
            ),
        };

        let insert_object = orm_model::InsertObject {
            object_type,
            is_active,
            attributes,
        };

        Ok(insert_object)
    }
}

// ===========================================================================

impl TryFromWithID<&seed_schema::CrossroadData> for orm_model::InsertObjectCrossroad {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from_with_id(value: &seed_schema::CrossroadData, id: i32) -> Result<Self, Self::Error> {
        let insert_object_crossroad = orm_model::InsertObjectCrossroad {
            id,
            name: value.properties.name.to_owned(),
        };

        Ok(insert_object_crossroad)
    }
}

// ===========================================================================

impl TryFromWithID<&seed_schema::SignalData> for orm_model::InsertObjectSignal {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from_with_id(value: &seed_schema::SignalData, id: i32) -> Result<Self, Self::Error> {
        let insert_object_signal = orm_model::InsertObjectSignal {
            id,
            kind: value.properties.kind.clone(),
        };

        Ok(insert_object_signal)
    }
}

// ===========================================================================

impl TryFromWithID<&seed_schema::GatewayData> for orm_model::InsertObjectGateway {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from_with_id(value: &seed_schema::GatewayData, id: i32) -> Result<Self, Self::Error> {
        let insert_object_gateway = orm_model::InsertObjectGateway {
            id,
            is_inbound: value.properties.is_inbound,
            is_outbound: value.properties.is_outbound,
        };

        Ok(insert_object_gateway)
    }
}

// ===========================================================================

impl TryFromWithID<&seed_schema::DirectionData> for orm_model::InsertObjectDirection {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from_with_id(value: &seed_schema::DirectionData, id: i32) -> Result<Self, Self::Error> {
        let insert_object_direction = orm_model::InsertObjectDirection {
            id,
            definition: value.properties.definition.clone(),
        };

        Ok(insert_object_direction)
    }
}

// ===========================================================================

impl TryFromWithID<&seed_schema::Picture> for orm_model::InsertObjectPicture {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from_with_id(value: &seed_schema::Picture, id: i32) -> Result<Self, Self::Error> {
        let insert_picture = orm_model::InsertObjectPicture {
            object_id: id,
            buffer: std::fs::read(&value.buffer_path)?,
            axis_width: value.axis_width,
            axis_height: value.axis_height,
            scale: value.scale,
            angle: value.angle,
        };

        Ok(insert_picture)
    }
}

// ===========================================================================

impl TryFrom<&seed_schema::Figure> for postgis_model::GeometryContainer<postgis_model::Point> {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from(figure: &seed_schema::Figure) -> Result<Self, Self::Error> {
        match figure {
            seed_schema::Figure::Point { coordinates } => Ok(
                postgis_model::GeometryContainer::Point(postgis_model::Point {
                    x: coordinates[0],
                    y: coordinates[1],
                    srid: Some(4326),
                }),
            ),
            seed_schema::Figure::LineString { coordinates } => {
                let points: Vec<postgis_model::Point> = coordinates
                    .iter()
                    .map(|coord| postgis_model::Point {
                        x: coord[0],
                        y: coord[1],
                        srid: Some(4326),
                    })
                    .collect();

                Ok(postgis_model::GeometryContainer::LineString(
                    postgis_model::LineString {
                        points,
                        srid: Some(4326),
                    },
                ))
            }
        }
    }
}

// ===========================================================================

impl TryFromWithID<&seed_schema::Geometry> for orm_model::InsertObjectGeometry {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn try_from_with_id(value: &seed_schema::Geometry, id: i32) -> Result<Self, Self::Error> {
        let figure =
            postgis_model::GeometryContainer::<postgis_model::Point>::try_from(&value.figure)?;

        let insert_object_geometry = orm_model::InsertObjectGeometry {
            object_id: id,
            geotype: value.geolocation_type.clone(),
            angle: value.angle,
            figure,
        };

        Ok(insert_object_geometry)
    }
}

// ===========================================================================
