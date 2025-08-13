use diesel::{
    deserialize::QueryableByName,
    prelude::*,
    sql_types::{BigInt, Double, Float8, Integer, Nullable},
};

#[derive(Debug, QueryableByName)]
#[diesel(check_for_backend(diesel::pg::Pg))]
struct RouteStep {
    #[diesel(sql_type = Integer)]
    seq: i32,
    #[diesel(sql_type = BigInt)]
    node: i64,
    #[diesel(sql_type = BigInt)]
    edge: i64,
    #[diesel(sql_type = Double)]
    cost: f64,
}

impl RouteStep {
    fn find_all(connection: &mut PgConnection) -> Result<Vec<Self>, diesel::result::Error> {
        let sql = r#"
            SELECT * FROM osm__ukraine_kyiv.func__get_route_by_points(ARRAY[
                ST_SetSRID(ST_MakePoint(30.4988571, 50.4445150), 4326),
                ST_SetSRID(ST_MakePoint(30.5131049, 50.4452792), 4326)
            ])
        "#;

        diesel::sql_query(sql).load(connection)
    }
}

#[cfg(test)]
mod tests {
    use std::error::Error;

    use super::*;

    #[test]
    fn select_route_by_points() -> Result<(), Box<dyn Error + Send + Sync>> {
        dotenvy::dotenv().unwrap();

        let client = crate::orm::database::DatabaseClient::new()?;
        let mut connection = client.get_connection()?;

        let results = RouteStep::find_all(&mut connection)?;

        assert!(!results.is_empty());

        Ok(())
    }
}
