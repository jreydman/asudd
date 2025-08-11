#[derive(diesel::Insertable, Debug)]
#[diesel(table_name = crate::orm::schema::object_gateways)]
pub struct InsertObjectGateway {
    pub id: i32,
    pub is_inbound: bool,
    pub is_outbound: bool,
}

// ------------------------------------------------------------------------------------------------

pub struct UpdateObjectGateway {
    pub is_inbound: bool,
    pub is_outbound: bool,
}
