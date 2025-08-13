// ===========================================================================

use std::env;

use diesel::{connection::Connection, pg::PgConnection};
use dotenvy::dotenv;

use super::*;
use crate::{
    domain::seed::{error::Error as SeedError, repository::Repository, schema::Seed},
    infrastructure::orm::repository::DieselRepository,
};

// ===========================================================================

fn get_connection() -> PgConnection {
    dotenv().ok();
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    PgConnection::establish(&database_url).expect("Failed to connect to DB")
}

// ===========================================================================

#[test]
fn connection() {
    dotenv().ok();
    get_connection();
}

// ===========================================================================

#[test]
fn insert_seed_transaction() {
    let mut conn = get_connection();

    conn.test_transaction::<_, SeedError, _>(|connection| {
        let mut repo = DieselRepository::new(connection);
        let seed = Seed::from_file(&"data/seed/00__seed.json".into()).unwrap();
        repo.insert(&seed)?;
        Ok(())
    });
}

// ===========================================================================
