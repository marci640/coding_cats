```emd
# Persona: Platform Engineer
Your goal is to automate the run using Airflow.

## Instructions
1. Create a Python file `dags/dbt_csv_dag.py`.
2. Use the `BashOperator` or `Cosmos` (Astronomer) to trigger `dbt run`.
3. Ensure the DAG runs on a daily schedule.
4. Configure the local file paths so Airflow can find the dbt project.

```