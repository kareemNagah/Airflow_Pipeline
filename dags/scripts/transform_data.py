import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def get_database_url():
    """Create database URL from environment variables"""
    user = os.getenv("POSTGRES_USER", "airflow")
    password = os.getenv("POSTGRES_PASSWORD", "airflow")
    host = os.getenv("POSTGRES_HOST", "postgres_db")
    port = os.getenv("POSTGRES_PORT", "5432")
    db = os.getenv("POSTGRES_DB", "nyc_taxi")
    return f"postgresql://{user}:{password}@{host}:{port}/{db}"

def transform_data():
    """Transform NYC taxi data for ML purposes"""
    # Connect to database
    engine = create_engine(get_database_url())
    
    # Read raw data
    df = pd.read_sql("""
        SELECT pickup_datetime, dropoff_datetime, passenger_count, 
               trip_distance, fare_amount, pu_location_id, do_location_id
        FROM raw_nyc_taxi
    """, engine)
    
    # Clean data by removing missing values
    df.dropna(inplace=True)
    
    # Convert datetime columns
    df['pickup_datetime'] = pd.to_datetime(df['pickup_datetime'])
    df['dropoff_datetime'] = pd.to_datetime(df['dropoff_datetime'])
    
    # Feature Engineering
    df['trip_duration'] = (df['dropoff_datetime'] - df['pickup_datetime']).dt.total_seconds()
    df['hour_of_day'] = df['pickup_datetime'].dt.hour
    df['day_of_week'] = df['pickup_datetime'].dt.dayofweek
    df['weekend'] = df['day_of_week'].apply(lambda x: 1 if x in [5,6] else 0)
    df['fare_per_km'] = df['fare_amount'] / df.apply(lambda x: x['trip_distance'] if x['trip_distance'] > 0 else float('inf'), axis=1)
    df = df[df['fare_per_km'] < float('inf')]
    
    # Save transformed data
    df.to_sql('nyc_taxi_transformed', engine, if_exists='replace', index=False)

if __name__ == '__main__':
    transform_data()
