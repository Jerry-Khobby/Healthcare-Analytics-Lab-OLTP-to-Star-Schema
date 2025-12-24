# Part 4: Analysis & Reflection

## **Why Is the Star Schema Faster?**

The star schema improves query performance primarily by reducing the number of joins and pre-computing key metrics. In a normalized OLTP schema, analytics queries require multiple joins across fact and dimension tables, often resulting in row explosion, especially when dealing with many-to-many relationships (e.g., diagnoses and procedures).

In the star schema:

* Fact tables store pre-aggregated measures (`encounter_count`, `total_allowed_amount`, `diagnosis_count`, `procedure_count`), minimizing computation at query time.
* Dimension tables use surrogate keys, reducing join complexity and improving indexing efficiency.
* Bridge tables compactly represent many-to-many relationships without inflating row counts in the fact table.

### **Comparison of JOINs**

| Query                           | Normalized JOINs | Star Schema JOINs     | Notes                                                                         |
| ------------------------------- | ---------------- | --------------------- | ----------------------------------------------------------------------------- |
| Monthly Encounters by Specialty | 2-3              | 3                     | Similar number of joins, but joins are on surrogate keys, making them faster. |
| Top Diagnosis-Procedure Pairs   | 4+               | 4                     | Star schema avoids row explosion by joining compact bridge tables.            |
| 30-Day Readmission Rate         | 3 (self-join)    | 4 (self-join on fact) | Pre-computed discharge dates in fact table reduce intermediate computations.  |
| Revenue by Specialty & Month    | 3                | 2                     | Star schema removes the need to join providers table for specialty mapping.   |

---

## **Where Data Is Pre-Computed**

In the fact table (`fact_encounters`):

* `encounter_count = 1`
* `total_allowed_amount` and `total_claim_amount` from billing
* `diagnosis_count` and `procedure_count` from bridge tables
* `length_of_stay` computed as `discharge_date - encounter_date`

This allows analytical queries to directly aggregate these values without recomputing during query execution.

---

## **Why Denormalization Helps Analytical Queries**

Denormalization reduces the number of joins needed to answer business questions. For example:

* In the normalized schema, `Revenue by Specialty` requires joining `billing → encounters → providers → specialties`.
* In the star schema, the fact table already contains `specialty_key` and pre-aggregated amounts, allowing a direct aggregation with fewer joins.

This reduces query execution time and improves scalability for large datasets.

---

## **Trade-offs: What Did You Gain? What Did You Lose?**

**Gains:**

* Faster query execution (up to ~6x for readmission analysis)
* Simplified query logic for business analysts
* Pre-aggregated metrics reduce computation overhead

**Losses:**

* Data duplication across fact and dimension tables
* Slightly more complex ETL logic for populating the star schema
* Need to maintain bridge tables for many-to-many relationships

Overall, the gains in performance and analytical simplicity outweigh the costs in storage and ETL complexity.

---

## **Bridge Tables: Worth It?**

We kept diagnoses and procedures in bridge tables instead of denormalizing into the fact table because:

* Many-to-many relationships cannot be efficiently stored in a single fact table without duplicating data.
* Bridge tables allow compact storage and maintain query flexibility.

**Trade-off:**

* Additional joins required for some queries (e.g., top diagnosis-procedure pairs)
* Slightly more complex ETL pipeline

In production, bridge tables are preferable to denormalizing, especially for large datasets, as they prevent data explosion in the fact table.


## **Performance Quantification**

**Query 1: Monthly Encounters by Specialty**

* Normalized: 102 ms
* Star Schema: 146 ms
* Notes: Slightly slower in small datasets due to extra joins in star schema, but scales better for larger datasets because of pre-aggregated metrics and surrogate key joins.

**Query 3: 30-Day Readmission Rate**

* Normalized: 109 ms
* Star Schema: 17 ms
* Improvement: ~6.4× faster
* Reason: Fact table pre-joins discharge dates and patient-specialty keys, reducing the need to join providers and intermediate tables.

**Query 4: Revenue by Specialty & Month**

* Normalized: 220 ms
* Star Schema: 114 ms
* Improvement: ~1.93× faster
* Reason: Pre-aggregated fact table with `specialty_key` eliminates the need to join providers for specialty mapping.

## **Conclusion**

The star schema provides significant performance advantages for analytical queries by pre-computing metrics and reducing join complexity. While it introduces some ETL complexity and data duplication, the benefits in speed and simplicity for business intelligence far outweigh these costs. Bridge tables efficiently handle many-to-many relationships, providing a scalable solution without inflating the fact table.

Overall, the star schema is the ideal structure for OLAP workloads in healthcare analytics, especially when the dataset grows into millions of rows.
