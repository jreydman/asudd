use crate::orm::model as orm_model;
use crate::orm::schema as orm_schema;
use crate::seed::schema as seed_schema;

// ===========================================================================

use crate::orm::convertion::TryFromWithID;
use diesel::{Connection, RunQueryDsl};

// ===========================================================================

pub trait Insertable {
    type Error;
    fn insert(&self, connection: &mut diesel::PgConnection) -> Result<i32, Self::Error>;
}

// ===========================================================================

pub trait ChildInsertable {
    type Error;
    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error>;
}

// ===========================================================================

impl Insertable for seed_schema::Object {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn insert(&self, conn: &mut diesel::PgConnection) -> Result<i32, Self::Error> {
        conn.transaction::<_, Self::Error, _>(|conn| {
            let insert_object = orm_model::InsertObject::try_from(self)?;
            let object_id: i32 = diesel::insert_into(orm_schema::objects::table)
                .values(&insert_object)
                .returning(orm_schema::objects::id)
                .get_result(conn)?;

            Ok(object_id)
        })
    }
}

// ===========================================================================

impl ChildInsertable for seed_schema::CrossroadData {
    type Error = Box<dyn std::error::Error + Send + Sync>;
    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error> {
        let insert_object_crossroad =
            orm_model::InsertObjectCrossroad::try_from_with_id(self, object_id)?;

        diesel::insert_into(orm_schema::object_crossroads::table)
            .values(&insert_object_crossroad)
            .execute(conn)?;

        Ok(())
    }
}

// ===========================================================================

impl ChildInsertable for seed_schema::SignalData {
    type Error = Box<dyn std::error::Error + Send + Sync>;
    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error> {
        let insert_object_signal =
            orm_model::InsertObjectSignal::try_from_with_id(self, object_id)?;

        diesel::insert_into(orm_schema::object_signals::table)
            .values(&insert_object_signal)
            .execute(conn)?;

        Ok(())
    }
}

// ===========================================================================

impl ChildInsertable for seed_schema::GatewayData {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error> {
        let insert_object_gateway =
            orm_model::InsertObjectGateway::try_from_with_id(self, object_id)?;

        diesel::insert_into(orm_schema::object_gateways::table)
            .values(&insert_object_gateway)
            .execute(conn)?;

        Ok(())
    }
}

// ===========================================================================

impl ChildInsertable for seed_schema::DirectionData {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error> {
        let insert_object_direction =
            orm_model::InsertObjectDirection::try_from_with_id(self, object_id)?;

        diesel::insert_into(orm_schema::object_directions::table)
            .values(&insert_object_direction)
            .execute(conn)?;

        Ok(())
    }
}

// ===========================================================================

impl ChildInsertable for seed_schema::Picture {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error> {
        let insert_object_picture =
            orm_model::InsertObjectPicture::try_from_with_id(self, object_id)?;

        diesel::insert_into(orm_schema::object_pictures::table)
            .values(&insert_object_picture)
            .execute(conn)?;

        Ok(())
    }
}

// ===========================================================================

impl ChildInsertable for seed_schema::Geometry {
    type Error = Box<dyn std::error::Error + Send + Sync>;

    fn insert(&self, object_id: i32, conn: &mut diesel::PgConnection) -> Result<(), Self::Error> {
        let insert_object_geometry =
            orm_model::InsertObjectGeometry::try_from_with_id(self, object_id)?;

        diesel::insert_into(orm_schema::object_geometries::table)
            .values(&insert_object_geometry)
            .execute(conn)?;

        Ok(())
    }
}

// ===========================================================================
