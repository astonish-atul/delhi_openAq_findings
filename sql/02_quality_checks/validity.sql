-- DQ005: physically implausible values (negative concentrations/RH/speed, RH>100, wind_direction out of [0,360))
SELECT 'DQ005' AS rule_id, COUNT(*) AS evaluated_count,
       SUM(CASE
             WHEN value_num < 0 THEN 1
             WHEN parameter = 'relativehumidity' AND value_num > 100 THEN 1
             WHEN parameter = 'wind_direction' AND (value_num < 0 OR value_num >= 360) THEN 1
             ELSE 0
           END) AS failed_count
FROM parsed_flat;

-- DQ006: a parameter should resolve to a single unit across the whole extract
WITH unit_counts AS (
    SELECT parameter, COUNT(DISTINCT unit) AS n_units
    FROM parsed_flat
    GROUP BY parameter
),
mixed_params AS (
    SELECT parameter FROM unit_counts WHERE n_units > 1
)
SELECT 'DQ006' AS rule_id,
       (SELECT COUNT(*) FROM parsed_flat) AS evaluated_count,
       (SELECT COUNT(*) FROM parsed_flat WHERE parameter IN (SELECT parameter FROM mixed_params)) AS failed_count;
