#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found"
    echo "Please copy .env.example to .env and fill in your credentials"
    exit 1
fi

# Set default PostgreSQL user to airflow if not specified
POSTGRES_USER=${POSTGRES_USER:-airflow}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-airflow}

# Check for required environment variables
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    echo "Error: PostgreSQL credentials not found in .env file"
    exit 1
fi

# Install docker-compose if not exists
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found, installing..."
    sudo apt update
    sudo apt install -y docker-compose
else
    echo "docker-compose is already installed"
fi

# Start docker containers in detached mode
echo "Starting Docker containers..."
docker-compose up -d postgres_db

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Create nyc_taxi database
echo "Creating nyc_taxi database..."
docker exec -it postgres_db psql -U airflow -d airflow -c "CREATE DATABASE nyc_taxi;"

# Check if data file exists
if [ ! -f "./Data/yellow_tripdata/taxi_tripdata.csv" ]; then
    echo "Error: Data file not found. Please run get_data.sh first"
    exit 1
fi

# Copy data to postgres container
echo "Copying data to PostgreSQL container..."
docker cp ./Data/yellow_tripdata/taxi_tripdata.csv postgres_db:/tmp/taxi_tripdata.csv

# Drop and recreate table
echo "Creating raw_nyc_taxi table..."
docker exec -it postgres_db psql -U airflow -d nyc_taxi -c "DROP TABLE IF EXISTS raw_nyc_taxi;"

docker exec -it postgres_db psql -U airflow -d nyc_taxi -c "
CREATE TABLE raw_nyc_taxi (
    trip_id SERIAL PRIMARY KEY,
    vendor_id INTEGER,
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    store_and_fwd_flag VARCHAR(1),
    rate_code_id INTEGER,
    pu_location_id INTEGER,
    do_location_id INTEGER,
    passenger_count INTEGER,
    trip_distance FLOAT,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    ehail_fee FLOAT, 
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    payment_type INTEGER,  
    trip_type INTEGER,  
    congestion_surcharge FLOAT,
    airport_fee FLOAT
);"

# Bulk insert data from CSV
echo "Loading data from CSV..."
docker exec -it postgres_db psql -U airflow -d nyc_taxi -c "\COPY raw_nyc_taxi(
    vendor_id, 
    pickup_datetime, 
    dropoff_datetime, 
    store_and_fwd_flag,
    rate_code_id,
    pu_location_id,
    do_location_id,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    ehail_fee,  
    improvement_surcharge,
    total_amount,
    payment_type,  
    congestion_surcharge,
    airport_fee
) FROM '/tmp/taxi_tripdata.csv' CSV HEADER;"

# Check number of rows in the table
echo "Verifying data load..."
docker exec -it postgres_db psql -U airflow -d nyc_taxi -c "SELECT COUNT(*) FROM raw_nyc_taxi;"

echo "Database setup completed successfully"



