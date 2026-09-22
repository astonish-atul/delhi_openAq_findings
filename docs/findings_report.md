# Findings Report — Data-Quality Assessment: OpenAQ New Delhi Measurements

**Extract:** openaq_new_delhi_measurements.xls | **Rows:** 18,000

## Executive summary

- The extract silently blends two different monitoring deployments — sensors from **Feb 2016**
  and sensors from **Feb–Mar 2025** — with no field in the data to tell them apart. This is the
  single largest driver of the quality issues found below and should be resolved before any
  trend or aggregate analysis is run.
- The **NOx (nitrogen oxides) sensor stream is very likely mis-scaled**: 99.7% of matched
  readings show NOx lower than NO alone, which is chemically impossible (NOx = NO + NO2).
- **Real data completeness is materially worse than the source's own metadata claims.** The
  `coverage.percentComplete`/`percentCoverage` fields report 100% for all 18,000 rows, while
  independent reconstruction of the expected 15-minute cadence shows **42.1% of expected
  reading slots are missing** overall (55.1% for the 2016 station, 20.7% for the 2025 station).
- Three pollutant parameters (co, no2, so2) carry **two different units** (ppb and µg/m³) across
  the merged extract, at risk of being silently averaged together incorrectly.
- **Recommended immediate action:** add a `station_id`/`location` field to the export, quarantine
  or clearly flag the NOx stream pending calibration review, and stop trusting the `coverage`
  metadata field as a completeness signal — measure it independently instead.

## Dataset scope

- **Period analyzed:** two disjoint windows — Feb 5–24, 2016 and Feb 18–Mar 6, 2025
- **Rows:** 18,000 | **Sensors:** 18 (1,000 rows each) | **Parameters:** 12
- **Grain:** one row = one sensor's reading for one 15-minute interval
- **Sources:** single flat-file OpenAQ export, no explicit station identifier
- **Limitations:** no external ground truth available to confirm the two-deployment hypothesis; see `docs/assumptions.md`

## Quality results

| Dimension | Evaluated | Failed | Failure rate | Severity |
|---|---:|---:|---:|---|
| Completeness | 54,000 | 18,000 | 33.3% | Critical/Medium (mixed — see below) |
| Uniqueness | 18,000 | 0 | 0.0% | — (pass) |
| Validity | 36,000 | 6,000 | 16.7% | High |
| Consistency | 18,972 | 969 | 5.1% | Critical |
| Timeliness | 24,873 | 10,478 | 42.1% | High |

*Completeness blends two very different rules: DQ001/DQ002 (value and key fields not null)
**pass at 100%** — every reading that exists is usable. DQ003 (coordinates/summary always null)
fails at 100% and is the sole driver of the 33.3% blended rate; it is scored medium severity
pending confirmation (see Finding 4).*

## Major findings

### Finding 1 — Two monitoring deployments merged without a distinguishing field
- **Finding:** Sensor IDs 35, 36, 392, 393, 394, 399 report data exclusively from Feb 5–24, 2016.
  Sensor IDs 12234782–12234790 and 14340713–14340715 report exclusively from Feb 18–Mar 6, 2025.
  No `station_id` or `location` field exists to confirm whether these are the same station
  (reassigned sensor IDs) or two different stations.
- **Evidence:** Sensor-level profiling (`sql/01_profile/category_profile.sql`) shows a complete,
  non-overlapping split by both sensor-ID range and date range.
- **Trend:** Not applicable — a structural split, not a trend.
- **Affected population:** All 18,000 rows carry this ambiguity; it directly drives Findings 2 and 3 below.
- **Likely cause:** Most consistent with a station relocation, hardware refresh, or an OpenAQ
  `location_id` change between 2016 and 2025 that was not carried into this export.
- **Business impact:** Any trend, year-over-year, or aggregate analysis that treats this extract
  as one continuous series will silently compare two different sensor deployments — and 2016
  pollutant levels (e.g., pm25 up to 637 µg/m³) are far higher than 2025 levels (pm25 up to
  204 µg/m³), which could be misread as "improvement" when it may equally reflect different
  instrumentation, siting, or calibration.

### Finding 2 — NOx stream is very likely mis-scaled (chemically implausible)
- **Finding:** By definition, NOx = NO + NO2, so NOx must always be ≥ NO alone. In this extract,
  969 of 972 matched timestamps (99.7%) show NOx **below** NO alone — on average by roughly
  three orders of magnitude (mean NOx = 0.040 ppb vs. mean NO+NO2 = 62.5 ppb).
- **Evidence:** `sql/02_quality_checks/consistency.sql` (DQ007), joined on matching timestamps
  for the `no`, `no2`, and `nox` parameters (2025 station only — the 2016 station has no NOx sensor).
- **Trend:** Consistent across the full observed window for sensor 14340713; not a one-off spike.
- **Affected population:** All 972 matched NOx readings from sensor 14340713 (current/2025 station).
- **Likely cause:** The magnitude and instability of the gap (ratio of expected-to-observed
  ranges from ~1,268× to ~1,900×, not a clean fixed factor like 1,000×) point to a **sensor
  calibration or unit-labeling defect** in the NOx channel specifically, rather than a simple
  decimal-place error elsewhere in the pipeline. This is reported as a **likely contributing
  factor**, not a confirmed root cause — the export alone cannot show which pipeline stage
  introduced it.
- **Business impact:** Any report using this NOx stream (e.g., NOx-based air-quality indices)
  would materially understate nitrogen oxide levels.

