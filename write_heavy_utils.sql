CREATE OR REPLACE FUNCTION table_id_to_table_name(id int) RETURNS TEXT
AS $$ SELECT 'test_' || id $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION create_table_if_not_exist(tab_name text) RETURNS boolean
AS $$
#print_strict_params on
BEGIN
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || tab_name || '(id serial PRIMARY KEY, value int)';
    return true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION do_transaction(tab_name text, is_write boolean, value int) RETURNS boolean
AS $$
#print_strict_params on
DECLARE
ret boolean;
BEGIN
    IF is_write THEN
        EXECUTE 'INSERT INTO ' || tab_name || '(value) VALUES (' || value || ')';
    ELSE
        EXECUTE 'SELECT * FROM ' || tab_name || ' WHERE id = ' || value;
    END IF;
    return true;
END;
$$ LANGUAGE plpgsql;