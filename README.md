## activerecord-clean-db-structure [ ![](https://img.shields.io/gem/v/activerecord-clean-db-structure.svg)](https://rubygems.org/gems/activerecord-clean-db-structure) [ ![](https://img.shields.io/gem/dt/activerecord-clean-db-structure.svg)](https://rubygems.org/gems/activerecord-clean-db-structure)

Ever been annoyed at a constantly changing `db/structure.sql` file when using ActiveRecord and Postgres?

Spent hours trying to decipher why that one team member keeps changing the file?

This library is here to help!

It cleans away all the unnecessary output in the file every time its updated automatically. This helps avoid merge conflicts, as well as increase readability.

## Installation

Add the following to your Gemfile:

```ruby
gem 'activerecord-clean-db-structure'
```

This will automatically hook the library into your `rake db:migrate` task.

## Supported Rails versions

Whilst there is no reason this shouldn't work on earlier versions, this has only been tested on Rails 4.2 and newer.

It also assumes you use ActiveRecord with PostgreSQL - other ORMs or databases are not supported.

## Caveats

Currently the library assumes all your `id` columns are either SERIAL, BIGSERIAL or uuid. It also assumes the `id` is the primary key.

Multi-column primary keys, as well as tables that don't have `id` as the primary key are not supported right now, and might lead to wrong output.

You can disable this part of the _cleaning_ process in your `config/environments/<environment>.rb` (or `config/application.rb`):

```ruby
Rails.application.configure do
  config.activerecord_clean_db_structure.ignore_ids = true
end
```

## Authors

* [Lukas Fittl](https://github.com/lfittl)

## License

Copyright (c) 2017, Lukas Fittl<br>
activerecord-clean-db-structure is licensed under the 3-clause BSD license, see LICENSE file for details.
