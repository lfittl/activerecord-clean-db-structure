module ActiveRecordCleanDbStructure
  class CleanDump
    attr_reader :dump
    def initialize(dump)
      @dump = dump
    end

    def run
      # Remove trailing whitespace
      dump.gsub!(/[ \t]+$/, '')
      dump.gsub!(/\A\n/, '')
      dump.gsub!(/\n\n\z/, "\n")

      # Remove version-specific output
      dump.gsub!(/^-- Dumped.*/, '')
      dump.gsub!(/^SET row_security = off;$/, '') # 9.5
      dump.gsub!(/^SET idle_in_transaction_session_timeout = 0;$/, '') # 9.6

      # Remove pg_stat_statements extension (its not relevant to the code)
      dump.gsub!(/^CREATE EXTENSION IF NOT EXISTS pg_stat_statements.*/, '')
      dump.gsub!(/^-- Name: (EXTENSION )?pg_stat_statements;.*/, '')

      # Remove pg_buffercache extension (its not relevant to the code)
      dump.gsub!(/^CREATE EXTENSION IF NOT EXISTS pg_buffercache.*/, '')
      dump.gsub!(/^-- Name: (EXTENSION )?pg_buffercache;.*/, '')

      # Remove comments on extensions, they create problems if the extension is owned by another user
      dump.gsub!(/^COMMENT ON EXTENSION .*/, '')

      # Remove useless, version-specific parts of comments
      dump.gsub!(/^-- (.*); Schema: (public|-); Owner: -.*/, '-- \1')

      # Remove useless comment lines
      dump.gsub!(/^--$/, '')

      # Reduce noise for id fields by making them SERIAL instead of integer+sequence stuff
      #
      # This is a bit optimistic, but works as long as you don't have an id field thats not a sequence/uuid
      dump.gsub!(/^    id integer NOT NULL(,)?$/, '    id SERIAL PRIMARY KEY\1')
      dump.gsub!(/^    id bigint NOT NULL(,)?$/, '    id BIGSERIAL PRIMARY KEY\1')
      dump.gsub!(/^    id uuid DEFAULT uuid_generate_v4\(\) NOT NULL(,)?$/, '    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY\1')
      dump.gsub!(/^    id uuid DEFAULT gen_random_uuid\(\) NOT NULL(,)?$/, '    id uuid DEFAULT gen_random_uuid() PRIMARY KEY\1')
      dump.gsub!(/^CREATE SEQUENCE \w+_id_seq\s+(AS integer\s+)?START WITH 1\s+INCREMENT BY 1\s+NO MINVALUE\s+NO MAXVALUE\s+CACHE 1;$/, '')
      dump.gsub!(/^ALTER SEQUENCE \w+_id_seq OWNED BY .*;$/, '')
      dump.gsub!(/^ALTER TABLE ONLY \w+ ALTER COLUMN id SET DEFAULT nextval\('\w+_id_seq'::regclass\);$/, '')
      dump.gsub!(/^ALTER TABLE ONLY \w+\s+ADD CONSTRAINT \w+_pkey PRIMARY KEY \(id\);$/, '')
      dump.gsub!(/^-- Name: (\w+\s+)?id; Type: DEFAULT$/, '')
      dump.gsub!(/^-- .*_id_seq; Type: SEQUENCE.*/, '')
      dump.gsub!(/^-- Name: (\w+\s+)?\w+_pkey; Type: CONSTRAINT$/, '')

      # Remove inherited tables
      inherited_tables_regexp = /-- Name: ([\w_]+); Type: TABLE\n\n[^;]+?INHERITS \([\w_]+\);/m
      inherited_tables = dump.scan(inherited_tables_regexp).map(&:first)
      dump.gsub!(inherited_tables_regexp, '')
      inherited_tables.each do |inherited_table|
        dump.gsub!(/ALTER TABLE ONLY #{inherited_table}[^;]+;/, '')
      end

      # Remove whitespace between schema migration INSERTS to make editing easier
      dump.gsub!(/^(INSERT INTO schema_migrations .*)\n\n/, "\\1\n")

      # Reduce 2+ lines of whitespace to one line of whitespace
      dump.gsub!(/\n{2,}/m, "\n\n")
    end
  end
end
