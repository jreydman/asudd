// ===========================================================================

use std::env;

use diesel::{Connection, pg::PgConnection};

pub struct DbConnection;

// ===========================================================================

impl DbConnection {
    pub fn establish() -> Result<PgConnection, Box<dyn std::error::Error>> {
        let database_url = env::var("DATABASE_URL")?;
        let conn = PgConnection::establish(&database_url)?;
        Ok(conn)
    }
}

// ===========================================================================
