-- DQ004: one row per (sensor_id, dt_from_utc)
WITH dupes AS (
    SELECT sensor_id, dt_from_utc, COUNT(*) AS occurrences
    FROM parsed_flat
    GROUP BY sensor_id, dt_from_utc
    HAVING COUNT(*) > 1
)
SELECT 'DQ004' AS rule_id,
       (SELECT COUNT(*) FROM parsed_flat) AS evaluated_count,
       COALESCE((SELECT SUM(occurrences) FROM dupes), 0) AS failed_count;
