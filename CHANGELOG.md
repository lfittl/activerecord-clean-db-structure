# Changelog

## Unreleased

* ...

## 0.4.0    2019-08-27

* Add "indexes_after_tables" option to allow indexes to be placed following the respective tables [#13](https://github.com/lfittl/activerecord-clean-db-structure/pull/13) [Giovanni Kock Bonetti](https://github.com/giovannibonetti)
* Add "order_schema_migrations_values" option to prevent schema_migrations values causing merge conflicts [#15](https://github.com/lfittl/activerecord-clean-db-structure/pull/15) [Nicke van Oorschot](https://github.com/nvanoorschot)
* Add "order_column_definitions" option to sort table columns alphabetically [#11](https://github.com/lfittl/activerecord-clean-db-structure/pull/11) [RKushnir](https://github.com/RKushnir)
* Generalize handling of schema names to not assume public
* Rails 6 support
  * Fix Rails 6 compatibility [#16](https://github.com/lfittl/activerecord-clean-db-structure/pull/16) [Giovanni Kock Bonetti](https://github.com/giovannibonetti)
  * Fix handling of multiple structure.sql files
* Remove Postgres 12 specific GUCs
* Generalize handling of schema names to not assume public
* Fix whitespace issue for config settings, remove default_with_oids


## 0.3.0    2019-05-07

* Add "ignore_ids" option to allow disabling of primary key substitution logic [#12](https://github.com/lfittl/activerecord-clean-db-structure/pull/12) [Vladimir Dementyev](https://github.com/palkan)
* Compatibility with Rails 6 multi-database configuration


## 0.2.6    2018-03-11

* Fix regular expressions to support schema qualification changes in 10.3


## 0.2.5    2017-11-15

* Filter out indices belonging partitioned tables


## 0.2.4    2017-11-02

* Remove pg_buffercache extension if present (its only used for statistics purposes)
* Remove extension comments if present - they can prevent non-superusers from
  restoring the tables, and are never used together with Rails anyway


## 0.2.3    2017-10-21

* pg 10.x adds AS Integer to structure.sql format [Nathan Woodhull](https://github.com/woodhull)


## 0.2.2    2017-08-05

* Support Rails 5.1 primary key UUIDs that rely on gen_random_uuid()


## 0.2.1    2017-06-30

* Allow primary keys to be the last column of a table [Clemens Kofler](https://github.com/clemens)
  - Special thanks to [Jon Mohrbacher](https://github.com/johnnymo87) who submitted a similar earlier change


## 0.2.0    2017-03-20

* Reduce dependencies to only require ActiveRecord [Mario Uher](https://github.com/ream88)
* Support Rails Engines [Mario Uher](https://github.com/ream88)
* Clean up more comment lines [Clemens Kofler](https://github.com/clemens)


## 0.1.0    2017-02-12

* Initial release.
