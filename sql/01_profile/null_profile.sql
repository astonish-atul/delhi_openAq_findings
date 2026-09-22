-- Null rate per key field
SELECT 'value_num' AS column_name, SUM(CASE WHEN value_num   IS NULL THEN 1 ELSE 0 END) AS null_count, COUNT(*) AS row_count FROM parsed_flat
UNION ALL
SELECT 'sensor_id', SUM(CASE WHEN sensor_id IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM parsed_flat
UNION ALL
SELECT 'parameter', SUM(CASE WHEN parameter IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM parsed_flat
UNION ALL
SELECT 'unit',SUM(CASE WHEN unit IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM parsed_flat
UNION ALL
SELECT 'dt_from_utc_ts', SUM(CASE WHEN dt_from_utc_ts IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM parsed_flat
UNION ALL
SELECT 'coordinates', SUM(CASE WHEN coordinates IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM parsed_flat
UNION ALL
SELECT 'summary',SUM(CASE WHEN summary IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM parsed_flat;
