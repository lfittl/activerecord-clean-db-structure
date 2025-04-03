SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

-- Name: pganalyze; Type: SCHEMA

CREATE SCHEMA pganalyze;

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

-- Name: explain_analyze(text, text[], text[], text[]); Type: FUNCTION

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

-- Name: get_stat_replication(); Type: FUNCTION

CREATE FUNCTION pganalyze.get_stat_replication() RETURNS SETOF pg_stat_replication
    LANGUAGE sql SECURITY DEFINER
    AS $$
  /* pganalyze-collector */ SELECT * FROM pg_catalog.pg_stat_replication;
$$;

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

-- Name: schema_migrations; Type: TABLE

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);

-- Name: unique_schema_migrations; Type: INDEX

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);

-- PostgreSQL database dump complete

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250101011234'),
('20250101015678');
