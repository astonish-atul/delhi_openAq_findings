# QA & Reconciliation Checklist

| Check | Result | Status |
|---|---|---|
| Row-count reconciliation: source rows = rows evaluated by row-scoped rules (DQ001–DQ006, DQ008) | 18,000 = 18,000 | ✅ Pass |
| Distinct-key reconciliation: `sensor_id` count in source = distinct sensors in profiling output | 18 = 18 | ✅ Pass |
| Aggregate reconciliation: exception file row-level failure counts = quality_results failed_count | DQ006 6,000 = 6,000; DQ007 969 = 969; DQ009 10,478 = 10,478 | ✅ Pass |
| Duplicate testing: no join used to build `quality_results` multiplies rows | Verified via `COUNT(DISTINCT sensor_id, dt_from_utc)` = 18,000 (no duplicates) | ✅ Pass |
| Filter testing — single sensor | Filtering to `sensor_id = 393` returns exactly 1,000 rows, consistent with per-sensor profile | ✅ Pass |
| Filter testing — single date | Filtering to `event_date = 2025-02-19` returns a non-zero, bounded row count consistent with 96 slots/day × 12 sensors | ✅ Pass |
| Filter testing — empty result | Filtering to a non-existent `sensor_id` returns 0 rows without error | ✅ Pass |
| Null testing | `coordinates`/`summary` confirmed NULL for all 18,000 rows (not a parsing artifact) — cross-checked directly against raw TSV cells | ✅ Confirmed intentional |
| Boundary testing | Min/max `value` per parameter checked against physical bounds (no negative concentrations, RH ∈ [0,100], wind_direction ∈ [0,360)) | ✅ Pass — DQ005 = 0% failure |
| Refresh testing | N/A — static historical extract, not a live/refreshing feed. Documented in `assumptions.md`. | ⚠️ Not applicable |
| Join validation | `no`/`no2`/`nox` join on `dt_from_utc_ts` checked for fan-out: 1,000 `no` rows × 1,000 `nox` rows joined on exact timestamp match, yielding ≤1,000 matched rows (972 observed, no multiplication) | ✅ Pass |

**Conclusion:** all `quality_results` and `exception_records` numbers reconcile to the SQL queries in `sql/02_quality_checks/` and `sql/03_exceptions/`. Refresh testing is not applicable to this one time historical extract.
