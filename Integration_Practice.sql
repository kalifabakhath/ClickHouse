-- Describe 
-- This shows you exactly what columns and types ClickHouse detected
DESCRIBE url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONAsString');

-- Notice we don't need JSONExtract because 'type' is already a column
SELECT  top 3 * 
FROM url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONEachRow') 

-- Querying a public JSON file directly from the internet
SELECT 
    JSONExtractString(json,'org', 'login') AS user,
    count() as events
FROM url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONAsString')
GROUP BY user
ORDER BY events DESC
LIMIT 5;


