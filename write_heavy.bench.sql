\set txn_value random(0, 100000)
\set write_knob random(0, 100)
\set table_id random_zipfian(0, 10000, 1.5)

BEGIN;

SELECT create_table_if_not_exist(table_id_to_table_name(:table_id));

SELECT do_transaction(table_id_to_table_name(:table_id), :write_knob <= 49, :txn_value);

END;