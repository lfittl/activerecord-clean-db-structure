module ActiveRecordCleanDbStructure
  class Railtie < Rails::Railtie
    config.activerecord_clean_db_structure = ActiveSupport::OrderedOptions.new

    rake_tasks do
      load 'activerecord-clean-db-structure/tasks/clean_db_structure.rake'
    end
  end
end
