# Data Dictionary — openaq_new_delhi_measurements

**Grain:** one row = one sensor's reading for one 15-minute time window
(`sensor_id` × `dt_from_utc`). Each `sensor_id` measures exactly one `parameter`
for its entire history in this extract (verified 1:1 during profiling).

| Field | Meaning | Type | Nullable | Source | Used for |
|---|---|---|---|---|---|
| value | Measured reading for the parameter/interval | Float | No (business rule) | OpenAQ sensor export | KPI, validity checks |
| flagInfo | Whether OpenAQ flagged the reading (`hasFlags`) | Struct (parsed) | No | OpenAQ | Diagnostic only — constant `False` in this extract |
| parameter | Pollutant/met parameter code (co, no, no2, nox, o3, pm10, pm25, so2, temperature, relativehumidity, wind_speed, wind_direction) | String | No | OpenAQ | Grouping, validity, consistency |
| period | Nested struct: label, interval, datetimeFrom/To (UTC + local) | Struct (parsed into dt_from_utc / dt_to_utc / dt_from_local) | No | OpenAQ | Grain, timeliness, consistency |
| coordinates | Station lat/long | String | Expected populated; **always NULL in this extract** | OpenAQ | Flagged as a completeness gap (DQ003) |
| summary | Summary statistics for the interval | String | Expected populated; **always NULL in this extract** | OpenAQ | Flagged as a completeness gap (DQ003) |
| coverage | Nested struct: expectedCount, observedCount, percentComplete, percentCoverage, window | Struct (parsed) | No | OpenAQ | Timeliness diagnostic — found to be self-reported and constant (DQ010) |
| sensor_id | Numeric sensor identifier | Integer | No (business key) | OpenAQ | Join key, grouping, uniqueness |
| unit | Unit of measure for `value` | String | No | OpenAQ | Validity, consistency (unit-per-parameter check) |

## Derived fields (added during profiling)

| Field | Meaning |
|---|---|
| dt_from_utc / dt_to_utc | Parsed interval start/end (UTC) from `period` |
| station_group | Inferred grouping: `legacy_2016` (sensor_id ∈ {35, 36, 392, 393, 394, 399}) vs `current_2025` (all other sensor_ids). **Inferred from the sensor-ID/date-range split observed during profiling — the raw extract carries no explicit station or location_id field**, so this label is an analytical convenience, not a confirmed source attribute. |
| row_id | Synthetic surrogate key assigned during profiling for exception traceability |

## Why NULL is not automatically a defect — and where it is here

- `coordinates` / `summary` being NULL for every one of the 18,000 rows is unusual enough
  (100% null rate, not a partial gap) that it is treated as a completeness finding (DQ003)
  rather than dismissed — but it is documented as **provisional/medium severity** because we
  cannot confirm from this extract alone whether the source API is expected to populate these
  fields for this endpoint, or whether they are legitimately out of scope for a measurements
  export. This should be confirmed with whoever owns the OpenAQ extraction job.
- `flagInfo.hasFlags` is always `False`. This is plausibly correct (no records were flagged
  upstream) rather than a defect, and is not scored as a quality failure.
