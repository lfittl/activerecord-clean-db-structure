# frozen_string_literal: true

RSpec.describe ActiveRecordCleanDbStructure::CleanDump do
  context 'with empty comment lines' do
    let(:sql_dump) { file_fixture('spec/fixtures/empty_comments.sql').read }
    let(:cleaner) { described_class.new sql_dump.clone }
    let(:expected_columns) do
      [
        ');',
        '',
        '-- useless comment'
      ]
    end

    it 'removes empty comments lines' do
      cleaner.run
      expect(cleaner.dump.split("\n").last(3)).to eq expected_columns
    end
  end

  context 'with unnecessary whitespace' do
    let(:sql_dump) { file_fixture('spec/fixtures/ending_whitespace.sql').read }
    let(:cleaner) { described_class.new sql_dump.clone }

    it 'removes empty whitespace lines' do
      cleaner.run
      expect(cleaner.dump).to end_with ");\n\n"
    end
  end

  context 'with order_column_definitions option' do
    let(:sql_dump) { file_fixture('spec/fixtures/unordered_columns.sql').read }
    let(:cleaner) { described_class.new sql_dump.clone, order_column_definitions: true }
    let(:expected_columns) do
      [
        'CREATE TABLE public.model (',
        '    alpha character varying(255),',
        '    beta character varying(255),',
        '    gamma character varying(255),',
        '    id SERIAL PRIMARY KEY',
        ');'
      ]
    end

    it 'sorts columns alphabetically' do
      cleaner.run
      expect(cleaner.dump.split("\n").last(6)).to eq expected_columns
    end
  end

  context 'without order_column_definitions option' do
    let(:sql_dump) { file_fixture('spec/fixtures/unordered_columns.sql').read }
    let(:cleaner) { described_class.new sql_dump.clone }
    let(:expected_columns) do
      [
        'CREATE TABLE public.model (',
        '    id SERIAL PRIMARY KEY,',
        '    beta character varying(255),',
        '    gamma character varying(255),',
        '    alpha character varying(255)',
        ');'
      ]
    end

    it 'does not sort columns' do
      cleaner.run
      expect(cleaner.dump.split("\n").last(6)).to eq expected_columns
    end
  end

  context 'with force_datetime_default_format' do
    context 'with Time object passed' do
      let(:sql_dump) { file_fixture('spec/fixtures/dates.sql').read }
      let(:cleaner) { described_class.new sql_dump.clone, force_datetime_default_format: Time.new(2019, 5, 6, 16, 44, 22) }
      let(:expected_columns) do
        [
          "    alpha timestamp without time zone DEFAULT '2019-05-06 16:44:22'::timestamp without time zone,",
          "    beta timestamp without time zone DEFAULT '2019-05-06 16:44:22'::timestamp without time zone",
          ');'
        ]
      end

      it 'forces all dates to be same datetime' do
        cleaner.run
        expect(cleaner.dump.split("\n").last(3)).to eq expected_columns
      end
    end

    context 'with true passed' do
      let(:sql_dump) { file_fixture('spec/fixtures/dates.sql').read }
      let(:cleaner) { described_class.new sql_dump.clone, force_datetime_default_format: true }
      let(:expected_columns) do
        [
          "    alpha timestamp without time zone DEFAULT '2015-12-18 23:38:27'::timestamp without time zone,",
          "    beta timestamp without time zone DEFAULT '2016-05-10 14:01:06'::timestamp without time zone",
          ');'
        ]
      end

      it 'forces all dates to be same format' do
        cleaner.run
        expect(cleaner.dump.split("\n").last(3)).to eq expected_columns
      end
    end
  end

  context 'without force_datetime_default_format' do
    let(:sql_dump) { file_fixture('spec/fixtures/dates.sql').read }
    let(:cleaner) { described_class.new sql_dump.clone }
    let(:expected_columns) do
      [
        "    alpha timestamp without time zone DEFAULT '2015-12-18 23:38:27.804383'::timestamp without time zone,",
        "    beta timestamp without time zone DEFAULT '2016-05-10 14:01:06'::timestamp without time zone",
        ');'
      ]
    end

    it 'leaves dates defaults as is' do
      cleaner.run
      expect(cleaner.dump.split("\n").last(3)).to eq expected_columns
    end
  end
end
