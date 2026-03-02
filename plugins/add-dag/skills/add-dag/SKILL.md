---
name: add-dag
description: Build a new Airflow DAG from a brief idea, .py file, or .md spec. Launches parallel research agents to analyze the codebase, then implements the DAG following existing patterns on a feature branch with tests.
argument-hint: [idea or file path]
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TeamCreate, TeamDelete, SendMessage, WebSearch, WebFetch
---

# Add DAG Skill

You are building a new Airflow DAG for the airflow_prod project. The user provides an idea, a `.py` file, or a `.md` spec via `$ARGUMENTS`.

## Phase 0: Parse Input

1. Check if `$ARGUMENTS` is a file path (ends in `.py`, `.md`, `.txt`). If so, read the file for the DAG specification.
2. Otherwise, treat `$ARGUMENTS` as a plain-text DAG idea.
3. Determine a short DAG name slug (lowercase, underscores, e.g., `new_entity`, `my_pipeline`) from the idea. This becomes `{dag_slug}`.

## Phase 1: Create Feature Branch

```bash
git checkout main && git pull origin main 2>/dev/null; git checkout -b feature/{dag_slug}
```

If `main` doesn't exist or pull fails, just branch from current HEAD.

## Phase 2: Launch Parallel Research Team

Create a team called `dag-builder` and spawn **6 agents in parallel** using the Task tool. All agents MUST use `model: "opus"` for maximum capability. Create tasks for each agent before spawning them.

### Agent 1 — `state-reader` (subagent_type: Explore)
**Task:** Read the current Airflow project state.
- List all existing DAGs in `dags/` with their DAG IDs, schedules, and tags
- Check `dags/processed_data/` for any active run directories
- Read `docker-compose.yaml` to understand the runtime environment (Airflow 3.0.1, CeleryExecutor, PostgreSQL, Redis)
- Read `requirements.txt` for available Python packages
- Read `config/config.prod.yaml` and `config/config.dev.yaml` for vault key mappings
- Check what schedule slots are already taken to avoid collisions
- Report: existing DAG IDs, their schedules, available vault keys, installed packages

### Agent 2 — `etl-scanner` (subagent_type: Explore)
**Task:** Catalog all reusable ETL functions relevant to the new DAG idea: `$ARGUMENTS`
- Read ALL files in `extract/`, `transform/`, `transform/transform_custom/`, `load/`, and `utils/`
- For each function: document the signature, what it does, required parameters, and return value
- Specifically note the XCom contract: every task returns `{"output_file": str, "run_dir": str}`
- Identify which existing functions could be reused for the new DAG
- Check `dicts/` for any relevant JSON dictionary/config files
- Check `queries/` for any relevant SQL templates and read `queries/sql_naming_conventions.md`
- Report: full function catalog with reuse recommendations for this specific DAG

### Agent 3 — `pattern-analyzer` (subagent_type: Explore)
**Task:** Extract the exact DAG structure pattern used in this project.
- Read at least 3 DAG files: `dags/dayg/alex.py`, `dags/dayg/fox.py`, `dags/allerting/ataas_monitor.py`
- Document the EXACT boilerplate including:
  - Imports (datetime, timedelta, DAG, PythonOperator, os, sys, pandas, LoggingMixin)
  - `sys.path.insert(0, "/opt/airflow")`
  - Logger pattern: `get_airflow_logger()` returning `LoggingMixin().log`
  - `default_args` dict (owner, depends_on_past, email_on_failure, email_on_retry, retries=0, retry_delay=2min)
  - DAG context manager with naming convention `ETL_{entity}_dayg`
  - Task function pattern: pull XCom -> read parquet -> transform -> write parquet -> return dict
  - Linear chain dependencies with `>>` operator
  - Cleanup as final task using `cleanup_files` from `utils/cleanup_run_dir`
- Document the Pydantic validation pattern used in transforms
- Report: exact copy-pasteable code template ready for the new DAG