### Finding 3 — Source's own completeness metadata cannot be trusted
- **Finding:** Every one of the 18,000 rows carries `coverage.percentComplete = 100.0` and
  `percentCoverage = 100.0` — a single constant value with zero variation. Independently
  reconstructing the expected 15-minute cadence from each sensor's own min/max timestamp shows
  **10,478 of 24,873 expected slots (42.1%) are actually missing.**
- **Evidence:** `sql/02_quality_checks/timeliness.sql` (DQ009, DQ010).
- **Trend:** Gaps are present throughout both monitoring windows, not concentrated at start/end
  (see `outputs/kpi_trend_missing_slots_daily.csv`), and the legacy 2016 station is markedly
  worse: **55.1%** of expected slots missing vs. **20.7%** for the 2025 station.
- **Affected population:** All 18 sensors; more severe for the 6 legacy-station sensors.
- **Likely cause:** The `coverage` block appears to describe completeness *within the single
  15-minute interval each row represents* (1 of 1 expected sub-readings), not completeness of
  the overall time series — a metadata field that is technically accurate for its own narrow
  definition but misleading if used as a series-level completeness signal.
- **Business impact:** A consumer who trusts the `coverage` field at face value would believe
  this dataset has zero gaps, when in fact more than two in five expected readings are absent —
  materially affecting any trend or hourly/daily aggregation.

### Finding 4 — Structural completeness gap: coordinates and summary always null
- **Finding:** `coordinates` and `summary` are NULL for all 18,000 rows — not a partial gap, a
  complete absence.
- **Evidence:** `sql/01_profile/null_profile.sql`; confirmed against raw TSV cells (not a parsing
  artifact).
- **Affected population:** 100% of rows.
- **Likely cause:** Undetermined from this extract — could be an export-configuration choice
  (these fields deliberately excluded) or a genuine upstream gap. Reported as **root cause could
  not be established from available data.**
- **Business impact:** Without `coordinates`, this dataset cannot be mapped or geographically
  validated without an external join to station metadata.

### Finding 5 — Three parameters carry two different units
- **Finding:** `co`, `no2`, and `so2` each appear under both `ppb` (2025 station) and `µg/m³`
  (2016 station) — 6,000 of 18,000 rows (33.3%) belong to a parameter with more than one unit
  in this extract.
- **Evidence:** `sql/02_quality_checks/validity.sql` (DQ006).
- **Likely cause:** Direct consequence of Finding 1 — the two station deployments report in
  different units for the same parameters, and nothing in the schema flags this.
- **Business impact:** Averaging or summing `co`/`no2`/`so2` across the full extract without
  first converting units would produce a meaningless blended figure differing by 2–3 orders of
  magnitude between the two unit systems.

## Root-cause analysis

**Confirmed by evidence in this extract:**
- Two disjoint sensor-ID/date-range populations exist in one file (Finding 1)
- NOx is chemically inconsistent with NO/NO2 in the same file (Finding 2)
- The `coverage` metadata field is constant despite real, independently measurable gaps (Finding 3)
- Three parameters carry two units within the same file (Finding 5)

**Likely contributing factors (not fully provable from this extract alone):**
- The two-deployment split most likely reflects a station relocation or `location_id` change
  between 2016 and 2025 that a downstream export process did not distinguish
- The NOx defect is most consistent with a sensor calibration or firmware/unit-labeling issue
  specific to that channel

**Unknowns:**
- Whether `coordinates`/`summary` are expected to populate for this export type at all
- The exact pipeline stage responsible for the NOx scaling defect

## Recommendations

| # | Recommendation | Evidence | Expected effect | Owner | Priority |
|---|---|---|---|---|---|
| 1 | Add a `station_id`/`location` field to the export and confirm with OpenAQ/source-system owner whether the 2016 and 2025 sensor sets represent the same physical station | Finding 1 | Prevents silent mixing of two deployments in any future trend analysis | Data engineering / pipeline owner | Critical |
| 2 | Quarantine the NOx stream (sensor 14340713) from reporting until sensor calibration/unit labeling is reviewed by the instrumentation owner | Finding 2 | Stops downstream reports from materially understating NOx | Sensor/instrumentation owner | Critical |
| 3 | Stop using `coverage.percentComplete`/`percentCoverage` as a completeness signal; replace with an independent 15-minute cadence check per sensor, alerting when gap rate exceeds a documented SLA (provisional: 10%, pending owner confirmation) | Finding 3 | Restores a trustworthy completeness signal for monitoring | Data/analytics team | High |
| 4 | Investigate the root cause of the legacy-2016 station's markedly higher gap rate (55.1% vs. 20.7%) before using that window for any completeness benchmark | Finding 3 | Clarifies whether 2016 data should be reweighted or excluded from completeness SLAs | Data engineering | High |
| 5 | Confirm with the export/source owner whether `coordinates` and `summary` are expected to populate for this endpoint; if yes, fix the export; if no, remove the columns to avoid confusion | Finding 4 | Removes a misleading always-null field from the schema | Data engineering / source owner | Medium |
| 6 | Add a unit-normalization step (convert `co`/`no2`/`so2` to one canonical unit) before any cross-deployment aggregation | Finding 5 | Prevents silently meaningless blended averages | Data/analytics team | High |

## Limitations

See `docs/assumptions.md` for full detail. In summary: the two-deployment hypothesis, the NOx
root cause, and the coordinates/summary gap are all reported at the confidence level the
evidence supports (confirmed defect vs. likely contributing factor vs. unresolved unknown) and
should be validated with the relevant source/pipeline owners before remediation is implemented.
