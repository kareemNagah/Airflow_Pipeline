#!/bin/bash

set -e

# Create the nyc_taxi database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE nyc_taxi;
EOSQL

# Connect to nyc_taxi database and create the raw_nyc_taxi table
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "nyc_taxi" <<-EOSQL
    CREATE TABLE IF NOT EXISTS raw_nyc_taxi (
        pickup_datetime TIMESTAMP,
        dropoff_datetime TIMESTAMP,
        passenger_count INTEGER,
        trip_distance FLOAT,
        pickup_longitude FLOAT,
        pickup_latitude FLOAT,
        dropoff_longitude FLOAT,
        dropoff_latitude FLOAT,
        fare_amount FLOAT
    );


EOSQL 