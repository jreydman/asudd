// =============================================================================

use std::{env, process};

use core_server::{application::seed_import::SeedImporter, infrastructure::orm::connection};
use diesel::{Connection, pg::PgConnection};
use dotenvy::dotenv;

// =============================================================================

fn main() {
    let folder = env::args().nth(1).unwrap_or_else(|| "data/seed".to_string());

    dotenv().ok();

    let mut connection = match connection::DbConnection::establish() {
        Ok(connection) => connection,
        Err(err) => {
            eprintln!("Failed to connect to DB: {}", err);
            process::exit(1);
        },
    };

    let mut importer = SeedImporter::new(&mut connection);

    match importer.import_from_folder(&folder) {
        Ok(_) => println!("Seeds imported successfully from '{}'", folder),
        Err(err) => {
            eprintln!("Failed to import seeds: {}", err);
            process::exit(1);
        },
    }
}

// =============================================================================
