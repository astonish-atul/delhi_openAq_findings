-- DQ009: observed 15-minute slots vs. expected slots within each sensor's own min/max window
WITH sensor_bounds AS (
    SELECT sensor_id, MIN(dt_from_utc_ts) AS min_ts, MAX(dt_from_utc_ts) AS max_ts
    FROM parsed_flat
    GROUP BY sensor_id
),
expected AS (
    SELECT sb.sensor_id, gs.slot
    FROM sensor_bounds sb,
         LATERAL generate_series(sb.min_ts, sb.max_ts, INTERVAL 15 MINUTE) AS gs(slot)
),
observed AS (
    SELECT sensor_id, dt_from_utc_ts AS slot FROM parsed_flat
)
SELECT 'DQ009' AS rule_id,
       (SELECT COUNT(*) FROM expected) AS evaluated_count,
       (SELECT COUNT(*) FROM expected e
          LEFT JOIN observed o ON e.sensor_id = o.sensor_id AND e.slot = o.slot
         WHERE o.slot IS NULL) AS failed_count;

-- DQ010: diagnostic - self-reported coverage metadata never varies despite real gaps found in DQ009
SELECT 'DQ010' AS rule_id,
       COUNT(*) AS evaluated_count,
       SUM(CASE WHEN percentComplete = 100.0 AND percentCoverage = 100.0 THEN 1 ELSE 0 END) AS rows_claiming_full_coverage,
       COUNT(DISTINCT percentComplete) AS distinct_percentComplete_values_seen
FROM parsed_flat;
