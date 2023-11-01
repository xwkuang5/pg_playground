## PostgreSQL Playground

A PostgreSQL playground where I experiment with different PostgreSQL behavior.

Snippets:

* [inverted_int4_ops.sql](./inverted_int4_ops.sql): snippet showing how to define a new operator class for the `int4` type that uses the reverse of natural ordering for comparison operator
* [write_heavy.bench.sql](./write_heavy.bench.sql): measure the overhead of dynamically creating table on the fly
  * Pre-req: create a test database (e.g., `testdb`) and copy paste the functions in [write_heavy_utils.sql](./write_heavy_utils.sql) in the database
  * Run `PGOPTIONS='--client-min-messages=warning' PGPASSWORD=<password> pgbench -U <user> testdb --client=8 --jobs=8 --progress=5 --time=100 --no-vacuum --report-per-command --max-tries=3 -f write_heavy.bench.sql`