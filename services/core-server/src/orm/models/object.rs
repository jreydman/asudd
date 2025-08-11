#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::objects)]
pub struct InsertObject {
    pub object_type: crate::orm::models::types::ObjectType,
    pub attributes: serde_json::Value,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObject {
    pub attributes: serde_json::Value,
    pub is_active: bool,
}
