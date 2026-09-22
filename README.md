# OpenAQ New Delhi Measurements — Data-Quality Project
## Check the attached report and deck for more detailed info
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
