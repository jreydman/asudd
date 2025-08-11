use crate::orm::models;
use crate::orm::seed::schema;

// ------------------------------------------------------------------------------------------------

pub trait Insertable<T> {
    fn to_insert(&self) -> T;
}

// ------------------------------------------------------------------------------------------------

pub trait ChildInsertable<T> {
    fn to_insert(&self, object_id: i32) -> T;
}

// ------------------------------------------------------------------------------------------------

impl Insertable<models::object::InsertObject> for schema::SeedObject {
    fn to_insert(&self) -> models::object::InsertObject {
        let object = self.as_trait().unwrap();

        models::object::InsertObject {
            object_type: *object.object_type(),
            attributes: serde_json::to_value(object.attributes().clone()).unwrap(),
        }
    }
}

// ------------------------------------------------------------------------------------------------

impl ChildInsertable<models::object_direction::InsertObjectDirection>
    for schema::SeedObjectDirectionProperties
{
    fn to_insert(&self, object_id: i32) -> models::object_direction::InsertObjectDirection {
        models::object_direction::InsertObjectDirection {
            id: object_id,
            definition: self.definition,
        }
    }
}

// ------------------------------------------------------------------------------------------------

impl ChildInsertable<models::object_signal::InsertObjectSignal>
    for schema::SeedObjectSignalProperties
{
    fn to_insert(&self, object_id: i32) -> models::object_signal::InsertObjectSignal {
        models::object_signal::InsertObjectSignal {
            id: object_id,
            kind: self.kind.clone(),
        }
    }
}

// ------------------------------------------------------------------------------------------------

impl ChildInsertable<models::object_crossroad::InsertObjectCrossroad>
    for schema::SeedObjectCrossroadProperties
{
    fn to_insert(&self, object_id: i32) -> models::object_crossroad::InsertObjectCrossroad {
        models::object_crossroad::InsertObjectCrossroad {
            id: object_id,
            name: self.name.clone(),
        }
    }
}

// ------------------------------------------------------------------------------------------------

impl ChildInsertable<models::object_gateway::InsertObjectGateway>
    for schema::SeedObjectGatewayProperties
{
    fn to_insert(&self, object_id: i32) -> models::object_gateway::InsertObjectGateway {
        models::object_gateway::InsertObjectGateway {
            id: object_id,
            is_inbound: self.is_inbound,
            is_outbound: self.is_outbound,
        }
    }
}

// ------------------------------------------------------------------------------------------------

pub trait FromFigure: Sized {
    fn from_figure(
        figure: &schema::SeedObjectGeometryFigure,
    ) -> Option<postgis_diesel::types::GeometryContainer<Self>>;
}

// ------------------------------------------------------------------------------------------------

impl FromFigure for postgis_diesel::types::Point {
    fn from_figure(
        figure: &schema::SeedObjectGeometryFigure,
    ) -> Option<postgis_diesel::types::GeometryContainer<Self>> {
        if figure.figure_type != models::types::ObjectGeometryType::Point {
            return None;
        }

        let arr = figure.coordinates.as_array()?;
        if arr.len() < 2 {
            return None;
        }

        let x = arr.first()?.as_f64()?;
        let y = arr.get(1)?.as_f64()?;
        let p = postgis_diesel::types::Point { x, y, srid: None };
        Some(postgis_diesel::types::GeometryContainer::Point(p))
    }
}

// ------------------------------------------------------------------------------------------------

impl<T> ChildInsertable<models::object_geometry::InsertObjectGeometry<T>>
    for schema::SeedObjectGeometry
where
    T: FromFigure,
{
    fn to_insert(&self, object_id: i32) -> models::object_geometry::InsertObjectGeometry<T> {
        models::object_geometry::InsertObjectGeometry {
            object_id,
            geotype: self.geotype,
            figure: T::from_figure(&self.figure).unwrap(),
            angle: self.angle,
        }
    }
}

// ------------------------------------------------------------------------------------------------

impl ChildInsertable<models::object_picture::InsertObjectPicture> for schema::SeedObjectPicture {
    fn to_insert(&self, object_id: i32) -> models::object_picture::InsertObjectPicture {
        models::object_picture::InsertObjectPicture {
            object_id,
            buffer: std::fs::read(&self.buffer_path).unwrap(),
            axis_width: self.axis_width,
            axis_height: self.axis_height,
            scale: self.scale,
            angle: self.angle,
        }
    }
}
