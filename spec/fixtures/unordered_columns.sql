
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
    beta character varying(255),
    gamma character varying(255),
    alpha character varying(255)
);
