
--Inspect Online Timeseries sythetic Data
SELECT  top 3 * 
FROM url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONEachRow') 

Created Inre
select top 30 * from github_events_raw

--merge Tree materialized table 
CREATE TABLE github_events
(
    event_id String,
    event_type String,
    actor_login LowCardinality(String), -- Optimization: Good for columns with many repeats
    repo_name String,
    created_at DateTime,
    updated_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(created_at) -- Physical separation by month
ORDER BY (event_type, created_at, event_id) -- How the Sparse Index is built
SETTINGS index_granularity = 8192;

SELECT 
    parseDateTimeBestEffort(JSONExtractString(json, 'created_at') )
    FROM url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONAsString')

select count(actor_login) from github_events
INSERT INTO github_events (event_id, event_type, actor_login, repo_name, created_at)
SELECT 
    JSONExtractString(json, 'id'),
    JSONExtractString(json, 'type'),
    JSONExtractString(json, 'actor', 'login'),
    JSONExtractString(json, 'repo', 'name'),
    parseDateTimeBestEffort(JSONExtractString(json, 'created_at'))
FROM url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONAsString');