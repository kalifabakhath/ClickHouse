-- Create a table designed to overwrite old data with the same ID
CREATE TABLE github_events_unique
(
    event_id String,
    event_type String,
    created_at DateTime,
    processed_time DateTime
)
ENGINE = ReplacingMergeTree(processed_time) -- Uses processed_time to determine the "latest" version
ORDER BY (event_id);
-- Having aggregated values

INSERT INTO github_events_unique 
SELECT 
    JSONExtractString(json, 'actor', 'login') AS event_id,
    JSONExtractString(json, 'type') AS event_type,
    parseDateTimeBestEffort(JSONExtractString(json, 'created_at')) AS created_at,
    parseDateTimeBestEffort(JSONExtractString(json, 'created_at')) AS processed_time
FROM url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONAsString');

select count(event_id) from github_events_unique
describe url('https://data.gharchive.org/2024-01-01-15.json.gz', 'JSONAsString');