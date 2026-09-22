# Problem Statement — DA-01: Data-Quality Monitoring for OpenAQ New Delhi Measurements

**Problem**
Data consumers do not have a reliable way to detect and quantify data-quality failures
in the `openaq_new_delhi_measurements` extract before it is used for air-quality reporting
or analysis.

**Objective**
Build a repeatable quality-monitoring workflow that detects major data-quality issues,
quantifies their frequency and business impact, identifies likely root causes, and
provides a scorecard for ongoing monitoring.

**Primary users**
- Data/analytics team consuming this extract for air-quality reporting
- Operations/environmental stakeholders relying on pollutant trend accuracy
- Data engineering stakeholders responsible for the OpenAQ ingestion pipeline

**Decisions enabled**
- Is this dataset reliable enough for downstream air-quality reporting as-is?
- Which quality failures require attention before the data is trusted?
- Which sensor/source/field contributes most to failures?
- Can the two apparent monitoring periods be safely combined, or must they be segmented?

**In scope**
- Completeness, uniqueness, validity, consistency, timeliness, anomaly detection
- Root-cause investigation using only evidence available in this extract

**Out of scope**
- Rebuilding the OpenAQ ingestion pipeline
- Production incident response
- Machine-learning-based anomaly detection
- Changing source-system (OpenAQ / sensor vendor) logic

**Data source**
`openaq_new_delhi_measurements.xls` (tab-separated OpenAQ sensor-measurement export),
18,000 rows, provided by the user for this project.
