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

  def test_indexes_after_tables
    assert_cleans_dump "data/input.sql", "expectations/indexes_after_tables.sql", indexes_after_tables: true
  end

  def test_keep_extensions_all
    assert_cleans_dump "data/input.sql", "expectations/keep_extensions_all.sql", keep_extensions: :all
  end

  def test_partitions
    assert_cleans_dump "data/partitions.sql", "expectations/partitions.sql"
  end

  private

  def assert_cleans_dump(input, output, props = {})
    cleaner = ActiveRecordCleanDbStructure::CleanDump.new(File.read(File.join(__dir__, input)), props)
    cleaner.run
    assert_equal File.read(File.join(__dir__, output)), cleaner.dump
  end
end
