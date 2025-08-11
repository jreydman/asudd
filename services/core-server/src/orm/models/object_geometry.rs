#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::object_geometries)]
pub struct InsertObjectGeometry<T> {
    pub object_id: i32,
    pub geotype: crate::orm::models::types::ObjectGeometryGeotype,
    pub figure: postgis_diesel::types::GeometryContainer<T>,
    pub angle: f64,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObjectGeometry<T> {
    pub geotype: crate::orm::models::types::ObjectGeometryGeotype,
    pub figure: postgis_diesel::types::GeometryContainer<T>,
    pub angle: f64,
}
