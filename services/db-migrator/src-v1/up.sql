--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO admin;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: admin
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: pgrouting; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrouting WITH SCHEMA public;


--
-- Name: EXTENSION pgrouting; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgrouting IS 'pgRouting Extension';


--
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: crossroad_object_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.crossroad_object_type AS ENUM (
    'highway_signal',
    'crossroad_port',
    'crossroad_direction'
);


ALTER TYPE public.crossroad_object_type OWNER TO admin;

--
-- Name: port_connection_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.port_connection_type AS ENUM (
    'internal',
    'external'
);


ALTER TYPE public.port_connection_type OWNER TO admin;

--
-- Name: add_crossroad_port(integer, boolean, boolean, jsonb); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.add_crossroad_port(p_crossroad_id integer, p_is_inbound boolean, p_is_outbound boolean, p_attributes jsonb DEFAULT NULL::jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_port_id INTEGER;
BEGIN
  IF NOT (p_is_inbound OR p_is_outbound) THEN
    RAISE EXCEPTION 'At least one direction (is_inbound or is_outbound) must be TRUE';
  END IF;

  INSERT INTO crossroad_objects (crossroad_id, type, attributes)
  VALUES (p_crossroad_id, 'crossroad_port', COALESCE(p_attributes, '{}'::jsonb))
  RETURNING id INTO new_port_id;

  INSERT INTO crossroad_ports (id, is_inbound, is_outbound)
  VALUES (new_port_id, p_is_inbound, p_is_outbound);

  RETURN new_port_id;
END;
$$;


ALTER FUNCTION public.add_crossroad_port(p_crossroad_id integer, p_is_inbound boolean, p_is_outbound boolean, p_attributes jsonb) OWNER TO admin;

--
-- Name: add_crossroad_port(integer, boolean, boolean, jsonb, public.geometry); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.add_crossroad_port(p_crossroad_id integer, p_is_inbound boolean, p_is_outbound boolean, p_attributes jsonb DEFAULT NULL::jsonb, p_geometry public.geometry DEFAULT NULL::public.geometry) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_port_id INTEGER;
BEGIN
  IF NOT (p_is_inbound OR p_is_outbound) THEN
    RAISE EXCEPTION 'At least one direction (is_inbound or is_outbound) must be TRUE';
  END IF;

  INSERT INTO crossroad_objects (crossroad_id, type, attributes)
  VALUES (p_crossroad_id, 'crossroad_port', COALESCE(p_attributes, '{}'::jsonb))
  RETURNING id INTO new_port_id;

  INSERT INTO crossroad_ports (id, is_inbound, is_outbound)
  VALUES (new_port_id, p_is_inbound, p_is_outbound);

  IF p_geometry IS NOT NULL THEN
    INSERT INTO crossroad_object_geometries (crossroad_object_id, geometry)
    VALUES (new_port_id, p_geometry);
  END IF;

  RETURN new_port_id;
END;
$$;


ALTER FUNCTION public.add_crossroad_port(p_crossroad_id integer, p_is_inbound boolean, p_is_outbound boolean, p_attributes jsonb, p_geometry public.geometry) OWNER TO admin;

--
-- Name: add_crossroad_signal(integer, jsonb); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.add_crossroad_signal(p_crossroad_id integer, p_attributes jsonb DEFAULT NULL::jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_signal_id INTEGER;
BEGIN
  INSERT INTO crossroad_objects (crossroad_id, type, attributes)
  VALUES (p_crossroad_id, 'highway_signal', COALESCE(p_attributes, '{}'::jsonb))
  RETURNING id INTO new_signal_id;

  INSERT INTO crossroad_signals (id) VALUES (new_signal_id);

  RETURN new_signal_id;
END;
$$;


ALTER FUNCTION public.add_crossroad_signal(p_crossroad_id integer, p_attributes jsonb) OWNER TO admin;

--
-- Name: add_crossroad_signal(integer, jsonb, public.geometry); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.add_crossroad_signal(p_crossroad_id integer, p_attributes jsonb DEFAULT NULL::jsonb, p_geometry public.geometry DEFAULT NULL::public.geometry) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_signal_id INTEGER;
BEGIN
  INSERT INTO crossroad_objects (crossroad_id, type, attributes)
  VALUES (p_crossroad_id, 'highway_signal', COALESCE(p_attributes, '{}'::jsonb))
  RETURNING id INTO new_signal_id;

  INSERT INTO crossroad_signals (id) VALUES (new_signal_id);

  IF p_geometry IS NOT NULL THEN
    INSERT INTO crossroad_object_geometries (crossroad_object_id, geometry)
    VALUES (new_signal_id, p_geometry);
  END IF;

  RETURN new_signal_id;
END;
$$;


ALTER FUNCTION public.add_crossroad_signal(p_crossroad_id integer, p_attributes jsonb, p_geometry public.geometry) OWNER TO admin;

--
-- Name: add_port_connection(integer, integer, jsonb); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.add_port_connection(p_source_port_id integer, p_destination_port_id integer, p_attributes jsonb DEFAULT NULL::jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  source_dir RECORD;
  dest_dir RECORD;
  conn_type PORT_CONNECTION_TYPE;
  new_connection_obj_id INTEGER;
BEGIN
  SELECT is_inbound, is_outbound INTO source_dir FROM crossroad_ports WHERE id = p_source_port_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Source port % not found', p_source_port_id;
  END IF;

  SELECT is_inbound, is_outbound INTO dest_dir FROM crossroad_ports WHERE id = p_destination_port_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Destination port % not found', p_destination_port_id;
  END IF;

  IF source_dir.is_inbound AND dest_dir.is_outbound THEN
    conn_type := 'internal';
  ELSIF source_dir.is_outbound AND dest_dir.is_inbound THEN
    conn_type := 'external';
  ELSE
    RAISE EXCEPTION 'Invalid port directions for connection between % and %', p_source_port_id, p_destination_port_id;
  END IF;

  IF conn_type = 'internal' THEN
    INSERT INTO crossroad_objects (crossroad_id, type, attributes)
    SELECT co.crossroad_id, 'crossroad_direction', COALESCE(p_attributes, '{}'::jsonb)
    FROM crossroad_objects co WHERE co.id = p_source_port_id
    RETURNING id INTO new_connection_obj_id;
  ELSE
    new_connection_obj_id := NULL;
  END IF;

  INSERT INTO port_connections (
    id,
    crossroad_object_source_id,
    crossroad_object_destination_id,
    connection_type
  ) VALUES (
    new_connection_obj_id,
    p_source_port_id,
    p_destination_port_id,
    conn_type
  );
END;
$$;


ALTER FUNCTION public.add_port_connection(p_source_port_id integer, p_destination_port_id integer, p_attributes jsonb) OWNER TO admin;

--
-- Name: asbinary(public.geometry); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.asbinary(public.geometry) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-3', 'LWGEOM_asBinary';


ALTER FUNCTION public.asbinary(public.geometry) OWNER TO admin;

--
-- Name: asbinary(public.geometry, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.asbinary(public.geometry, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-3', 'LWGEOM_asBinary';


ALTER FUNCTION public.asbinary(public.geometry, text) OWNER TO admin;

--
-- Name: astext(public.geometry); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.astext(public.geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-3', 'LWGEOM_asText';


ALTER FUNCTION public.astext(public.geometry) OWNER TO admin;

--
-- Name: estimated_extent(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.estimated_extent(text, text) RETURNS public.box2d
    LANGUAGE c IMMUTABLE STRICT SECURITY DEFINER
    AS '$libdir/postgis-3', 'geometry_estimated_extent';


ALTER FUNCTION public.estimated_extent(text, text) OWNER TO admin;

--
-- Name: estimated_extent(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.estimated_extent(text, text, text) RETURNS public.box2d
    LANGUAGE c IMMUTABLE STRICT SECURITY DEFINER
    AS '$libdir/postgis-3', 'geometry_estimated_extent';


ALTER FUNCTION public.estimated_extent(text, text, text) OWNER TO admin;

--
-- Name: geomfromtext(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.geomfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeomFromText($1)$_$;


ALTER FUNCTION public.geomfromtext(text) OWNER TO admin;

--
-- Name: geomfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.geomfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeomFromText($1, $2)$_$;


ALTER FUNCTION public.geomfromtext(text, integer) OWNER TO admin;

--
-- Name: ndims(public.geometry); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.ndims(public.geometry) RETURNS smallint
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-3', 'LWGEOM_ndims';


ALTER FUNCTION public.ndims(public.geometry) OWNER TO admin;

--
-- Name: planet_osm_index_bucket(bigint[]); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.planet_osm_index_bucket(bigint[]) RETURNS bigint[]
    LANGUAGE sql IMMUTABLE
    AS $_$  SELECT ARRAY(SELECT DISTINCT    unnest($1) >> 5)$_$;


ALTER FUNCTION public.planet_osm_index_bucket(bigint[]) OWNER TO admin;

--
-- Name: planet_osm_line_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.planet_osm_line_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


ALTER FUNCTION public.planet_osm_line_osm2pgsql_valid() OWNER TO admin;

--
-- Name: planet_osm_member_ids(jsonb, character); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.planet_osm_member_ids(jsonb, character) RETURNS bigint[]
    LANGUAGE sql IMMUTABLE
    AS $_$  SELECT array_agg((el->>'ref')::int8)   FROM jsonb_array_elements($1) AS el    WHERE el->>'type' = $2$_$;


ALTER FUNCTION public.planet_osm_member_ids(jsonb, character) OWNER TO admin;

--
-- Name: planet_osm_point_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.planet_osm_point_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


ALTER FUNCTION public.planet_osm_point_osm2pgsql_valid() OWNER TO admin;

--
-- Name: planet_osm_polygon_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.planet_osm_polygon_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


ALTER FUNCTION public.planet_osm_polygon_osm2pgsql_valid() OWNER TO admin;

--
-- Name: planet_osm_roads_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.planet_osm_roads_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


ALTER FUNCTION public.planet_osm_roads_osm2pgsql_valid() OWNER TO admin;

--
-- Name: set_updated_at_timestamp(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.set_updated_at_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at_timestamp() OWNER TO admin;

--
-- Name: setsrid(public.geometry, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.setsrid(public.geometry, integer) RETURNS public.geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-3', 'LWGEOM_set_srid';


ALTER FUNCTION public.setsrid(public.geometry, integer) OWNER TO admin;

--
-- Name: srid(public.geometry); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.srid(public.geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-3', 'LWGEOM_get_srid';


ALTER FUNCTION public.srid(public.geometry) OWNER TO admin;

--
-- Name: st_asbinary(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.st_asbinary(text) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_AsBinary($1::geometry);$_$;


ALTER FUNCTION public.st_asbinary(text) OWNER TO admin;

--
-- Name: st_astext(bytea); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.st_astext(bytea) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_AsText($1::geometry);$_$;


ALTER FUNCTION public.st_astext(bytea) OWNER TO admin;

--
-- Name: trg_create_internal_connections(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.trg_create_internal_connections() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  other_port RECORD;
BEGIN
  FOR other_port IN
    SELECT p.id, co.crossroad_id, p.is_inbound, p.is_outbound
    FROM crossroad_ports p
    JOIN crossroad_objects co ON p.id = co.id
    WHERE co.crossroad_id = (SELECT crossroad_id FROM crossroad_objects WHERE id = NEW.id)
      AND p.id <> NEW.id
  LOOP
    IF NEW.is_inbound AND other_port.is_outbound THEN
      PERFORM add_port_connection(NEW.id, other_port.id, NULL);
    ELSIF NEW.is_outbound AND other_port.is_inbound THEN
      PERFORM add_port_connection(other_port.id, NEW.id, NULL);
    END IF;
  END LOOP;

  RETURN NULL;
END;
$$;


ALTER FUNCTION public.trg_create_internal_connections() OWNER TO admin;

--
-- Name: gist_geometry_ops; Type: OPERATOR FAMILY; Schema: public; Owner: admin
--

CREATE OPERATOR FAMILY public.gist_geometry_ops USING gist;
ALTER OPERATOR FAMILY public.gist_geometry_ops USING gist ADD
    OPERATOR 1 public.<<(public.geometry,public.geometry) ,
    OPERATOR 2 public.&<(public.geometry,public.geometry) ,
    OPERATOR 3 public.&&(public.geometry,public.geometry) ,
    OPERATOR 4 public.&>(public.geometry,public.geometry) ,
    OPERATOR 5 public.>>(public.geometry,public.geometry) ,
    OPERATOR 6 public.~=(public.geometry,public.geometry) ,
    OPERATOR 7 public.~(public.geometry,public.geometry) ,
    OPERATOR 8 public.@(public.geometry,public.geometry) ,
    OPERATOR 9 public.&<|(public.geometry,public.geometry) ,
    OPERATOR 10 public.<<|(public.geometry,public.geometry) ,
    OPERATOR 11 public.|>>(public.geometry,public.geometry) ,
    OPERATOR 12 public.|&>(public.geometry,public.geometry) ,
    OPERATOR 13 public.<->(public.geometry,public.geometry) FOR ORDER BY pg_catalog.float_ops ,
    OPERATOR 14 public.<#>(public.geometry,public.geometry) FOR ORDER BY pg_catalog.float_ops ,
    FUNCTION 3 (public.geometry, public.geometry) public.geometry_gist_compress_2d(internal) ,
    FUNCTION 4 (public.geometry, public.geometry) public.geometry_gist_decompress_2d(internal) ,
    FUNCTION 8 (public.geometry, public.geometry) public.geometry_gist_distance_2d(internal,public.geometry,integer);


ALTER OPERATOR FAMILY public.gist_geometry_ops USING gist OWNER TO admin;

--
-- Name: gist_geometry_ops; Type: OPERATOR CLASS; Schema: public; Owner: admin
--

CREATE OPERATOR CLASS public.gist_geometry_ops
    FOR TYPE public.geometry USING gist FAMILY public.gist_geometry_ops AS
    STORAGE public.box2df ,
    FUNCTION 1 (public.geometry, public.geometry) public.geometry_gist_consistent_2d(internal,public.geometry,integer) ,
    FUNCTION 2 (public.geometry, public.geometry) public.geometry_gist_union_2d(bytea,internal) ,
    FUNCTION 5 (public.geometry, public.geometry) public.geometry_gist_penalty_2d(internal,internal,internal) ,
    FUNCTION 6 (public.geometry, public.geometry) public.geometry_gist_picksplit_2d(internal,internal) ,
    FUNCTION 7 (public.geometry, public.geometry) public.geometry_gist_same_2d(public.geometry,public.geometry,internal);


ALTER OPERATOR CLASS public.gist_geometry_ops USING gist OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: crossroad_object_geometries; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.crossroad_object_geometries (
    id integer NOT NULL,
    crossroad_object_id integer NOT NULL,
    geometry public.geometry(Geometry,4326) NOT NULL
);


ALTER TABLE public.crossroad_object_geometries OWNER TO admin;

--
-- Name: crossroad_object_geometries_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.crossroad_object_geometries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.crossroad_object_geometries_id_seq OWNER TO admin;

--
-- Name: crossroad_object_geometries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.crossroad_object_geometries_id_seq OWNED BY public.crossroad_object_geometries.id;


--
-- Name: crossroad_objects; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.crossroad_objects (
    id integer NOT NULL,
    crossroad_id integer NOT NULL,
    type public.crossroad_object_type NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    attributes jsonb
);


ALTER TABLE public.crossroad_objects OWNER TO admin;

--
-- Name: crossroad_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.crossroad_objects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.crossroad_objects_id_seq OWNER TO admin;

--
-- Name: crossroad_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.crossroad_objects_id_seq OWNED BY public.crossroad_objects.id;


--
-- Name: crossroad_ports; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.crossroad_ports (
    id integer NOT NULL,
    is_inbound boolean DEFAULT false NOT NULL,
    is_outbound boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_valid_direction CHECK ((is_inbound OR is_outbound))
);


ALTER TABLE public.crossroad_ports OWNER TO admin;

--
-- Name: crossroad_signal_connection_controls; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.crossroad_signal_connection_controls (
    signal_id integer NOT NULL,
    port_connection_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.crossroad_signal_connection_controls OWNER TO admin;

--
-- Name: crossroad_signals; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.crossroad_signals (
    id integer NOT NULL
);


ALTER TABLE public.crossroad_signals OWNER TO admin;

--
-- Name: crossroads; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.crossroads (
    id integer NOT NULL,
    name character varying(100),
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    attributes jsonb
);


ALTER TABLE public.crossroads OWNER TO admin;

--
-- Name: crossroads_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.crossroads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.crossroads_id_seq OWNER TO admin;

--
-- Name: crossroads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.crossroads_id_seq OWNED BY public.crossroads.id;


--
-- Name: osm2pgsql_properties; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.osm2pgsql_properties (
    property text NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.osm2pgsql_properties OWNER TO admin;

--
-- Name: planet_osm_line; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_line (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tracktype text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way_area real,
    way public.geometry(LineString,3857)
);


ALTER TABLE public.planet_osm_line OWNER TO admin;

--
-- Name: planet_osm_nodes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_nodes (
    id bigint NOT NULL,
    lat integer NOT NULL,
    lon integer NOT NULL,
    tags jsonb
);


ALTER TABLE public.planet_osm_nodes OWNER TO admin;

--
-- Name: planet_osm_point; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_point (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    capital text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    ele text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way public.geometry(Point,3857)
);


ALTER TABLE public.planet_osm_point OWNER TO admin;

--
-- Name: planet_osm_polygon; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_polygon (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tracktype text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way_area real,
    way public.geometry(Geometry,3857)
);


ALTER TABLE public.planet_osm_polygon OWNER TO admin;

--
-- Name: planet_osm_rels; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_rels (
    id bigint NOT NULL,
    members jsonb NOT NULL,
    tags jsonb
);


ALTER TABLE public.planet_osm_rels OWNER TO admin;

--
-- Name: planet_osm_roads; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_roads (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tracktype text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way_area real,
    way public.geometry(LineString,3857)
);


ALTER TABLE public.planet_osm_roads OWNER TO admin;

--
-- Name: planet_osm_ways; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.planet_osm_ways (
    id bigint NOT NULL,
    nodes bigint[] NOT NULL,
    tags jsonb
);


ALTER TABLE public.planet_osm_ways OWNER TO admin;

--
-- Name: port_connections; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.port_connections (
    id integer,
    crossroad_object_source_id integer NOT NULL,
    crossroad_object_destination_id integer NOT NULL,
    connection_type public.port_connection_type NOT NULL,
    CONSTRAINT chk_internal_id CHECK ((((connection_type = 'internal'::public.port_connection_type) AND (id IS NOT NULL)) OR ((connection_type = 'external'::public.port_connection_type) AND (id IS NULL)))),
    CONSTRAINT chk_no_self_connection CHECK ((crossroad_object_source_id <> crossroad_object_destination_id))
);


ALTER TABLE public.port_connections OWNER TO admin;

--
-- Name: crossroad_object_geometries id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_object_geometries ALTER COLUMN id SET DEFAULT nextval('public.crossroad_object_geometries_id_seq'::regclass);


--
-- Name: crossroad_objects id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_objects ALTER COLUMN id SET DEFAULT nextval('public.crossroad_objects_id_seq'::regclass);


--
-- Name: crossroads id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroads ALTER COLUMN id SET DEFAULT nextval('public.crossroads_id_seq'::regclass);


--
-- Name: crossroad_object_geometries crossroad_object_geometries_crossroad_object_id_geometry_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_object_geometries
    ADD CONSTRAINT crossroad_object_geometries_crossroad_object_id_geometry_key UNIQUE (crossroad_object_id, geometry);


--
-- Name: crossroad_object_geometries crossroad_object_geometries_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_object_geometries
    ADD CONSTRAINT crossroad_object_geometries_pkey PRIMARY KEY (id);


--
-- Name: crossroad_objects crossroad_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_objects
    ADD CONSTRAINT crossroad_objects_pkey PRIMARY KEY (id);


--
-- Name: crossroad_ports crossroad_ports_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_ports
    ADD CONSTRAINT crossroad_ports_pkey PRIMARY KEY (id);


--
-- Name: crossroad_signal_connection_controls crossroad_signal_connection_controls_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_signal_connection_controls
    ADD CONSTRAINT crossroad_signal_connection_controls_pkey PRIMARY KEY (signal_id, port_connection_id);


--
-- Name: crossroad_signals crossroad_signals_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_signals
    ADD CONSTRAINT crossroad_signals_pkey PRIMARY KEY (id);


--
-- Name: crossroads crossroads_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroads
    ADD CONSTRAINT crossroads_pkey PRIMARY KEY (id);


--
-- Name: osm2pgsql_properties osm2pgsql_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.osm2pgsql_properties
    ADD CONSTRAINT osm2pgsql_properties_pkey PRIMARY KEY (property);


--
-- Name: planet_osm_nodes planet_osm_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.planet_osm_nodes
    ADD CONSTRAINT planet_osm_nodes_pkey PRIMARY KEY (id);


--
-- Name: planet_osm_rels planet_osm_rels_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.planet_osm_rels
    ADD CONSTRAINT planet_osm_rels_pkey PRIMARY KEY (id);


--
-- Name: planet_osm_ways planet_osm_ways_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.planet_osm_ways
    ADD CONSTRAINT planet_osm_ways_pkey PRIMARY KEY (id);


--
-- Name: port_connections port_connections_id_crossroad_object_source_id_crossroad_ob_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.port_connections
    ADD CONSTRAINT port_connections_id_crossroad_object_source_id_crossroad_ob_key UNIQUE (id, crossroad_object_source_id, crossroad_object_destination_id);


--
-- Name: port_connections port_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.port_connections
    ADD CONSTRAINT port_connections_pkey PRIMARY KEY (crossroad_object_source_id, crossroad_object_destination_id);


--
-- Name: planet_osm_line_osm_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_line_osm_id_idx ON public.planet_osm_line USING btree (osm_id);


--
-- Name: planet_osm_line_way_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_line_way_idx ON public.planet_osm_line USING gist (way);


--
-- Name: planet_osm_point_osm_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_point_osm_id_idx ON public.planet_osm_point USING btree (osm_id);


--
-- Name: planet_osm_point_way_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_point_way_idx ON public.planet_osm_point USING gist (way);


--
-- Name: planet_osm_polygon_osm_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_polygon_osm_id_idx ON public.planet_osm_polygon USING btree (osm_id);


--
-- Name: planet_osm_polygon_way_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_polygon_way_idx ON public.planet_osm_polygon USING gist (way);


--
-- Name: planet_osm_rels_node_members_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_rels_node_members_idx ON public.planet_osm_rels USING gin (public.planet_osm_member_ids(members, 'N'::character(1))) WITH (fastupdate=off);


--
-- Name: planet_osm_rels_way_members_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_rels_way_members_idx ON public.planet_osm_rels USING gin (public.planet_osm_member_ids(members, 'W'::character(1))) WITH (fastupdate=off);


--
-- Name: planet_osm_roads_osm_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_roads_osm_id_idx ON public.planet_osm_roads USING btree (osm_id);


--
-- Name: planet_osm_roads_way_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_roads_way_idx ON public.planet_osm_roads USING gist (way);


--
-- Name: planet_osm_ways_nodes_bucket_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX planet_osm_ways_nodes_bucket_idx ON public.planet_osm_ways USING gin (public.planet_osm_index_bucket(nodes)) WITH (fastupdate=off);


--
-- Name: planet_osm_line planet_osm_line_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER planet_osm_line_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_line FOR EACH ROW EXECUTE FUNCTION public.planet_osm_line_osm2pgsql_valid();


--
-- Name: planet_osm_point planet_osm_point_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER planet_osm_point_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_point FOR EACH ROW EXECUTE FUNCTION public.planet_osm_point_osm2pgsql_valid();


--
-- Name: planet_osm_polygon planet_osm_polygon_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER planet_osm_polygon_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_polygon FOR EACH ROW EXECUTE FUNCTION public.planet_osm_polygon_osm2pgsql_valid();


--
-- Name: planet_osm_roads planet_osm_roads_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER planet_osm_roads_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_roads FOR EACH ROW EXECUTE FUNCTION public.planet_osm_roads_osm2pgsql_valid();


--
-- Name: crossroad_ports trg_after_insert_crossroad_port; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_after_insert_crossroad_port AFTER INSERT ON public.crossroad_ports FOR EACH ROW EXECUTE FUNCTION public.trg_create_internal_connections();


--
-- Name: crossroad_objects trg_set_updated_at__crossroad_objects; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_set_updated_at__crossroad_objects BEFORE UPDATE ON public.crossroad_objects FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: crossroads trg_set_updated_at__crossroads; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_set_updated_at__crossroads BEFORE UPDATE ON public.crossroads FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: crossroad_object_geometries crossroad_object_geometries_crossroad_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_object_geometries
    ADD CONSTRAINT crossroad_object_geometries_crossroad_object_id_fkey FOREIGN KEY (crossroad_object_id) REFERENCES public.crossroad_objects(id) ON DELETE CASCADE;


--
-- Name: crossroad_objects crossroad_objects_crossroad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_objects
    ADD CONSTRAINT crossroad_objects_crossroad_id_fkey FOREIGN KEY (crossroad_id) REFERENCES public.crossroads(id) ON DELETE CASCADE;


--
-- Name: crossroad_ports crossroad_ports_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_ports
    ADD CONSTRAINT crossroad_ports_id_fkey FOREIGN KEY (id) REFERENCES public.crossroad_objects(id) ON DELETE CASCADE;


--
-- Name: crossroad_signals crossroad_signals_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.crossroad_signals
    ADD CONSTRAINT crossroad_signals_id_fkey FOREIGN KEY (id) REFERENCES public.crossroad_objects(id) ON DELETE CASCADE;


--
-- Name: port_connections port_connections_crossroad_object_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.port_connections
    ADD CONSTRAINT port_connections_crossroad_object_destination_id_fkey FOREIGN KEY (crossroad_object_destination_id) REFERENCES public.crossroad_objects(id) ON DELETE CASCADE;


--
-- Name: port_connections port_connections_crossroad_object_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.port_connections
    ADD CONSTRAINT port_connections_crossroad_object_source_id_fkey FOREIGN KEY (crossroad_object_source_id) REFERENCES public.crossroad_objects(id) ON DELETE CASCADE;


--
-- Name: port_connections port_connections_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.port_connections
    ADD CONSTRAINT port_connections_id_fkey FOREIGN KEY (id) REFERENCES public.crossroad_objects(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

