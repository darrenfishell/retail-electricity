# 🔌 Retail Electricity Data Pipeline and Analysis

> A reproducible data engineering and analysis pipeline built with Python, dlt, dbt, DuckDB, Tableau and Observable Plot.

## 📦 Project Overview

This project includes a robust data pipeline that:
- Parses state and federal electricity data for loading into DuckDB
- Performs transformations using [dbt](https://www.getdbt.com/)
- Outputs clean datasets ready for analysis
- Generates summary reports and visualizations

The resulting analysis shows that retail electricity suppliers cost Maine customers **$180.5 million** more than the standard offer from 2012-2023.

I conducted the original analysis of this data for the [Bangor Daily News](https://www.bangordailynews.com/2016/08/31/business/business-energy/maine-competitive-electricity-providers-variable-rates/) in 2016. This project codifies the data extraction and transformations involved. 

The provided Tableau workbook file includes a connection to DuckDB, which benefits from installing the [DuckDB connector](https://duckdb.org/docs/stable/guides/data_viewers/tableau.html#installing-the-tableau-duckdb-connector). The database can be reached with the default PostgreSQL JDBC driver, but the custom connector is more compatible.

---

## 🛠️ Tools

- **Python** – data processing, orchestration
- **Conda** – environment management
- **DuckDB** – fast analytical SQL engine
- **dbt** – SQL transformations and data modeling
- **Pandas** – data wrangling
- **Makefile** – reproducible commands

---

## 📁 Project Structure

```
.
├── data/                     # Database
├── dlt_pipeline/             # Parsing for specific state and federal sources
│   ├── __init__.py
│   └── file_transformations.py
├── models/                   # dbt models (SQL files)
├── environment.yml           # Conda environment definition
├── run_pipeline.py           # Main pipeline runner
├── Makefile                  # Reproducible workflow commands
└── README.md
```

---

## ⚙️ Setup Instructions

### 1. Clone the repo

```
git clone https://github.com/darrenfishell/retail-electricity.git
cd retail-electricity
```

### 2. Run the pipeline

```
make
```

The default pipeline will create the conda environment and run the pipeline, creating the DuckDB database and transformed tables and views for analysis.

### Manual options

For running specific steps or cleaning up the environment, refer to: 

```
make help
```

---

## 📜 License

MIT License. See `LICENSE` file for details.
