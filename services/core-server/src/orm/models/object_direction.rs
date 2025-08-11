#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::object_directions)]
pub struct InsertObjectDirection {
    pub id: i32,
    pub definition: crate::orm::models::types::ObjectDirectionDefinition,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObjectDirection {
    pub is_inbound: bool,
    pub is_outbound: bool,
}
