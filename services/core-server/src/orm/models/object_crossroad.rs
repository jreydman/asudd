#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::object_crossroads)]
pub struct InsertObjectCrossroad {
    pub id: i32,
    pub name: String,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObjectCrossroad {
    pub name: String,
}
