--
-- PostgreSQL database dump
--

\restrict 4dM75BbnS1l6mbbeHyatR0KIFJsU9gbErm3t0mCutpg5cmmeZkPGuvIesUEN9XZ

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.0

-- Started on 2026-01-28 18:27:30

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
-- TOC entry 6 (class 2615 OID 25679)
-- Name: off_dm; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA off_dm;


ALTER SCHEMA off_dm OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 25846)
-- Name: dim_brand; Type: TABLE; Schema: off_dm; Owner: postgres
--

CREATE TABLE off_dm.dim_brand (
    brand_sk bigint,
    brand_name text
);


ALTER TABLE off_dm.dim_brand OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 25856)
-- Name: dim_category; Type: TABLE; Schema: off_dm; Owner: postgres
--

CREATE TABLE off_dm.dim_category (
    category_sk bigint,
    category_name text
);


ALTER TABLE off_dm.dim_category OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 25851)
-- Name: dim_country; Type: TABLE; Schema: off_dm; Owner: postgres
--

CREATE TABLE off_dm.dim_country (
    country_sk bigint,
    country_name text
);


ALTER TABLE off_dm.dim_country OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 25865)
-- Name: dim_product; Type: TABLE; Schema: off_dm; Owner: postgres
--

CREATE TABLE off_dm.dim_product (
    product_sk bigint,
    code text,
    product_name text,
    brand_sk bigint,
    country_sk bigint,
    category_sk bigint,
    nutriscore_grade text,
    nova_group integer,
    pnns_groups_1 text,
    pnns_groups_2 text,
    completeness_score double precision,
    quality_issues_json text,
    attr_hash character varying(128),
    effective_from timestamp without time zone,
    effective_to timestamp without time zone,
    is_current boolean
);


ALTER TABLE off_dm.dim_product OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 25861)
-- Name: dim_time; Type: TABLE; Schema: off_dm; Owner: postgres
--

CREATE TABLE off_dm.dim_time (
    time_sk bigint,
    date date NOT NULL,
    year integer,
    month integer,
    day integer,
    week integer
);


ALTER TABLE off_dm.dim_time OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 25870)
-- Name: fact_nutrition_snapshot; Type: TABLE; Schema: off_dm; Owner: postgres
--

CREATE TABLE off_dm.fact_nutrition_snapshot (
    fact_id bigint,
    product_sk bigint,
    time_sk bigint,
    energy_kcal_100g double precision,
    fat_100g double precision,
    saturated_fat_100g double precision,
    sugars_100g double precision,
    salt_100g double precision,
    proteins_100g double precision,
    fiber_100g double precision,
    sodium_100g double precision,
    nutriscore_grade text,
    nova_group integer,
    completeness_score double precision,
    quality_issues_json text
);


ALTER TABLE off_dm.fact_nutrition_snapshot OWNER TO postgres;

-- Completed on 2026-01-28 18:27:31

--
-- PostgreSQL database dump complete
--

\unrestrict 4dM75BbnS1l6mbbeHyatR0KIFJsU9gbErm3t0mCutpg5cmmeZkPGuvIesUEN9XZ

