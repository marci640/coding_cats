"""
Airflow DAG: dbt_csv_pipeline
Triggers a dbt run + test for the coding_cats staging pipeline.
Schedule: Daily at 06:00 UTC
"""

from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.operators.bash import BashOperator

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DBT_PROJECT_DIR = Path(__file__).resolve().parent.parent / "dbt_project"
DBT_PROFILES_DIR = DBT_PROJECT_DIR  # adjust if profiles.yml lives elsewhere

DEFAULT_ARGS = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# ---------------------------------------------------------------------------
# DAG Definition
# ---------------------------------------------------------------------------
with DAG(
    dag_id="dbt_csv_pipeline",
    default_args=DEFAULT_ARGS,
    description="Runs the coding_cats staging pipeline and executes tests.",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["dbt", "csv", "staging"],
) as dag:

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt seed --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt run --models staging.stg_raw_data --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt test --models staging.stg_raw_data --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    # Task dependency chain
    dbt_seed >> dbt_run >> dbt_test
