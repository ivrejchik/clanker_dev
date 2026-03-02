# Add DAG

Build a new Airflow DAG from a brief idea, `.py` file, or `.md` spec.

## What it does

1. Parses your input (idea, file path, or spec)
2. Creates a feature branch
3. Launches 6 parallel research agents (all Opus) to analyze:
   - Project state and existing DAGs
   - Reusable ETL functions
   - DAG structure patterns
   - Potential pitfalls
   - Web research for best practices
   - Test design
4. Implements the DAG following existing project patterns
5. Creates tests
6. Reviews and presents a summary

## Usage

```
/add-dag [idea or file path]
```

## Examples

```
/add-dag daily pipeline to sync customer data from Azure SQL to Postgres
/add-dag ./specs/new_pipeline.md
/add-dag monitoring dag for data freshness checks
```
