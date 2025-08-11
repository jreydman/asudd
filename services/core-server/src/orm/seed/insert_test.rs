#[cfg(test)]
mod tests {
    use crate::orm::{
        helpers::seed_insertable::{ChildInsertable, Insertable},
        models::object_geometry::InsertObjectGeometry,
    };
    use diesel::prelude::*;

    use super::*;
    use diesel::Connection;
    use serde_json;

    #[test]
    fn test_seed_insertion() {
        let json_data = r#"
        {
            "objects": [
                {
                    "object_type": "crossroad",
                    "rel_id": 1,
                    "properties": {
                        "name": "Main Crossroad"
                    },
                    "pictures": [
                        {
                            "buffer_path": "src/orm/seed/pictures/1.bmp",
                            "axis_width": 100,
                            "axis_height": 200,
                            "scale": 1.5,
                            "angle": 45.0
                        }
                    ],
                    "geometries": [
                        {
                            "geotype": "local",
                            "figure": {
                                "type": "Point",
                                "coordinates": [102.0, 0.5]
                            },
                            "angle": 0.0
                        }
                    ]
                }
            ]
        }
        "#;

        let root: crate::orm::seed::schema::SeedRoot =
            serde_json::from_str(json_data).expect("Failed to deserialize SeedRoot");

        let mut connection = crate::orm::database::establish_connection();

        connection.begin_test_transaction().unwrap();

        crate::orm::seed::insert_seed(root, &mut connection).unwrap();
    }
}
