module ActiveRecordCleanDbStructure
  class CleanDump
    attr_reader :dump, :options

    def initialize(dump, options = {})
      @dump = dump
      @options = options
    end

    def run
      clean_partition_tables # Must be first because it makes assumptions about string format
      clean
      clean_inherited_tables
      clean_options
    end

    def clean
      # Remove trailing whitespace
      dump.gsub!(/[ \t]+$/, '')
      dump.gsub!(/\A\n/, '')
      dump.gsub!(/\n\n\z/, "\n")

      # Remove version-specific output
      dump.gsub!(/^-- Dumped.*/, '')
      dump.gsub!(/^SET row_security = off;\n/m, '') # 9.5
      dump.gsub!(/^SET idle_in_transaction_session_timeout = 0;\n/m, '') # 9.6
      dump.gsub!(/^SET transaction_timeout = 0;\n/m, '') # 17
      dump.gsub!(/^SET default_with_oids = false;\n/m, '') # all older than 12
      dump.gsub!(/^SET xmloption = content;\n/m, '') # 12
      dump.gsub!(/^SET default_table_access_method = heap;\n/m, '') # 12

      extensions_to_remove = ["pg_stat_statements", "pg_buffercache"]
      if options[:keep_extensions] == :all
        extensions_to_remove = [] 
      elsif options[:keep_extensions]
        extensions_to_remove -= Array(options[:keep_extensions])
      end
      extensions_to_remove.each do |ext|
        dump.gsub!(/^CREATE EXTENSION IF NOT EXISTS #{ext}.*/, '')
        dump.gsub!(/^-- Name: (EXTENSION )?#{ext};.*/, '')
      end

      # Remove comments on extensions, they create problems if the extension is owned by another user
      dump.gsub!(/^COMMENT ON EXTENSION .*/, '')

      # Remove useless, version-specific parts of comments
      dump.gsub!(/^-- (.*); Schema: ([\w\.]+|-); Owner: -.*/, '-- \1')

      # Remove useless comment lines
      dump.gsub!(/^--$/, '')

      unless options[:ignore_ids] == true
        # Reduce noise for id fields by making them SERIAL instead of integer+sequence stuff
        #
        # This is a bit optimistic, but works as long as you don't have an id field thats not a sequence/uuid
        dump.gsub!(/^    id integer NOT NULL(,)?$/, '    id SERIAL PRIMARY KEY\1')
        dump.gsub!(/^    id bigint NOT NULL(,)?$/, '    id BIGSERIAL PRIMARY KEY\1')
        dump.gsub!(/^    id uuid DEFAULT ([\w]+\.)?uuid_generate_v4\(\) NOT NULL(,)?$/, '    id uuid DEFAULT \1uuid_generate_v4() PRIMARY KEY\2')
        dump.gsub!(/^    id uuid DEFAULT ([\w]+\.)?gen_random_uuid\(\) NOT NULL(,)?$/, '    id uuid DEFAULT \1gen_random_uuid() PRIMARY KEY\2')
        dump.gsub!(/^CREATE SEQUENCE [\w\.]+_id_seq\s+(AS integer\s+)?START WITH 1\s+INCREMENT BY 1\s+NO MINVALUE\s+NO MAXVALUE\s+CACHE 1;$/, '')
        dump.gsub!(/^ALTER SEQUENCE [\w\.]+_id_seq OWNED BY .*;$/, '')
        dump.gsub!(/^ALTER TABLE ONLY [\w\.]+ ALTER COLUMN id SET DEFAULT nextval\('[\w\.]+_id_seq'::regclass\);$/, '')
        dump.gsub!(/^ALTER TABLE ONLY [\w\.]+\s+ADD CONSTRAINT [\w\.]+_pkey PRIMARY KEY \(id\);$/, '')
        dump.gsub!(/^-- Name: (\w+\s+)?id; Type: DEFAULT$/, '')
        dump.gsub!(/^-- .*_id_seq; Type: SEQUENCE.*/, '')
        dump.gsub!(/^-- Name: (\w+\s+)?\w+_pkey; Type: CONSTRAINT$/, '')
      end
    end

    def clean_inherited_tables
      inherited_tables_regexp = /-- Name: ([\w\.]+); Type: TABLE\n\n[^;]+?INHERITS \([\w\.]+\);/m
      inherited_tables = dump.scan(inherited_tables_regexp).map(&:first)
      dump.gsub!(inherited_tables_regexp, '')
      inherited_tables.each do |inherited_table|
        dump.gsub!(/ALTER TABLE ONLY ([\w_]+\.)?#{inherited_table}[^;]+;/, '')

        index_regexp = /CREATE INDEX ([\w_]+) ON ([\w_]+\.)?#{inherited_table}[^;]+;/m
        dump.scan(index_regexp).map(&:first).each do |inherited_table_index|
          dump.gsub!("-- Name: #{inherited_table_index}; Type: INDEX", '')
        end
        dump.gsub!(index_regexp, '')
      end
    end

    def clean_partition_tables
      partitioned_tables = []

      # Postgres 12 pg_dump will output separate ATTACH PARTITION statements (even when run against an 11 or older server)
      partitioned_tables_regexp1 = /ALTER TABLE ONLY [\w\.]+ ATTACH PARTITION ([\w\.]+)/
      partitioned_tables += dump.scan(partitioned_tables_regexp1).map(&:last)

      # Earlier versions use an inline PARTITION OF
      partitioned_tables_regexp2 = /-- Name: ([\w\.]+); Type: TABLE\n\n[^;]+?PARTITION OF [\w\.]+\n[^;]+?;/m
      partitioned_tables += dump.scan(partitioned_tables_regexp2).map(&:first)

      # We assume that a comment + schema statement pair has 3 trailing newlines.
      # This makes it easier to drop both the comment and statement at once.
      statements = dump.split("\n\n\n")
      names = []
      partitioned_tables.each { |table| names << table.split('.', 2)[1] }
      if names.any?
        dump.scan(/CREATE (UNIQUE )?INDEX ([\w_]+) ON ([\w_]+\.)?(#{names.join('|')})[^;]+;/m).each { |m| names << m[1] }
      end
      statements.reject! { |stmt| names.any? { |name| stmt.include?(name) } }
      @dump = statements.join("\n\n")
      @dump << "\n" if @dump[-1] != "\n"

      # This is mostly done to allow restoring Postgres 11 output on Postgres 10
      dump.gsub!(/CREATE INDEX ([\w]+) ON ONLY/, 'CREATE INDEX \\1 ON')
    end

    def clean_options
      if options[:order_schema_migrations_values] == true
        schema_migrations_cleanup
      else
        # Remove whitespace between schema migration INSERTS to make editing easier
        dump.gsub!(/^(INSERT INTO schema_migrations .*)\n\n/, "\\1\n")
      end

      if options[:indexes_after_tables] == true
        # Extract indexes, remove comments and place them just after the respective tables
        indexes =
          dump
            .scan(/^CREATE.+INDEX.+ON.+\n/)
            .group_by { |line| line.scan(/\b\w+\.\w+\b/).first }
            .transform_values(&:join)

        dump.gsub!(/^CREATE( UNIQUE)? INDEX \w+ ON .+\n+/, '')
        dump.gsub!(/^-- Name: \w+; Type: INDEX\n+/, '')
        indexes.each do |table, indexes_for_table|
          dump.gsub!(/^(CREATE TABLE #{table}\b(:?[^;\n]*\n)+\);*\n(?:.*);*)/) { $1 + "\n\n" + indexes_for_table }
        end
      end

      # Reduce 2+ lines of whitespace to one line of whitespace
      dump.gsub!(/\n{2,}/m, "\n\n")

      if options[:order_column_definitions] == true
        dump.replace(order_column_definitions(dump))
      end
    end

    def order_column_definitions(source)
      result = []

      parse_column_name = ->(line) { line.match(/^    "?([^" ]+)/)[1] }
      with_column_separator = ->(line) { line.sub(/,?\n$/, ",\n") }
      without_column_separator = ->(line) { line.sub(/,\n$/, "\n") }

      inside_table = false
      columns = []

      source.each_line do |source_line|
        if source_line.start_with?("CREATE TABLE")
          inside_table = true
          columns = []
          result << source_line
        elsif source_line.start_with?(")")
          if inside_table
            inside_table = false
            columns.sort_by!(&:first)

            columns[0..-2].each do |_, line|
              result << with_column_separator[line]
            end

            result << without_column_separator[columns.last[1]]
          end

          result << source_line
        elsif inside_table
          columns << [parse_column_name[source_line], source_line]
        else
          result << source_line
        end
      end

      result.join
    end

    private

    # Cleanup of schema_migrations values to prevent merge conflicts:
    # - sorts all values chronological
    # - places the comma's in front of each value (except for the first)
    # - places the semicolon on a separate last line
    def schema_migrations_cleanup
      # Read all schema_migrations values from the dump.
      values = dump.scan(/^(\(\'\d{14}\'\))[,;]\n/).flatten.sort

      # Replace the schema_migrations values.
      dump.sub!(
        /(?<=INSERT INTO "schema_migrations" \(version\) VALUES).+;\n*/m,
        "\n #{values.join("\n,")}\n;\n\n"
      )
    end
  end
end
