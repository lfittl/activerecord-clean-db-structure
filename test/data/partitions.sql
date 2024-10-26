--
-- Name: autovacuum_run_stats_35d; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autovacuum_run_stats_35d (
    autovacuum_run_stats_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    server_id uuid,
    schema_table_id bigint,
    occurred_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (occurred_at);


--
-- Name: index_autovacuum_run_stats_35d_on_schema_table_id_occurred_at; Type: INDEX
--

CREATE INDEX index_autovacuum_run_stats_35d_on_schema_table_id_occurred_at ON public.autovacuum_run_stats_35d USING btree (schema_table_id, occurred_at);


--
-- Name: index_autovacuum_run_stats_35d_on_server_id_and_occurred_at; Type: INDEX
--

CREATE INDEX index_autovacuum_run_stats_35d_on_server_id_and_occurred_at ON public.autovacuum_run_stats_35d USING btree (server_id, occurred_at);


--
-- Name: autovacuum_run_stats_35d_20241026; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autovacuum_run_stats_35d_20241026 (
    autovacuum_run_stats_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    server_id uuid,
    schema_table_id bigint,
    occurred_at timestamp with time zone NOT NULL
);


--
-- Name: autovacuum_run_stats_35d_20241026; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autovacuum_run_stats_35d ATTACH PARTITION public.autovacuum_run_stats_35d_20241026 FOR VALUES FROM ('2024-10-25 19:00:00-05') TO ('2024-10-26 19:00:00-05');


--
-- Name: autovacuum_run_stats_35d_20241026 autovacuum_run_stats_35d_20241026_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autovacuum_run_stats_35d_20241026
    ADD CONSTRAINT autovacuum_run_stats_35d_20241026_pkey PRIMARY KEY (autovacuum_run_stats_id);


--
-- Name: autovacuum_run_stats_35d_20241026_server_id_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX autovacuum_run_stats_35d_20241026_server_id_occurred_at_idx ON public.autovacuum_run_stats_35d_20241026 USING btree (server_id, occurred_at);


--
-- Name: autovacuum_run_stats_35d_2024_schema_table_id_occurred_at_idx25; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX autovacuum_run_stats_35d_2024_schema_table_id_occurred_at_idx25 ON public.autovacuum_run_stats_35d_20241026 USING btree (schema_table_id, occurred_at);


--
-- Name: autovacuum_run_stats_35d_20241026_server_id_occurred_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_autovacuum_run_stats_35d_on_server_id_and_occurred_at ATTACH PARTITION public.autovacuum_run_stats_35d_20241026_server_id_occurred_at_idx;


--
-- Name: schema_table_infos_35d; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_table_infos_35d (
    schema_table_id bigint NOT NULL,
    collected_at timestamp with time zone NOT NULL,
    server_id uuid NOT NULL
)
PARTITION BY RANGE (collected_at);


--
-- Name: schema_table_infos_35d schema_table_infos_35d_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_table_infos_35d
    ADD CONSTRAINT schema_table_infos_35d_pkey PRIMARY KEY (schema_table_id, collected_at);


--
-- Name: schema_table_infos_35d_20240920; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_table_infos_35d_20240920 (
    schema_table_id bigint NOT NULL,
    collected_at timestamp with time zone NOT NULL,
    server_id uuid NOT NULL
);


--
-- Name: schema_table_infos_35d_20240920; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_table_infos_35d ATTACH PARTITION public.schema_table_infos_35d_20240920 FOR VALUES FROM ('2024-09-19 19:00:00-05') TO ('2024-09-20 19:00:00-05');


--
-- Name: schema_table_infos_35d_20240920 schema_table_infos_35d_20240920_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_table_infos_35d_20240920
    ADD CONSTRAINT schema_table_infos_35d_20240920_pkey PRIMARY KEY (schema_table_id, collected_at);


--
-- Name: schema_table_infos_35d_20240920_server_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schema_table_infos_35d_20240920_server_id_idx ON public.schema_table_infos_35d_20240920 USING btree (server_id);


--
-- Name: schema_table_infos_35d_2024092_schema_table_id_collected_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schema_table_infos_35d_2024092_schema_table_id_collected_at_idx ON public.schema_table_infos_35d_20240920 USING btree (schema_table_id, collected_at DESC);


--
-- Name: schema_table_infos_35d_20240920_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.schema_table_infos_35d_pkey ATTACH PARTITION public.schema_table_infos_35d_20240920_pkey;


--
-- Name: schema_table_infos_35d_20240920_server_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_schema_table_infos_35d_on_server_id ATTACH PARTITION public.schema_table_infos_35d_20240920_server_id_idx;
