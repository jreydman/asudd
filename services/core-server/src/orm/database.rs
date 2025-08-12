use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::r2d2::ConnectionManager;
use r2d2::{Pool, PooledConnection};

use std::env;

// ===========================================================================

pub type DbPool = Pool<ConnectionManager<PgConnection>>;
pub type DbPooledConnection = PooledConnection<ConnectionManager<PgConnection>>;
pub type DbError = r2d2::Error;

// ===========================================================================

pub struct DatabaseClient {
    pool: DbPool,
}

// ===========================================================================

impl DatabaseClient {
    pub fn new() -> Result<Self, DbError> {
        let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        let manager = ConnectionManager::<PgConnection>::new(&database_url);
        let pool = r2d2::Pool::builder().build(manager)?;

        Ok(Self { pool })
    }

    pub fn get_connection(&self) -> Result<DbPooledConnection, DbError> {
        self.pool.get()
    }
}

// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn database_connection() {
        dotenvy::dotenv().unwrap();

        let client = DatabaseClient::new();
        assert!(client.is_ok());

        let client = client.unwrap();

        let connection = client.get_connection();

        assert!(connection.is_ok());
    }
}

// ===========================================================================
