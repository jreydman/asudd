use std::path;

use super::*;

#[test]
fn deserialize_seed_from_file() {
    schema::Seed::from_file(&path::PathBuf::from("data/seed/00__seed.json"))
        .expect("Failed to load seed");
}
