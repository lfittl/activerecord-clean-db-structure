require 'activerecord-clean-db-structure/clean_dump'

Rake::Task['db:structure:dump'].enhance do
  filenames = ENV['DB_STRUCTURE']
  filenames ||= Rails.application.config.paths['db'].map do |path|
    File.join(path, 'structure.sql')
  end

  filenames.each do |filename|
    cleaner = ActiveRecordCleanDbStructure::CleanDump.new(
      File.read(filename),
      **Rails.application.config.activerecord_clean_db_structure
    )
    cleaner.run
    File.write(filename, cleaner.dump)
  end
end
