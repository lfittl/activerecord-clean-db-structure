module ActiveRecordCleanDbStructure
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'activerecord-clean-db-structure/tasks/clean_db_structure.rake'
    end
  end
end
