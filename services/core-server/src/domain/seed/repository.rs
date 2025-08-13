use crate::domain::seed::{error, schema};

// ===========================================================================

pub trait Repository {
    fn insert(&mut self, seed: &schema::Seed) -> Result<(), error::Error>;
    fn insert_many(&mut self, seeds: &[schema::Seed]) -> Result<(), error::Error>;
}

// ===========================================================================
