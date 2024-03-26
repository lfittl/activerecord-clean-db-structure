require './test/spec_helper'
require 'activerecord-clean-db-structure/clean_dump'

class PrimaryKeyTest < Minitest::Spec
  described_class = ActiveRecordCleanDbStructure::CleanDump

  describe 'Primary key on create table' do
    dump = <<~SQL
      --
      -- Name: users; Type: TABLE; Schema: public; Owner: -
      --

      CREATE TABLE public.users (
        id bigint NOT NULL,
        name character varying NOT NULL,#{'        '}
        created_at timestamp(6) without time zone NOT NULL
      );
      --
      -- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
      --

      ALTER TABLE ONLY public.users
        ADD CONSTRAINT users_pkey PRIMARY KEY (id);

      --
      -- PostgreSQL database dump complete
      --
    SQL

    it 'Adds primary key to create table' do
      assert_equal <<~SQL, described_class.new(dump).run

        -- Name: users; Type: TABLE

        CREATE TABLE public.users (
          id bigint PRIMARY KEY,
          name character varying NOT NULL,
          created_at timestamp(6) without time zone NOT NULL
        );

        -- PostgreSQL database dump complete
      SQL
    end
  end

  describe 'Composite primary key on create table' do
    it "Doesn't add primary key to create table" do
      dump = <<~SQL
        --
        -- Name: storage_tables_blobs; Type: TABLE; Schema: public; Owner: -
        --

        CREATE TABLE public.storage_tables_blobs (
          partition_key character(1) NOT NULL,
          checksum character(85) NOT NULL,
          attachments_count_modified timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
          attachments_count integer DEFAULT 0 NOT NULL,
          byte_size bigint NOT NULL,
          content_type character varying,
          metadata jsonb
        )
        PARTITION BY LIST (partition_key);

        --
        -- Name: storage_tables_blobs storage_tables_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
        --

        ALTER TABLE ONLY public.storage_tables_blobs
          ADD CONSTRAINT storage_tables_blobs_pkey PRIMARY KEY (checksum, partition_key);

        --
        -- PostgreSQL database dump complete
        --
      SQL

      assert_equal <<~SQL, described_class.new(dump).run

        -- Name: storage_tables_blobs; Type: TABLE

        CREATE TABLE public.storage_tables_blobs (
          partition_key character(1) NOT NULL,
          checksum character(85) NOT NULL,
          attachments_count_modified timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
          attachments_count integer DEFAULT 0 NOT NULL,
          byte_size bigint NOT NULL,
          content_type character varying,
          metadata jsonb
        )
        PARTITION BY LIST (partition_key);

        -- Name: storage_tables_blobs storage_tables_blobs_pkey; Type: CONSTRAINT

        ALTER TABLE ONLY public.storage_tables_blobs
          ADD CONSTRAINT storage_tables_blobs_pkey PRIMARY KEY (checksum, partition_key);

        -- PostgreSQL database dump complete
      SQL
    end
  end
end
