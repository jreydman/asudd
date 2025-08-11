fn main() -> Result<(), Box<dyn std::error::Error>> {
    use core_server::orm::models;
    use core_server::orm::schema;
    use core_server::orm::seed::schema as seed_schema;

    let seed_string = std::fs::read_to_string("src/orm/seed/01__seed.json")?;

    let root: seed_schema::SeedRoot = serde_json::from_str(&seed_string)?;

    let mut connection = core_server::orm::database::establish_connection();

    core_server::orm::seed::insert_seed(root, &mut connection)?;

    Ok(())
}
