
-- Name: autovacuum_run_stats_35d; Type: TABLE

CREATE TABLE public.autovacuum_run_stats_35d (
    autovacuum_run_stats_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    server_id uuid,
    schema_table_id bigint,
    occurred_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (occurred_at);

-- Name: index_autovacuum_run_stats_35d_on_schema_table_id_occurred_at; Type: INDEX

CREATE INDEX index_autovacuum_run_stats_35d_on_schema_table_id_occurred_at ON public.autovacuum_run_stats_35d USING btree (schema_table_id, occurred_at);

-- Name: index_autovacuum_run_stats_35d_on_server_id_and_occurred_at; Type: INDEX

CREATE INDEX index_autovacuum_run_stats_35d_on_server_id_and_occurred_at ON public.autovacuum_run_stats_35d USING btree (server_id, occurred_at);

-- Name: schema_table_infos_35d; Type: TABLE

CREATE TABLE public.schema_table_infos_35d (
    schema_table_id bigint NOT NULL,
    collected_at timestamp with time zone NOT NULL,
    server_id uuid NOT NULL
)
PARTITION BY RANGE (collected_at);

ALTER TABLE ONLY public.schema_table_infos_35d
    ADD CONSTRAINT schema_table_infos_35d_pkey PRIMARY KEY (schema_table_id, collected_at);

