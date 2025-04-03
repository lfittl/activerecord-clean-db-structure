SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

-- Name: myschema; Type: SCHEMA

CREATE SCHEMA myschema;

-- Name: btree_gin; Type: EXTENSION

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA myschema;

-- Name: EXTENSION btree_gin; Type: COMMENT

-- Name: btree_gist; Type: EXTENSION

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;

-- Name: EXTENSION btree_gist; Type: COMMENT

-- Name: dblink; Type: EXTENSION

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;

-- Name: EXTENSION dblink; Type: COMMENT

-- Name: pgcrypto; Type: EXTENSION

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

-- Name: EXTENSION pgcrypto; Type: COMMENT

-- Name: uuid-ossp; Type: EXTENSION

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

-- Name: EXTENSION "uuid-ossp"; Type: COMMENT

-- Name: myschema; Type: TYPE

CREATE TYPE myschema.myenum AS ENUM (
    'a',
    'b',
    'c'
);

SET default_tablespace = '';

-- Name: table2; Type: TABLE

CREATE TABLE public.table2 (
    id BIGSERIAL PRIMARY KEY,
);

-- Name: test_func2(public.table2[]); Type: FUNCTION

CREATE FUNCTION public.test_func2(ids public.table2[] DEFAULT NULL::public.table2[]) RETURNS TABLE(id bigint)
    LANGUAGE sql ROWS 10000 PARALLEL SAFE
    AS $$
  SELECT * FROM
$$;

-- Name: ar_internal_metadata; Type: TABLE

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

-- Name: myschema; Type: TABLE

CREATE TABLE myschema.mytable (
    id uuid DEFAULT public.gen_random_uuid() PRIMARY KEY,
    organization_id uuid NOT NULL
);

-- Name: schema_migrations; Type: TABLE

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);

-- Name: index_mytable_on_organization_id; Type: INDEX

CREATE INDEX index_mytable_on_organization_id ON myschema.mytable USING btree (organization_id);

-- Name: unique_schema_migrations; Type: INDEX

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);

-- PostgreSQL database dump complete

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250101011234'),
('20250101015678');
