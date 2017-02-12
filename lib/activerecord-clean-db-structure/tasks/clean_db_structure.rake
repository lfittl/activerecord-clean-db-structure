require 'activerecord-clean-db-structure/clean_dump'

Rake::Task['db:structure:dump'].enhance do
  Rake::Task['clean_db_structure'].invoke
end

task :clean_db_structure do
  filename = ENV['DB_STRUCTURE'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'structure.sql')

  cleaner = ActiveRecordCleanDbStructure::CleanDump.new(File.read(filename))
  cleaner.run
  File.write(filename, cleaner.dump)
end
