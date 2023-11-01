\set txn_value random(0, 1000000)
\set write_knob random(0, 100)
\set table_id random_zipfian(0, 10000, 1.01)
-- \set table_id random(0, 10000)

BEGIN;

SELECT create_table_if_not_exist(:table_id);

SELECT do_transaction(:table_id, :write_knob <= 49, :txn_value);

END;