-- DQ001: value must not be null
SELECT 'DQ001' AS rule_id, COUNT(*) AS evaluated_count,
       SUM(CASE WHEN value_num IS NULL THEN 1 ELSE 0 END) AS failed_count
FROM parsed_flat;

-- DQ002: identifying fields must not be null
SELECT 'DQ002' AS rule_id, COUNT(*) AS evaluated_count,
       SUM(CASE WHEN sensor_id IS NULL OR parameter IS NULL OR unit IS NULL THEN 1 ELSE 0 END) AS failed_count
FROM parsed_flat;

-- DQ003: coordinates/summary metadata completeness 
SELECT 'DQ003' AS rule_id, COUNT(*) AS evaluated_count,
       SUM(CASE WHEN coordinates IS NULL AND summary IS NULL THEN 1 ELSE 0 END) AS failed_count
FROM parsed_flat;
