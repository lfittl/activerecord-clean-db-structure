require "test_helper"

class CleanDumpTest < Minitest::Test
  def test_basic_case
    assert_cleans_dump "expectations/default_props.sql", {}
  end

  def test_ignore_ids
    assert_cleans_dump "expectations/ignore_ids.sql", { ignore_ids: true }
  end

  def test_order_column_definitions
    assert_cleans_dump "expectations/order_column_definitions.sql", { order_column_definitions: true }
  end

  def test_order_schema_migrations_values
    assert_cleans_dump "expectations/order_schema_migrations_values.sql", { order_schema_migrations_values: true }
  end

  def test_indexes_after_tables
    assert_cleans_dump "expectations/indexes_after_tables.sql", { indexes_after_tables: true }
  end

  def test_keep_extensions_all
    assert_cleans_dump "expectations/keep_extensions_all.sql", { keep_extensions: :all }
  end

  private

  def assert_cleans_dump(expected_output_path, props)
    cleaner = ActiveRecordCleanDbStructure::CleanDump.new(File.read(File.join(__dir__, "data/input.sql")), props)
    cleaner.run
    assert_equal File.read(File.join(__dir__, expected_output_path)), cleaner.dump
  end
end
