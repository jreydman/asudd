use std::path::PathBuf;

use super::stage_converter::StagedObject;
use crate::domain::seed::schema::Seed;

// ===========================================================================

#[test]
fn staging_from_seed_file() {
    let path = PathBuf::from("data/seed/00__seed.json");

    let seed = Seed::from_file(&path).expect("Failed to load seed");

    let first_obj = seed.objects.first().expect("No objects in seed");

    StagedObject::from_seed_object(first_obj).expect("Failed to stage object");
}
