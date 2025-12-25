
#  Healthcare Analytics Lab: OLTP vs OLAP Performance Comparison

##  Project Overview

This project demonstrates the **performance differences between OLTP (Online Transaction Processing)** and **OLAP (Online Analytical Processing)** systems using a **Healthcare Analytics use case**.

The core objective is to:

1. **Design and implement a normalized OLTP database**
2. **Run analytical queries and measure performance**
3. **Transform the OLTP schema into an OLAP Star Schema**
4. **Run equivalent analytical queries on the OLAP system**
5. **Compare query execution times and scalability**
6. **Explain why OLAP systems outperform OLTP systems for analytics**

This mirrors real-world data engineering workflows used in healthcare reporting, business intelligence, and data warehousing.

---

##  Problem Statement

Healthcare systems generate large volumes of transactional data (patients, encounters, diagnoses, procedures, billing).
While **OLTP databases** are optimized for inserts and updates, they **perform poorly for analytical workloads** involving joins, aggregations, and historical analysis.

This project empirically proves why **OLAP star schemas** are better suited for analytics.

---

##  Architecture Overview

### Phase 1: OLTP System

* Fully normalized schema (3NF)
* Optimized for transactional integrity
* Multiple joins required for analytics

### Phase 2: OLAP System

* Star schema with fact and dimension tables
* Pre-aggregated metrics
* Surrogate keys
* Optimized for analytical queries

---

##  Project Structure

```
Healthcare-Analytics-Lab-OLTP-to-Star-Schema/
│
├── data/
│   ├── oltp/                # CSV exports from OLTP tables
│   └── olap/                # CSVs for dimensions, facts, bridge tables
│
├── deliverables/
│   ├── design_decisions.txt
│   ├── etl_design.txt
│   ├── query_analysis.txt
│   ├── star_schema_queries.txt
│   ├── star_schema.sql
│   └── reflection.md
│
├── logs/                     # ETL and execution logs
│
├── OLTP/
│   ├── schema.sql
│   ├── constraints.sql
│   └── insert_data.sql
│
├── OLAP/
│   ├── schema.sql
│   ├── constraints.sql
│   └── insert_data.sql
│
├── performance_analysis/
│   ├── oltp/
│   │   ├── 01_monthly_encounters.sql
│   │   ├── 02_diagnosis_procedure_pairs.sql
│   │   ├── 03_30day_readmissions.sql
│   │   └── 04_revenue_by_specialty.sql
│   │
│   └── olap/
│       ├── 01_monthly_encounters.sql
│       ├── 02_diagnosis_procedure_pairs.sql
│       ├── 03_30day_readmissions.sql
│       └── 04_revenue_by_specialty.sql
│
├── src/
│   ├── config/
│   ├── data_generation/      # Faker-based dummy data generation
│   ├── connection.py
│   ├── main.py
│
├── .env
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Data Generation

* Dummy healthcare data generated using **Python + Faker**
* Tables populated:

  * Patients
  * Providers
  * Departments
  * Encounters
  * Diagnoses
  * Procedures
  * Billing
* Data exported to CSV
* CSVs used as input for ETL pipeline

---

##  OLTP Schema (Normalized)

### Key Characteristics

* Fully normalized tables
* Referential integrity enforced
* Optimized for transactions

### Core Tables

* `patients`
* `providers`
* `departments`
* `specialties`
* `encounters`
* `diagnoses`
* `procedures`
* `billing`
* Junction tables:

  * `encounter_diagnoses`
  * `encounter_procedures`

This schema requires **multiple joins** for analytical queries.

---

##  OLAP Star Schema Design

### Fact Table

**`fact_encounters`**

* encounter_count
* total_allowed_amount
* total_claim_amount
* diagnosis_count
* procedure_count
* length_of_stay

### Dimension Tables

* `dim_date`
* `dim_patient`
* `dim_specialty`
* `dim_department`
* `dim_encounter_type`
* `dim_diagnosis`
* `dim_procedure`

### Bridge Tables

* `bridge_encounter_diagnoses`
* `bridge_encounter_procedures`

> Bridge tables preserve many-to-many relationships without exploding fact table rows.

---

## ETL Pipeline

Implemented in Python using **Pandas**.

### ETL Flow

1. **Extract**

   * Read OLTP CSVs
2. **Transform**

   * Generate surrogate keys
   * Create age groups
   * Compute length of stay
   * Aggregate billing and encounter metrics
3. **Load**

   * Load dimensions first
   * Load fact table
   * Load bridge tables

Detailed design available in:
`deliverables/etl_design.txt`

---

## Performance Queries

The **same analytical questions** were asked on both schemas:

1. Monthly Encounters by Specialty
2. Top Diagnosis–Procedure Pairs
3. 30-Day Readmission Rate
4. Revenue by Specialty & Month

---

## Performance Results Summary

| Query                     | OLTP Time | OLAP Time | Improvement                       |
| ------------------------- | --------- | --------- | --------------------------------- |
| Monthly Encounters        | 102 ms    | 146 ms    | OLTP slightly faster (small data) |
| Diagnosis–Procedure Pairs | 462 ms    | 150 ms    | ~3× faster                        |
| 30-Day Readmission        | 109 ms    | 17 ms     | **~6.4× faster**                  |
| Revenue by Specialty      | 220 ms    | 114 ms    | ~1.9× faster                      |

---

## Key Findings

### Why OLAP Performs Better

* Pre-aggregated metrics
* Fewer joins
* Surrogate key joins
* Reduced row explosion
* Optimized for GROUP BY operations

### When OLTP Appears Faster

* Small datasets
* Simple aggregations
* Low join complexity

**However**, OLAP **scales significantly better** as data grows into millions of rows.

---

## ⚖️ Trade-offs

### Gains

* Faster analytical queries
* Cleaner query logic
* Scalable reporting

###  Costs

* Data duplication
* More complex ETL
* Additional storage

---

## Deliverables

All required documentation is located in the `deliverables/` folder:

* Design decisions
* ETL architecture
* Query analysis
* Performance comparison
* Reflection and conclusions

---

## Conclusion

This project demonstrates that:

* **OLTP databases are not designed for analytics**
* **Star schemas dramatically improve analytical performance**
* **ETL complexity is a worthwhile trade-off**
* **OLAP is the correct choice for healthcare reporting and BI**

This mirrors real-world data warehouse design patterns used in hospitals, insurance companies, and analytics platforms.

---

## 🛠️ Technologies Used

* Python
* Pandas
* Faker
* MySQL
* SQL
* Star Schema Modeling
* ETL Design
* Performance Benchmarking

---

## Author

**Jeremiah Anku Cobblah**
Healthcare Analytics & Data Engineering Lab
