# mysqldump-process-scripts

Scripts to process mysqldump file.

## complete-insert.pl

Add columns to INSERT lines like --complete-insert option.

## innodb-optimize-keys.pl

Move add key processes after inserting records like --innodb-optimize-keys option.

## select-tables.pl

Select specified tables from mysqldump file.

### usage

``` bash
$ mysqldump db_name | perl select-tables.pl table_a table_b
```

## LICENSE

MIT License

