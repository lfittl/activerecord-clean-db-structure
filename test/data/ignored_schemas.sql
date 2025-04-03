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
-- Name: myschema; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA myschema;


--
-- Name: pganalyze; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pganalyze;


--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA myschema;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: pg_buffercache; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA public;


--
-- Name: EXTENSION pg_buffercache; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_buffercache IS 'examine the shared buffer cache';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: myschema; Type: TYPE; Schema: myschema; Owner: -
--

CREATE TYPE myschema.myenum AS ENUM (
    'a',
    'b',
    'c'
);


--
-- Name: explain_analyze(text, text[], text[], text[]); Type: FUNCTION; Schema: pganalyze; Owner: -
--

CREATE FUNCTION pganalyze.explain_analyze(query text, params text[], param_types text[], analyze_flags text[]) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  prepared_query text;
  params_str text;
  param_types_str text;
  explain_prefix text;
  explain_flag text;
  result text;
BEGIN
  SET TRANSACTION READ ONLY;

  PERFORM 1 FROM pg_roles WHERE (rolname = current_user AND rolsuper) OR (pg_has_role(oid, 'MEMBER') AND rolname IN ('rds_superuser', 'azure_pg_admin', 'cloudsqlsuperuser'));
  IF FOUND THEN
    RAISE EXCEPTION 'cannot run: pganalyze.explain_analyze helper is owned by superuser - recreate function with lesser privileged user';
  END IF;

  SELECT pg_catalog.regexp_replace(query, ';+\s*\Z', '') INTO prepared_query;
  IF prepared_query LIKE '%;%' THEN
    RAISE EXCEPTION 'cannot run pganalyze.explain_analyze helper with a multi-statement query';
  END IF;

  explain_prefix := 'EXPLAIN (VERBOSE, FORMAT JSON';
  FOR explain_flag IN SELECT * FROM unnest(analyze_flags)
  LOOP
    IF explain_flag NOT SIMILAR TO '[A-z_ ]+' THEN
      RAISE EXCEPTION 'cannot run pganalyze.explain_analyze helper with invalid flag';
    END IF;
    explain_prefix := explain_prefix || ', ' || explain_flag;
  END LOOP;
  explain_prefix := explain_prefix || ') ';

  SELECT COALESCE('(' || pg_catalog.string_agg(pg_catalog.quote_literal(p), ',') || ')', '') FROM pg_catalog.unnest(params) _(p) INTO params_str;
  SELECT COALESCE('(' || pg_catalog.string_agg(pg_catalog.quote_ident(p), ',') || ')', '') FROM pg_catalog.unnest(param_types) _(p) INTO param_types_str;

  EXECUTE 'PREPARE pganalyze_explain_analyze ' || param_types_str || ' AS ' || prepared_query;
  BEGIN
    EXECUTE explain_prefix || 'EXECUTE pganalyze_explain_analyze' || params_str INTO STRICT result;
  EXCEPTION WHEN QUERY_CANCELED OR OTHERS THEN
    DEALLOCATE pganalyze_explain_analyze;
    RAISE;
  END;
  DEALLOCATE pganalyze_explain_analyze;

  RETURN result;
END
$$;


--
-- Name: get_stat_replication(); Type: FUNCTION; Schema: pganalyze; Owner: -
--

CREATE FUNCTION pganalyze.get_stat_replication() RETURNS SETOF pg_stat_replication
    LANGUAGE sql SECURITY DEFINER
    AS $$
  /* pganalyze-collector */ SELECT * FROM pg_catalog.pg_stat_replication;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: table2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.table2 (
    id bigint NOT NULL,
);


--
-- Name: test_func2(public.table2[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.test_func2(ids public.table2[] DEFAULT NULL::public.table2[]) RETURNS TABLE(id bigint)
    LANGUAGE sql ROWS 10000 PARALLEL SAFE
    AS $$
  SELECT * FROM 
$$;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: myschema; Type: TABLE; Schema: myschema; Owner: -
--

CREATE TABLE myschema.mytable (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: index_mytable_on_organization_id; Type: INDEX; Schema: myschema; Owner: -
--

CREATE INDEX index_mytable_on_organization_id ON myschema.mytable USING btree (organization_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250101011234'),
('20250101015678');

