use crate::domain::seed::{error, schema};

pub trait Repository {
    fn insert(&self, seed: &schema::Seed) -> Result<(), error::Error>;
    fn insert_many(&self, seeds: &[schema::Seed]) -> Result<(), error::Error>;
}
