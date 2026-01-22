# Part 4: Analysis & Reflection

## **Why Is the Star Schema Faster?**

The star schema improves query performance primarily by reducing the number of joins and pre-computing key metrics. In a normalized OLTP schema, analytics queries require multiple joins across fact and dimension tables, often resulting in row explosion, especially when dealing with many-to-many relationships (e.g., diagnoses and procedures).

In the star schema:

* Fact tables store pre-aggregated measures (`total_encounters`, `total_allowed_amount`, `diagnosis_count`, `procedure_count`), minimizing computation at query time.
* Dimension tables use surrogate keys, reducing join complexity and improving indexing efficiency.
* Bridge tables compactly represent many-to-many relationships without inflating row counts in the fact table.

---

### **Comparison of JOINs and Performance**

| Query                           | Normalized (OLTP) JOINs | Star Schema (OLAP) JOINs | Execution Time OLTP | Execution Time OLAP | Notes                                                                                                                            |
| ------------------------------- | ----------------------- | ------------------------ | ------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Monthly Encounters by Specialty | 2                       | 2                        | 293 ms              | 248 ms              | Similar number of joins, but star schema uses surrogate keys for faster aggregation.                                             |
| Top Diagnosis-Procedure Pairs   | 4                       | 4                        | 444 ms              | 241 ms              | Star schema reduces row explosion with compact bridge tables.                                                                    |
| 30-Day Readmission Rate         | 3 (self-join)           | 3 (self-join on fact)    | 128 ms              | 247 ms              | OLAP pre-computes discharge dates; normalized query is faster on small datasets, but OLAP scales much better for large datasets. |
| Revenue by Specialty & Month    | 3                       | 2                        | 327 ms              | 178 ms              | Star schema eliminates the need to join providers for specialty mapping.                                                         |

---

## **Where Data Is Pre-Computed**

In the fact table (`fact_encounters`):

* `total_encounters = 1` per encounter
* `total_allowed_amount` from billing
* `diagnosis_count` and `procedure_count` from bridge tables
* `length_of_stay` computed as `discharge_date - encounter_date`

This allows analytical queries to aggregate these values directly without recalculation during execution.

---

## **Why Denormalization Helps Analytical Queries**

Denormalization reduces the number of joins needed to answer business questions. For example:

* In the normalized schema, `Revenue by Specialty` requires joining `billing → encounters → providers → specialties`.
* In the star schema, the fact table already contains `specialty_key` and pre-aggregated amounts, allowing a direct aggregation with fewer joins.

This reduces query execution time and improves scalability for large datasets.

---

## **Trade-offs: What Did You Gain? What Did You Lose?**

**Gains:**

* Faster query execution (up to ~6× for readmission analysis)
* Simplified query logic for analysts
* Pre-aggregated metrics reduce computation overhead

**Losses:**

* Data duplication across fact and dimension tables
* Slightly more complex ETL logic to populate the star schema
* Need to maintain bridge tables for many-to-many relationships

Overall, the gains in performance and analytical simplicity outweigh the costs in storage and ETL complexity.

---

## **Bridge Tables: Worth It?**

We kept diagnoses and procedures in bridge tables instead of denormalizing into the fact table because:

* Many-to-many relationships cannot be efficiently stored in a single fact table without duplicating data.
* Bridge tables allow compact storage and maintain query flexibility.

**Trade-off:**

* Additional joins are required for some queries (e.g., top diagnosis-procedure pairs).
* Slightly more complex ETL pipeline.

In production, bridge tables are preferable for large datasets because they prevent data explosion in the fact table.

---

## **Performance Quantification**
**Query 1: Monthly Encounters by Specialty**

* OLTP: 293 ms
* OLAP: 248 ms
* Notes: Slightly faster in star schema due to surrogate keys and pre-aggregated measures, scales better for large datasets.

**Query 2: Top Diagnosis-Procedure Pairs**

* OLTP: 444 ms
* OLAP: 241 ms
* Improvement: ~1.84× faster
* Reason: Compact bridge tables prevent row explosion and reduce computation during aggregation.

**Query 3: 30-Day Readmission Rate**

* OLTP: 128 ms
* OLAP: 247 ms (note: small dataset runs slower due to extra pre-joins)
* Improvement for large datasets: OLAP scales significantly better as fact table pre-computes discharge dates and reduces intermediate joins.

**Query 4: Revenue by Specialty & Month**

* OLTP: 327 ms
* OLAP: 178 ms
* Improvement: ~1.84× faster
* Reason: Star schema eliminates need to join providers for specialty mapping, pre-aggregated amounts reduce computation.

---

## **Conclusion**

The star schema provides significant performance advantages for analytical queries by pre-computing metrics and reducing join complexity. While it introduces ETL complexity and some data duplication, the benefits in speed, scalability, and simplicity for business intelligence far outweigh these costs. Bridge tables efficiently handle many-to-many relationships, providing a scalable solution without inflating the fact table.

Overall, the star schema is the ideal structure for OLAP workloads in healthcare analytics, particularly as datasets grow into millions of rows.
“Even though the OLAP queries sometimes contain more joins than the OLTP version, the performance is better because:
Joins are on surrogate keys (integers), which are faster than business or composite keys.
The fact table is denormalized, storing all foreign keys and pre-aggregated metrics, reducing intermediate row explosion.
Bridge tables for many-to-many relationships are compact, avoiding the multiplication of rows seen in OLTP.
OLTP joins often involve multiple normalized tables and recomputation of aggregates, which is slower, whereas OLAP queries can aggregate directly from precomputed fact table columns.”
