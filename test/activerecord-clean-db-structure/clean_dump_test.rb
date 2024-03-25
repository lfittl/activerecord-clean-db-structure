require "./test/spec_helper"
require "activerecord-clean-db-structure/clean_dump"

class CleanDumpTest < Minitest::Spec
  described_class = ActiveRecordCleanDbStructure::CleanDump
  
  describe "Clean primary keys" do
    dump = <<~SQL
      --
      -- Name: users; Type: TABLE; Schema: public; Owner: -
      --

      CREATE TABLE public.users (
        id bigint NOT NULL,
        name character varying NOT NULL,        
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

    it "Adds primary key to create table" do
      assert_equal described_class.new(dump).run, <<~SQL

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
end

