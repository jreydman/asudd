#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::object_signals)]
pub struct InsertObjectSignal {
    pub id: i32,
    pub kind: Vec<crate::orm::models::types::ObjectSignalKind>,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObjectSignal {
    pub kind: Vec<crate::orm::models::types::ObjectSignalKind>,
}
