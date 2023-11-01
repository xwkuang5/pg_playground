CREATE OR REPLACE FUNCTION table_id_to_table_name(table_id int) RETURNS TEXT
AS $$ SELECT 'test_' || table_id $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION create_table_if_not_exist(table_id int) RETURNS boolean
AS $$
#print_strict_params on
BEGIN
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