-- DQ007: NOx must be >= NO alone (NOx = NO + NO2 by chemical definition)
WITH no_ AS (SELECT dt_from_utc_ts, value_num AS no_val   FROM parsed_flat WHERE parameter = 'no'),
     nox AS (SELECT dt_from_utc_ts, value_num AS nox_val  FROM parsed_flat WHERE parameter = 'nox'),
     matched AS (
        SELECT no_.dt_from_utc_ts, no_val, nox_val
        FROM no_ JOIN nox USING (dt_from_utc_ts)
     )
SELECT 'DQ007' AS rule_id,
       (SELECT COUNT(*) FROM matched) AS evaluated_count,
       (SELECT COUNT(*) FROM matched WHERE nox_val < no_val) AS failed_count;

-- DQ008: declared period window (dt_to - dt_from) must equal the declared interval (15 minutes)
SELECT 'DQ008' AS rule_id, COUNT(*) AS evaluated_count,
       SUM(CASE WHEN date_diff('minute', dt_from_utc_ts, dt_to_utc_ts) <> 15 THEN 1 ELSE 0 END) AS failed_count
FROM parsed_flat;
