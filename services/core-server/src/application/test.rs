// =============================================================================

use std::env;

use diesel::connection::Connection;
use dotenvy::dotenv;

use super::*;
use crate::{application::seed_import::SeedImporter, domain::seed::error::Error as SeedError};

// =============================================================================

fn get_connection() -> diesel::PgConnection {
    dotenv().ok();
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    diesel::PgConnection::establish(&database_url).expect("Failed to connect to DB")
}

// =============================================================================

#[test]
fn import_from_folder_transaction() {
    let mut conn = get_connection();

    conn.test_transaction::<_, SeedError, _>(|connection| {
        let mut importer = SeedImporter::new(connection);

        importer.import_from_folder("data/seed").unwrap();

        Ok(())
    });
}

// =============================================================================
