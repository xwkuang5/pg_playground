-- SQL snippet demonstrating the relationship between access method, strategy number and operator class
-- Reference: https://www.postgresql.org/docs/current/xindex.html#XINDEX-HASH-STRAT-TABLE
CREATE FUNCTION inverted_btint4cmp(int4, int4) RETURNS integer
    AS 'select -1 * btint4cmp($1, $2);'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;

-- Create an operator class where `<` is mapped to `>` and the support function inverted.
CREATE OPERATOR CLASS inverted_int4_ops
    FOR TYPE int4 USING btree AS
        OPERATOR        1       > ,
        OPERATOR        2       >= ,
        OPERATOR        3       = ,
        OPERATOR        4       <= ,
        OPERATOR        5       < ,
        FUNCTION        1       inverted_btint4cmp(int4, int4);

CREATE TABLE InvertedOperatorClass (id int, val int4);

INSERT INTO InvertedOperatorClass VALUES (1, 1);
INSERT INTO InvertedOperatorClass VALUES (2, 2);
INSERT INTO InvertedOperatorClass VALUES (3, 3);

SET enable_seqscan=OFF;

CREATE INDEX ON InvertedOperatorClass (val inverted_int4_ops ASC);

-- pgfirestore=# EXPLAIN SELECT * FROM InvertedOperatorClass WHERE val > 1;
--                                                 QUERY PLAN
-- -----------------------------------------------------------------------------------------------------------
--  Index Scan using invertedoperatorclass_val_idx on invertedoperatorclass  (cost=0.13..8.15 rows=1 width=8)
--    Index Cond: (val > 1)
-- (2 rows)

-- pgfirestore=# SELECT * FROM InvertedOperatorClass WHERE val > 1;
--  id | val
-- ----+-----
--   3 |   3
--   2 |   2
-- (2 rows)

-- pgfirestore=# SELECT * FROM InvertedOperatorClass WHERE val > 0;
--  id | val
-- ----+-----
--   3 |   3
--   2 |   2
--   1 |   1
-- (3 rows)

DROP OPERATOR CLASS inverted_int4_ops using btree CASCADE;

-- Create an operator class where `<` is mapped to `>`
-- Note the support function is intentionally left as `btint4cmp`
-- so that using the resulting btree for index scans will produce
-- the wrong results.
CREATE OPERATOR CLASS inverted_int4_ops
    FOR TYPE int4 USING btree AS
        OPERATOR        1       > ,
        OPERATOR        2       >= ,
        OPERATOR        3       = ,
        OPERATOR        4       <= ,
        OPERATOR        5       < ,
        FUNCTION        1       btint4cmp(int4, int4);

CREATE INDEX ON InvertedOperatorClass (val inverted_int4_ops ASC);

-- pgfirestore-#         FUNCTION        1       inverted_btint4cmp(int4, int4);
--         FUNCTION        1       inverted_btint4cmp(int4, int4);
-- pgfirestore=# EXPLAIN SELECT * FROM InvertedOperatorClass WHERE val > 1;
--                                                 QUERY PLAN
-- -----------------------------------------------------------------------------------------------------------
--  Index Scan using invertedoperatorclass_val_idx on invertedoperatorclass  (cost=0.13..8.15 rows=1 width=8)
--    Index Cond: (val > 1)
-- (2 rows)

-- The query predicate `< 3` becomes `> 3` for the btree
-- The on-disk btree index entry layout is `[1, 2, 3]` due to the support function
-- Combining the above we can predict that the query will produce 0
-- results because there's no more index entries after 3.
-- pgfirestore=# SELECT * FROM InvertedOperatorClass WHERE val < 3;
--  id | val
-- ----+-----
-- (0 rows)

DROP OPERATOR CLASS inverted_int4_ops using btree CASCADE;

DROP TABLE InvertedOperatorClass;