#[cfg(test)]
mod tests {
    use super::*;
    use serde_json;

    #[test]
    fn test_seed_deserialization() {
        let json_data = r#"
        {
            "objects": [
                {
                    "object_type": "crossroad",
                    "rel_id": 1,
                    "attributes": {
                        "metadata": "example metadata"
                    },
                    "properties": {
                        "name": "Main Crossroad"
                    },
                    "pictures": [
                        {
                            "buffer_path": "path/to/image.png",
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
                },
                {
                    "object_type": "gateway",
                    "rel_id": 2,
                    "attributes": {},
                    "properties": {
                        "is_inbound": true,
                        "is_outbound": false
                    },
                    "pictures": [],
                    "geometries": []
                }
            ],
            "object_dependencies": [
                {
                    "master_id": 1,
                    "slave_ids": [2]
                }
            ]
        }
        "#;

        let root: crate::orm::seed::schema::SeedRoot =
            serde_json::from_str(json_data).expect("Failed to deserialize SeedRoot");

        assert_eq!(root.objects.len(), 2);

        if let crate::orm::seed::schema::SeedObject::Crossroad(crossroad) = &root.objects[0] {
            assert_eq!(crossroad.rel_id, 1);
            assert_eq!(crossroad.properties.name, "Main Crossroad");
            assert_eq!(crossroad.pictures.len(), 1);
            assert_eq!(crossroad.geometries.len(), 1);
            assert_eq!(
                crossroad.attributes.metadata.as_deref(),
                Some("example metadata")
            );
            assert_eq!(
                crossroad.object_type,
                crate::orm::models::types::ObjectType::Crossroad
            );
        } else {
            panic!("Expected Crossroad object");
        }

        if let crate::orm::seed::schema::SeedObject::Gateway(gateway) = &root.objects[1] {
            assert_eq!(gateway.rel_id, 2);
            assert!(gateway.properties.is_inbound);
            assert!(!gateway.properties.is_outbound);
            assert_eq!(gateway.pictures.len(), 0);
            assert_eq!(gateway.geometries.len(), 0);
            assert_eq!(
                gateway.object_type,
                crate::orm::models::types::ObjectType::Gateway
            );
        } else {
            panic!("Expected Gateway object");
        }

        assert_eq!(root.object_dependencies.len(), 1);
        assert_eq!(root.object_dependencies[0].master_id, 1);
        assert_eq!(root.object_dependencies[0].slave_ids, vec![2]);
    }
}
