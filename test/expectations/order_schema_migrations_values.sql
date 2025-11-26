SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = '';

-- Name: ar_internal_metadata; Type: TABLE

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

-- Name: delayed_jobs; Type: TABLE

CREATE TABLE public.delayed_jobs (
    id BIGSERIAL PRIMARY KEY,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    whodunnit text
)
WITH (fillfactor='85');

-- Name: schema_migrations; Type: TABLE

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

-- Name: index_delayed_jobs_on_locked_by; Type: INDEX

CREATE INDEX index_delayed_jobs_on_locked_by ON public.delayed_jobs USING btree (locked_by);

-- Name: index_delayed_jobs_on_queue; Type: INDEX

CREATE INDEX index_delayed_jobs_on_queue ON public.delayed_jobs USING btree (queue);

-- Name: index_delayed_jobs_on_failed_at_IS_NULL; Type: INDEX

CREATE INDEX "index_delayed_jobs_on_failed_at_IS_NULL" ON public.delayed_jobs USING btree (((failed_at IS NULL)));

-- Name: index_delayed_jobs_on_run_at; Type: INDEX

CREATE INDEX index_delayed_jobs_on_run_at ON public.delayed_jobs USING btree (run_at) WHERE (locked_at IS NULL);

-- PostgreSQL database dump complete

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
 ('20210903003251')
,('20210923052631')
,('20211012054749')
,('20211125055031')
,('20220802204003')
,('20240621020038')
,('20240621041110')
,('20240725043656')
,('20240822224954')
,('20240822225012')
;

