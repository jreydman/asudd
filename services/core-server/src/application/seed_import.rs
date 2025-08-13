use std::{fs, path::Path};

use diesel::pg::PgConnection;

use crate::{
    domain::seed::{repository::Repository, schema::Seed},
    infrastructure::orm::repository::DieselRepository,
};

// ===========================================================================

pub struct SeedImporter<'a> {
    connection: &'a mut PgConnection,
}

// ===========================================================================

impl<'a> SeedImporter<'a> {
    pub fn new(connection: &'a mut PgConnection) -> Self {
        Self { connection }
    }

    pub fn import_from_folder<P: AsRef<Path>>(
        &mut self,
        folder_path: P,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let mut repo = DieselRepository::new(self.connection);

        for entry in fs::read_dir(folder_path)? {
            let path = entry?.path();
            if path.extension().map(|ext| ext == "json").unwrap_or(false) {
                let seed = Seed::from_file(&path)?;
                repo.insert(&seed)?;
            }
        }

        Ok(())
    }
}

// ===========================================================================
