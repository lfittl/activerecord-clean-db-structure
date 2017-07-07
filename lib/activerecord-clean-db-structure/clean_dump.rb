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
      dump.gsub!(/^COMMENT ON EXTENSION pg_stat_statements.*/, '')
      dump.gsub!(/^-- Name: (EXTENSION )?pg_stat_statements;.*/, '')

      # Remove useless, version-specific parts of comments
      dump.gsub!(/^-- (.*); Schema: (public|-); Owner: -.*/, '-- \1')

      # Remove useless comment lines
      dump.gsub!(/^--$/, '')

      # Mask user mapping
      dump.gsub!(
        /^CREATE USER MAPPING FOR \w+ SERVER (\w+) .*;/m,
        'CREATE USER MAPPING FOR some_user SERVER \1;'
      )
      dump.gsub!(
        /^-- Name: USER MAPPING \w+ SERVER (\w+); Type: USER MAPPING/,
        '-- Name: USER MAPPING some_user SERVER \1; Type: USER MAPPING'
      )

      # Reduce noise for id fields by making them SERIAL instead of integer+sequence stuff
      #
      # This is a bit optimistic, but works as long as you don't have an id field thats not a sequence/uuid
      is_table = false, count_open_brackets = 0, count_close_brackets = 0
      @dump = dump.lines.map do |line|
        is_table = true if line =~ /CREATE TABLE (\w+) \(/

        count_open_brackets  += line.count('(')
        count_close_brackets += line.count(')')

        is_table = false if is_table && count_open_brackets == count_close_brackets

        if !is_table # optimization speed
          line
        elsif line =~ /^    id integer NOT NULL/
          line.sub('id integer NOT NULL', 'id SERIAL PRIMARY KEY')
        elsif line =~ /^    id bigint NOT NULL/
          line.sub('id bigint NOT NULL', 'id BIGSERIAL PRIMARY KEY')
        else
          line
        end
      end.join

      dump.gsub!(/^    id uuid DEFAULT uuid_generate_v4\(\) NOT NULL,$/, '    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,')
      dump.gsub!(/^CREATE SEQUENCE \w+_id_seq\s+START WITH 1\s+INCREMENT BY 1\s+NO MINVALUE\s+NO MAXVALUE\s+CACHE 1;$/, '')
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
