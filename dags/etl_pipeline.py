from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime
from sqlalchemy import create_engine
import pandas as pd
import os

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 2, 25),
    'retries': 1,
}

def load_data():
    """
    Load the final ML-ready dataset from the transformed table.
    This step creates a new table 'ml_ready_data' based on further filtering
    and exports it to a CSV file.
    """
    POSTGRES_USER = os.getenv("POSTGRES_USER", "airflow")
    POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "airflow")
    POSTGRES_DB = "nyc_taxi"
    POSTGRES_HOST = "postgres_db"
    POSTGRES_PORT = "5432"
    engine = create_engine(f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}")

    sql = """
    CREATE TABLE IF NOT EXISTS ml_ready_data AS
    SELECT 
        trip_distance, 
        fare_amount, 
        passenger_count, 
        trip_duration, 
        hour_of_day, 
        day_of_week, 
        weekend, 
        fare_per_km
    FROM nyc_taxi_transformed
    WHERE trip_distance > 0 AND fare_amount > 0;
    """
    with engine.connect() as connection:
        connection.execute(sql)


with DAG("nyc_taxi_etl", default_args=default_args, schedule="0 12 * * *", catchup=False) as dag:
    
    # Extraction step: Here, we simply log that raw data is already in PostgreSQL.
    extract_task = BashOperator(
        task_id="extract",
        bash_command="echo 'Extraction complete: raw data is available in PostgreSQL.'"
    )
    
    # Transformation step: Run the external transformation script.
    transform_task = BashOperator(
        task_id="transform",
        bash_command="python3 ${AIRFLOW_HOME}/dags/scripts/transform_data.py"
    )
    
    # Load step: Create the final ML-ready table.
    load_task = PythonOperator(
        task_id="load",
        python_callable=load_data
    )
    
    extract_task >> transform_task >> load_task
