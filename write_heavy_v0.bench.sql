\set txn_value random(0, 1000000)
\set write_knob random(0, 100)
\set table_id 1

BEGIN;

SELECT do_transaction(:table_id, :write_knob <= 49, :txn_value);

END;