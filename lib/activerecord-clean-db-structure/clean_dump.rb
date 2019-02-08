module ActiveRecordCleanDbStructure
  class CleanDump
    attr_reader :dump, :options

    def initialize(dump, options = {})
      @dump = dump
      @options = options
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

      unless options[:ignore_ids] == true
        # Reduce noise for id fields by making them SERIAL instead of integer+sequence stuff
        #
        # This is a bit optimistic, but works as long as you don't have an id field thats not a sequence/uuid
        dump.gsub!(/^    id integer NOT NULL(,)?$/, '    id SERIAL PRIMARY KEY\1')
        dump.gsub!(/^    id bigint NOT NULL(,)?$/, '    id BIGSERIAL PRIMARY KEY\1')
        dump.gsub!(/^    id uuid DEFAULT (public\.)?uuid_generate_v4\(\) NOT NULL(,)?$/, '    id uuid DEFAULT \1uuid_generate_v4() PRIMARY KEY\2')
        dump.gsub!(/^    id uuid DEFAULT (public\.)?gen_random_uuid\(\) NOT NULL(,)?$/, '    id uuid DEFAULT \1gen_random_uuid() PRIMARY KEY\2')
        dump.gsub!(/^CREATE SEQUENCE [\w\.]+_id_seq\s+(AS integer\s+)?START WITH 1\s+INCREMENT BY 1\s+NO MINVALUE\s+NO MAXVALUE\s+CACHE 1;$/, '')
        dump.gsub!(/^ALTER SEQUENCE [\w\.]+_id_seq OWNED BY .*;$/, '')
        dump.gsub!(/^ALTER TABLE ONLY [\w\.]+ ALTER COLUMN id SET DEFAULT nextval\('[\w\.]+_id_seq'::regclass\);$/, '')
        dump.gsub!(/^ALTER TABLE ONLY [\w\.]+\s+ADD CONSTRAINT [\w\.]+_pkey PRIMARY KEY \(id\);$/, '')
        dump.gsub!(/^-- Name: (\w+\s+)?id; Type: DEFAULT$/, '')
        dump.gsub!(/^-- .*_id_seq; Type: SEQUENCE.*/, '')
        dump.gsub!(/^-- Name: (\w+\s+)?\w+_pkey; Type: CONSTRAINT$/, '')
      end

      # Remove inherited tables
      inherited_tables_regexp = /-- Name: ([\w_\.]+); Type: TABLE\n\n[^;]+?INHERITS \([\w_\.]+\);/m
      inherited_tables = dump.scan(inherited_tables_regexp).map(&:first)
      dump.gsub!(inherited_tables_regexp, '')
      inherited_tables.each do |inherited_table|
        dump.gsub!(/ALTER TABLE ONLY (public\.)?#{inherited_table}[^;]+;/, '')

        index_regexp = /CREATE INDEX ([\w_]+) ON (public\.)?#{inherited_table}[^;]+;/m
        dump.scan(index_regexp).map(&:first).each do |inherited_table_index|
          dump.gsub!("-- Name: #{inherited_table_index}; Type: INDEX", '')
        end
        dump.gsub!(index_regexp, '')
      end

      # Remove partitioned tables
      partitioned_tables_regexp = /-- Name: ([\w_\.]+); Type: TABLE\n\n[^;]+?PARTITION OF [\w_\.]+\n[^;]+?;/m
      partitioned_tables = dump.scan(partitioned_tables_regexp).map(&:first)
      dump.gsub!(partitioned_tables_regexp, '')
      partitioned_tables.each do |partitioned_table|
        dump.gsub!(/ALTER TABLE ONLY (public\.)?#{partitioned_table}[^;]+;/, '')
        dump.gsub!(/-- Name: #{partitioned_table} [^;]+; Type: DEFAULT/, '')

        index_regexp = /CREATE INDEX ([\w_]+) ON (public\.)?#{partitioned_table}[^;]+;/m
        dump.scan(index_regexp).map(&:first).each do |partitioned_table_index|
          dump.gsub!("-- Name: #{partitioned_table_index}; Type: INDEX ATTACH", '')
          dump.gsub!("-- Name: #{partitioned_table_index}; Type: INDEX", '')
          dump.gsub!(/ALTER INDEX ([\w_\.]+) ATTACH PARTITION (public\.)?#{partitioned_table_index};/, '')
        end
        dump.gsub!(index_regexp, '')

        dump.gsub!(/-- Name: #{partitioned_table}_pkey; Type: INDEX ATTACH\n\n[^;]+?ATTACH PARTITION (public\.)?#{partitioned_table}_pkey;/, '')
      end
      # This is mostly done to allow restoring Postgres 11 output on Postgres 10
      dump.gsub!(/CREATE INDEX ([\w_]+) ON ONLY/, 'CREATE INDEX \\1 ON')

      # Remove whitespace between schema migration INSERTS to make editing easier
      dump.gsub!(/^(INSERT INTO schema_migrations .*)\n\n/, "\\1\n")

      # Extract indexes, remove comments and place indexes just after the respective tables
      indexes =
        dump
          .scan(/^CREATE.+INDEX.+ON.+\n/)
          .group_by { |line| line.scan(/\b\w+\.\w+\b/).first }
          .transform_values(&:join)

      dump.gsub!(/^CREATE( UNIQUE)? INDEX \w+ ON .+\n+/, '')
      dump.gsub!(/^-- Name: \w+; Type: INDEX\n+/, '')
      indexes.each do |table, indexes_for_table|
        dump.gsub!(/^(CREATE TABLE #{table}\b(:?[^;\n]*\n)+\);\n)/) { $1 + "\n" + indexes_for_table }
      end

      # Reduce 2+ lines of whitespace to one line of whitespace
      dump.gsub!(/\n{2,}/m, "\n\n")
    end
  end
end
