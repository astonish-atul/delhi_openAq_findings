# OpenAQ New Delhi Measurements — Data-Quality Project

This package follows the process defined in `process.md` end-to-end: profiling → SQL
quality rules → exception dataset → KPI/reporting layer → root-cause analysis → two
final deliverables (findings report, slide deck).

## Final deliverables (what you asked for)
- `outputs/Data_Quality_Findings_Report.docx` — the findings report
- `outputs/Data_Quality_Findings_Deck.pptx` — the slide deck

## Supporting work (the "why" behind the deliverables)
- `docs/problem_statement.md` — objective, users, decisions enabled, scope
- `docs/data_dictionary.md` — grain, fields, derived fields, why nulls were/weren't flagged
- `docs/assumptions.md` — assumptions, provisional thresholds, and limitations
- `docs/qa_checklist.md` — reconciliation and QA checks performed on the analysis itself
- `docs/findings_report.md` — markdown source of the findings report
- `config/quality_rules.csv` — the 11-rule registry (DQ001–DQ011) with dimension, severity, threshold basis
- `sql/01_profile/` — row counts, null profile, category/parameter profile
- `sql/02_quality_checks/` — completeness, uniqueness, validity, consistency, timeliness SQL (DuckDB dialect)
- `data/raw/` — the original extract plus the parsed/flattened working table
- `outputs/quality_results.csv` — standardized rule-by-rule pass/fail results
- `outputs/exception_records.csv` — every failing row/slot, traceable to its rule
- `outputs/summary_metrics.csv`, `kpi_by_dimension.csv`, `kpi_by_source.csv`, `kpi_trend_missing_slots_daily.csv` — KPI layer
- `outputs/chart_*.png` — charts embedded in the report; `outputs/slide_*.png` — charts embedded in the deck

## Headline findings
1. Two monitoring deployments (2016 legacy station, 2025 current station) are merged in
   one file with no station/location field to distinguish them.
2. The NOx sensor stream is very likely mis-scaled (99.7% of readings are chemically
   implausible against NO + NO2).
3. The source's own completeness metadata claims 100% coverage on every row while real
   gaps run as high as 55% for the legacy station.
4. `coordinates`/`summary` are null for 100% of rows.
5. Three parameters (co, no2, so2) carry two different units across the merged extract.

See the findings report or deck for full detail, evidence, and prioritized recommendations.
