
-- PostgreSQL database dump

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE TABLE public.model (
    id SERIAL PRIMARY KEY,
    alpha timestamp without time zone DEFAULT '2015-12-18 23:38:27.804383'::timestamp without time zone,
    beta timestamp without time zone DEFAULT '2016-05-10 14:01:06'::timestamp without time zone
);
