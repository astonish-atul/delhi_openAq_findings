-- Parameter x unit x sensor x station-group profile
SELECT
    station_group,
    parameter,
    unit,
    sensor_id,
    COUNT(*)AS row_count,
    MIN(dt_from_utc_ts)AS min_ts,
    MAX(dt_from_utc_ts) AS max_ts,
    ROUND(MIN(value_num), 4) AS min_value,
    ROUND(MAX(value_num), 4)AS max_value,
    ROUND(AVG(value_num), 4) AS avg_value
FROM parsed_flat
GROUP BY station_group, parameter, unit, sensor_id
ORDER BY parameter, unit, sensor_id;
