// @generated automatically by Diesel CLI.

pub mod sql_types {
    pub use postgis_diesel::sql_types::Geometry;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "object_direction_definition"))]
    pub struct ObjectDirectionDefinition;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "object_geometry_geotype"))]
    pub struct ObjectGeometryGeotype;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "object_signal_kind"))]
    pub struct ObjectSignalKind;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "object_type"))]
    pub struct ObjectType;
}

diesel::table! {
    object_crossroads (id) {
        id -> Int4,
        name -> Nullable<Text>,
    }
}

diesel::table! {
    object_dependencies (master_id, slave_id) {
        master_id -> Int4,
        slave_id -> Int4,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::ObjectDirectionDefinition;

    object_directions (id) {
        id -> Int4,
        definition -> ObjectDirectionDefinition,
    }
}

diesel::table! {
    object_gateways (id) {
        id -> Int4,
        is_inbound -> Bool,
        is_outbound -> Bool,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::ObjectGeometryGeotype;
    use super::sql_types::Geometry;

    object_geometries (id) {
        id -> Int4,
        object_id -> Int4,
        geotype -> ObjectGeometryGeotype,
        angle -> Float8,
        figure -> Geometry,
    }
}

diesel::table! {
    object_pictures (id) {
        id -> Int4,
        object_id -> Int4,
        buffer -> Bytea,
        axis_width -> Int4,
        axis_height -> Int4,
        scale -> Float8,
        angle -> Float8,
    }
}

diesel::table! {
    object_signal_standards (id) {
        id -> Int4,
        code -> Text,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::ObjectSignalKind;

    object_signals (id) {
        id -> Int4,
        standard -> Nullable<Int4>,
        kind -> Array<Nullable<ObjectSignalKind>>,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::ObjectType;

    object_type_mapping (table_name) {
        table_name -> Text,
        expected_type -> ObjectType,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::ObjectType;

    objects (id) {
        id -> Int4,
        object_type -> ObjectType,
        is_active -> Bool,
        attributes -> Jsonb,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

diesel::table! {
    spatial_ref_sys (srid) {
        srid -> Int4,
        #[max_length = 256]
        auth_name -> Nullable<Varchar>,
        auth_srid -> Nullable<Int4>,
        #[max_length = 2048]
        srtext -> Nullable<Varchar>,
        #[max_length = 2048]
        proj4text -> Nullable<Varchar>,
    }
}

diesel::joinable!(object_crossroads -> objects (id));
diesel::joinable!(object_directions -> objects (id));
diesel::joinable!(object_gateways -> objects (id));
diesel::joinable!(object_geometries -> objects (object_id));
diesel::joinable!(object_pictures -> objects (object_id));
diesel::joinable!(object_signals -> object_signal_standards (standard));
diesel::joinable!(object_signals -> objects (id));

diesel::allow_tables_to_appear_in_same_query!(
    object_crossroads,
    object_dependencies,
    object_directions,
    object_gateways,
    object_geometries,
    object_pictures,
    object_signal_standards,
    object_signals,
    object_type_mapping,
    objects,
    spatial_ref_sys,
);