### Agent 4 — `pitfall-checker` (subagent_type: Explore)
**Task:** Identify specific problems and pitfalls for this new DAG idea: `$ARGUMENTS`
- Read the DAG idea and cross-reference with existing code for potential issues
- Check for: SQL injection risks, missing error handling, data type mismatches
- Verify Azure Key Vault secret naming conventions match `config.prod.yaml`
- Check if the target PostgreSQL table/schema needs new vault keys in config YAML
- Look for the parquet intermediate file naming convention and ensure no collisions
- Check if new SQL queries are needed in `queries/` directory
- Verify the proposed schedule doesn't conflict with existing DAGs (existing schedules are: `15 8 * * *`, `45 8 * * *`, `0 9 * * *`, `15 9 * * *`, `0 9 * * 1-5`, `0 8 * * *`, `0 8 * * 6`)
- Check for proper Pydantic validation on any new transforms
- Review `.env` for any environment variables that might be needed
- Report: list of pitfalls with specific remediation steps

### Agent 5 — `web-researcher` (subagent_type: general-purpose)
**Task:** Search the web for relevant information about this new DAG: `$ARGUMENTS`
- Search for best practices related to the DAG's specific data domain
- Search for Airflow 3.0.1 specific patterns or gotchas (the project uses Airflow 3.0.1)
- Search for any relevant Python library usage patterns needed for new transforms
- If the DAG involves a new data source or API, research its documentation
- Search for Pydantic v2 validation patterns (project uses pydantic 2.11.4)
- Report: relevant findings with links and code examples

### Agent 6 — `test-designer` (subagent_type: general-purpose)
**Task:** Design tests for this new DAG: `$ARGUMENTS`
- Read the existing DAG pattern from `dags/dayg/alex.py` as reference
- Read existing Pydantic validation from `transform/remove_test_tenants.py` as reference
- Design unit tests for any new transform functions (using pytest + pandas)
- Design a DAG validation test (DAG loads without errors, correct task count, correct dependencies)
- Design data contract tests (Pydantic model validation)
- Note: the project currently has NO tests (test_*.py is gitignored), so design a proper structure
- Suggest a `tests/` directory with `conftest.py` and organized test files
- Report: complete test plan with actual pytest code ready to paste

## Phase 3: Implement the DAG

After ALL 6 agents complete, synthesize their findings and build the DAG. Follow these rules strictly:

### File Placement
Decide where the DAG belongs based on its type:
- Daily ETL pipeline -> `dags/dayg/{dag_slug}.py`
- Monitoring/alerting -> `dags/allerting/{dag_slug}.py`
- Maintenance/utility -> `dags/custom/{dag_slug}.py`
- Development/experimental -> `dags/dev/{dag_slug}.py`

### Mandatory Code Pattern
Every DAG file MUST follow this exact structure:

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
import os
import sys
import pandas as pd
from airflow.utils.log.logging_mixin import LoggingMixin

airflow_home = "/opt/airflow"
sys.path.insert(0, airflow_home)

# Import reusable functions
from extract.extract_from_raptor import extract_from_raptor
from utils.cleanup_run_dir import cleanup_files as cleanup_files_func
from utils.config_loader import get_vault_key
from utils.get_secret import get_secret
# ... other imports as needed from existing modules

def get_airflow_logger():
    return LoggingMixin().log

logger = get_airflow_logger()

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0,
    "retry_delay": timedelta(minutes=2),
}

# Task functions following XCom contract: always return {"output_file": str, "run_dir": str}
def extract_task(**context):
    query_path = os.path.join(airflow_home, "queries", "{dag_slug}.sql")
    with open(query_path, "r") as f:
        query = f.read()
    return extract_from_raptor(query=query, **context)

def transform_step(**context):
    result = context["ti"].xcom_pull(task_ids="previous_task_id")
    df = pd.read_parquet(result["output_file"])
    transformed_df = some_transform(df)
    output_file = result["output_file"].replace("_old.parquet", "_new.parquet")
    transformed_df.to_parquet(output_file, index=False)
    logger.info(f"Transform complete: {len(transformed_df)} rows")
    return {"output_file": output_file, "run_dir": result["run_dir"]}

def load_task(**context):
    result = context["ti"].xcom_pull(task_ids="last_transform_task_id")
    table_name = get_secret(get_vault_key("{dag_slug}_table"))
    pg_db = get_secret(get_vault_key("postgres_db_schema"))
    from load.load_to_postgres import load_to_postgres
    load_to_postgres(result["output_file"], table_name, pg_db)
    return {"output_file": result["output_file"], "run_dir": result["run_dir"]}

