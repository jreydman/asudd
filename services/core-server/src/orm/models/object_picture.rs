#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::object_pictures)]
pub struct InsertObjectPicture {
    pub object_id: i32,
    pub buffer: Vec<u8>,
    pub axis_width: i32,
    pub axis_height: i32,
    pub scale: f64,
    pub angle: f64,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObjectPicture {
    pub buffer: Vec<u8>,
    pub axis_width: i32,
    pub axis_height: i32,
    pub scale: f64,
    pub angle: f64,
}
