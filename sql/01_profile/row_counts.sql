-- Row count, sensor/parameter cardinality, date range
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT sensor_id)  AS distinct_sensors,
    COUNT(DISTINCT parameter)AS distinct_parameters,
    COUNT(DISTINCT unit)AS distinct_units,
    MIN(dt_from_utc_ts) AS earliest_reading,
    MAX(dt_from_utc_ts) AS latest_reading
FROM parsed_flat;
