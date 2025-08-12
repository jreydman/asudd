use core_server::{commands, orm, seed};
use dotenvy::dotenv;

fn main() {
    dotenv().ok();

    let path = "data/seed/00__seed.json".to_owned();
    let client = orm::database::DatabaseClient::new().unwrap();
    let mut connection = client.get_connection().unwrap();

    println!("Seed insertion started");

    commands::insert_seed(&path, &mut connection).unwrap();

    println!("Seed inserted");
}
