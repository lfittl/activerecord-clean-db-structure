require "test_helper"

class CleanDumpTest < Minitest::Test
  def test_basic_case
    assert_cleans_dump "data/input.sql", "expectations/default_props.sql"
  end

  def test_ignore_ids
    assert_cleans_dump "data/input.sql", "expectations/ignore_ids.sql", ignore_ids: true
  end

  def test_order_column_definitions
    assert_cleans_dump "data/input.sql", "expectations/order_column_definitions.sql", order_column_definitions: true
  end

  def test_order_schema_migrations_values
    assert_cleans_dump "data/input.sql", "expectations/order_schema_migrations_values.sql", order_schema_migrations_values: true
  end

  def test_meta_tables_after_main
    assert_cleans_dump "data/input.sql", "expectations/meta_tables_after_main.sql", meta_tables_after_main: true
  end

  def test_keep_extensions_all
    assert_cleans_dump "data/input.sql", "expectations/keep_extensions_all.sql", keep_extensions: :all
  end

  def test_partitions
    assert_cleans_dump "data/partitions.sql", "expectations/partitions.sql"
  end

  def test_ignored_schemas
    assert_cleans_dump "data/ignored_schemas.sql", "expectations/ignored_schemas_pganalyze.sql", ignore_schemas: ['pganalyze']
    assert_cleans_dump "data/ignored_schemas.sql", "expectations/ignored_schemas_myschema.sql", ignore_schemas: ['myschema']
  end

  private

  def assert_cleans_dump(input, output, props = {})
    cleaner = ActiveRecordCleanDbStructure::CleanDump.new(File.read(File.join(__dir__, input)), props)
    cleaner.run
    assert_equal File.read(File.join(__dir__, output)), cleaner.dump
  end
end
