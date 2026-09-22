# Assumptions & Limitations

## Assumptions
1. **Grain** is one sensor's reading per declared 15-minute interval. Verified: `dt_to_utc − dt_from_utc = 15 minutes` for all 18,000 rows (DQ008 passes 100%).
2. **Two station deployments, inferred not confirmed.** Sensor IDs 35, 36, 392, 393, 394, 399 report Feb 5–24, 2016; sensor IDs 12234782–12234790 and 14340713–14340715 report Feb 18–Mar 6, 2025. No `station_id`/`location` field exists in the raw extract to confirm these are two physically distinct deployments rather than one station whose sensor IDs were reassigned; this is the most likely explanation given OpenAQ's ID-per-sensor model, and is labeled `station_group` throughout this analysis as an **inferred, not confirmed,** attribute.
3. **Timeliness proxy.** Because this is a static historical extract (not a live feed), a "freshness vs. now" check is not meaningful. Timeliness is instead measured as observed-vs-expected 15-minute slot coverage within each sensor's own min/max window — a practical proxy for pipeline completeness given the available data.
4. **Provisional thresholds.** No documented SLA, data contract, or historical baseline was available outside this extract. The following thresholds are therefore **provisional analytical thresholds** pending confirmation by the data/source owner:
   - IQR outlier fence (Q1 − 3×IQR, Q3 + 3×IQR) per parameter+unit for anomaly flags
   - 10% gap-rate reference ceiling used only to describe severity in prose, not as a hard pass/fail cutoff

## Limitations
- No independent ground truth (e.g., an official OpenAQ API pull for the same window) was available to confirm whether the 2016/2025 split is two stations, a station relocation, or a backfill artifact — this is flagged as a "likely contributing factor," not a confirmed root cause.
- The NOx unit/scale defect (Finding 2) could not be tied to a specific pipeline stage (sensor firmware, ingestion transform, or export step) from this extract alone; only the ppb vs. expected-magnitude mismatch could be established.
- `coordinates` and `summary` being 100% null could reflect either a genuine upstream defect or a field that this endpoint is not expected to populate — not resolvable from the data alone.
- Severity for DQ011 (statistical anomalies) uses this extract as its own baseline (no external historical series was available), so seasonal/legitimate pollution spikes may be indistinguishable from true anomalies without a longer baseline.

