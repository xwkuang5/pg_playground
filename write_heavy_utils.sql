CREATE OR REPLACE FUNCTION table_id_to_table_name(table_id int) RETURNS TEXT
AS $$ SELECT 'test_' || table_id $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION create_table_if_not_exist(table_id int) RETURNS boolean
AS $$
#print_strict_params on
BEGIN
    -- This lock is only necessary in the benchmark to avoid clients from being aborted due
    -- to concurrent `CREATE TABLE` DDL. In a real workload, we should be able to ignore error
    -- due to race to create etable. An alternative is to use the single check idiom to first
    -- check if the table exists and only create the table if the table does not exist. However,
    -- the query itself ends up dominating the latency of the overall workload due to complicated
    -- join required when querying `information_schema.tables`
    -- As long as the `table_id` is drawn from a large enough range, the chances of two clients waiting
    -- accessing the same table and thus landing on the same lock should be low.
    PERFORM pg_advisory_xact_lock(table_id);
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || table_id_to_table_name(table_id) || '(id serial PRIMARY KEY, value int)';
    return true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION do_transaction(table_id int, is_write boolean, value int) RETURNS boolean
AS $$
#print_strict_params on
DECLARE
ret boolean;
BEGIN
    IF is_write THEN
        EXECUTE 'INSERT INTO ' || table_id_to_table_name(table_id) || '(value) VALUES (' || value || ')';
    ELSE
        EXECUTE 'SELECT * FROM ' || table_id_to_table_name(table_id) || ' WHERE id = ' || value;
    END IF;
    return true;
END;
$$ LANGUAGE plpgsql;