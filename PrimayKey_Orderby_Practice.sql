-- Table A: Sorted by ID
CREATE TABLE test_order_id (
    id UInt64,
    event_time DateTime,
    data String
) ENGINE = MergeTree()
ORDER BY id;

-- Table B: Sorted by Time
CREATE TABLE test_order_time (
    id UInt64,
    event_time DateTime,
    data String
) ENGINE = MergeTree()
ORDER BY event_time;


--SYS Table--------------------------------------------------------------------------------------------------------------------
SELECT 
    table, 
    name AS part_name, 
    rows, 
    active
FROM system.parts
WHERE table LIKE 'test_order_%' and active= 1;

--Forcing the table parts to be merged---------------------------------------------------------------------------------------
OPTIMIZE TABLE test_order_id FINAL;
OPTIMIZE TABLE test_order_time FINAL;

--querying the table look the order ------------------------------------------------------------------------------------------
-- Check Table A (Ordered by ID)
SELECT * FROM test_order_id;
-- Result: You'll see IDs 1, 2, 3 in perfect order.

-- Check Table B (Ordered by Time)
SELECT * FROM test_order_time;
-- Result: You'll see the timestamps in order, but IDs might be 1, 2, 3 
-- (because our timestamps happened to match the IDs in this specific case).

-- Querying by ID on a table ordered by ID (Fast Skip)------------------------------------------------------------------
EXPLAIN indexes = 1
SELECT * FROM test_order_id WHERE id = 1;

-- Querying by ID on a table ordered by Time (Slow Scan)
EXPLAIN indexes = 1
SELECT * FROM test_order_time WHERE id = 1;