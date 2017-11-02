# Changelog

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
