$:.push File.expand_path('../lib', __FILE__)
require 'activerecord-clean-db-structure/version'

Gem::Specification.new do |s|
  s.name        = 'activerecord-clean-db-structure'
  s.version     = ActiveRecordCleanDbStructure::VERSION
  s.summary     = 'Automatic cleanup for the Rails db/structure.sql file (ActiveRecord/PostgreSQL)'
  s.description = 'Never worry about weird diffs and merge conflicts again'
  s.authors     = ['Lukas Fittl']
  s.email       = 'lukas@fittl.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ['lib']
  s.homepage      = 'https://github.com/lfittl/activerecord-clean-db-structure'
  s.license       = 'MIT'

  s.add_dependency('activerecord', '>= 4.2')

  s.add_development_dependency 'rake', '~> 13'
end
