-- The Dimension Table (Taxi Zones) --1. Create the lookup table
CREATE TABLE taxi_zones (
    LocationID UInt16,
    Borough String,
    Zone String,
    service_zone String
) ENGINE = MergeTree()
ORDER BY LocationID;

-- 2. Ingest directly from ClickHouse's public S3 bucket
INSERT INTO taxi_zones
SELECT * FROM url(
    'https://datasets-documentation.s3.eu-west-3.amazonaws.com/nyc-taxi/taxi_zone_lookup.csv', 
    'CSVWithNames'
);

select * from taxi_zones

--------------------------------------------------------------------------------------------------------------------
--The Fact Table (Understanding PK vs. ORDER BY)---------------------

CREATE TABLE nyc_trips (
    VendorID UInt8,
    tpep_pickup_datetime DateTime,
    PULocationID UInt16, -- Pick Up Location
    DOLocationID UInt16, -- Drop Off Location
    passenger_count UInt8,
    trip_distance Float32,
    fare_amount Float32,
    total_amount Float32
) ENGINE = MergeTree()
ORDER BY (VendorID, PULocationID, tpep_pickup_datetime) -- The physical disk sorting (3 columns)
PRIMARY KEY (VendorID, PULocationID); -- The RAM index (2 columns)