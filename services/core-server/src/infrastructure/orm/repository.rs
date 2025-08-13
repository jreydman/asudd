use crate::domain::seed::{
    error::Error as SeedError, repository::Repository as SeedRepository, schema::Seed,
};

// ===========================================================================

pub struct DieselRepository<'a> {
    connection: &'a diesel::PgConnection,
}

// ===========================================================================

impl<'a> DieselRepository<'a> {
    pub fn new(connection: &'a mut diesel::PgConnection) -> Self {
        Self { connection }
    }
}

// ===========================================================================

impl<'a> SeedRepository for DieselRepository<'a> {
    fn insert_many(&self, seeds: &[Seed]) -> Result<(), SeedError> {
        unimplemented!()
    }

    fn insert(&self, seed: &Seed) -> Result<(), SeedError> {
        unimplemented!()
    }
}

// ===========================================================================
