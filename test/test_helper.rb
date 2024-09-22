$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "activerecord-clean-db-structure"
require 'activerecord-clean-db-structure/clean_dump'

require "minitest/autorun"
Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |rb| require(rb) }