with DAG(
    "ETL_{dag_slug}_dayg",
    default_args=default_args,
    description="ETL pipeline for {description}",
    schedule="CRON_EXPRESSION",  # Avoid conflicts with existing schedules
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["etl", "{dag_slug}"],
) as dag:

    extract = PythonOperator(task_id="extract_data", python_callable=extract_task)
    # ... transform tasks ...
    load = PythonOperator(task_id="load_data", python_callable=load_task)
    cleanup = PythonOperator(task_id="cleanup_files", python_callable=cleanup_files_func)

    extract >> transform_1 >> transform_2 >> load >> cleanup
```

### New Transform Functions
If the DAG needs new transform functions:
- Create them in `transform/` (shared) or `transform/transform_custom/` (DAG-specific)
- Follow the Pydantic validation pattern from existing transforms
- Include `get_airflow_logger()` in each file
- Accept a DataFrame, return a DataFrame

### New SQL Queries
If the DAG needs a new SQL query:
- Create it in `queries/{dag_slug}.sql`
- Follow the naming conventions in `queries/sql_naming_conventions.md`

### Config Updates
If new vault keys are needed:
- Add them to BOTH `config/config.dev.yaml` and `config/config.prod.yaml` under `vault_keys`
- Follow existing naming patterns (dev uses simpler names, prod uses `-PROD-` prefixed names)

### Dictionary Files
If the DAG needs a new allergen dictionary or config:
- Create it in `dicts/{dag_slug}_dict.json`

## Phase 4: Implement Tests

Create a proper test structure:

```
tests/
├── conftest.py                      # Shared fixtures (sample DataFrames, mock secrets)
├── test_{dag_slug}_dag.py           # DAG structure tests
└── test_{dag_slug}_transforms.py    # Transform function tests (if new transforms created)
```

Tests MUST cover:
1. **DAG validation**: DAG loads, correct task count, correct dependencies, no cycles
2. **Transform unit tests**: Each new transform function with sample data
3. **Pydantic validation**: Models reject invalid data correctly
4. **XCom contract**: Each task function returns `{"output_file": str, "run_dir": str}`

IMPORTANT: `test_*.py` is in `.gitignore`. After creating tests, inform the user they should update `.gitignore` to allow test files if they want to commit them.

## Phase 5: Final Review

1. Re-read the implemented DAG file and all new files created
2. Verify all imports resolve to existing or newly created modules
3. Verify the XCom contract `{"output_file": str, "run_dir": str}` is maintained across ALL tasks
4. Verify the schedule doesn't conflict with existing DAGs
5. Verify `cleanup_files` is the final task in the chain
6. Run syntax check: `python -c "import ast; ast.parse(open('path/to/dag.py').read())"`
7. If tests were created, attempt to run them with `pytest tests/ -v`
8. Present the user a summary:
   - Files created/modified (with paths)
   - DAG structure as ASCII diagram showing task flow
   - Chosen schedule and justification
   - Reused existing functions (list)
   - New functions created (list)
   - Manual steps needed (vault keys to create in Azure, docker rebuild, .gitignore update, etc.)

## Hard Rules — NEVER Violate These

- ALWAYS reuse existing functions from `extract/`, `transform/`, `load/`, and `utils/` before writing new ones
- ALWAYS follow the exact boilerplate pattern from existing DAGs — do not invent new patterns
- ALWAYS use the XCom contract: `{"output_file": str, "run_dir": str}` for every task
- ALWAYS add `cleanup_files` as the final task in the chain
- ALWAYS use `get_airflow_logger()` for logging, NEVER `print()`
- NEVER hardcode secrets — use `get_secret()` via `get_vault_key()`
- NEVER use deprecated Airflow imports — use `airflow.providers.standard.operators.python.PythonOperator`
- The project runs Airflow 3.0.1 with Python 3.9 inside Docker
- Data passes between tasks via Parquet files in `dags/processed_data/{run_id}/`
- The project uses Azure Key Vault for all secrets, Azure SQL as source, PostgreSQL as target
