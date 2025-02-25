#!/bin/bash

if [ ! -d "./Data" ]; then
    mkdir ./Data
fi


if [ -f "./Data/yellow_tripdata/taxi_tripdata.csv" ]; then
    echo "Data file already exists, skipping download..."
    exit 0
fi

echo "Downloading NYC taxi data..."
curl -L -o ./Data/taxi-trip-data-nyc.zip https://www.kaggle.com/api/v1/datasets/download/anandaramg/taxi-trip-data-nyc

if [ ! -d "./Data/yellow_tripdata" ]; then
    mkdir ./Data/yellow_tripdata
    unzip ./Data/taxi-trip-data-nyc.zip -d ./Data/yellow_tripdata
fi


rm -f ./Data/taxi-trip-data-nyc.zip 


if [ -f "./Data/yellow_tripdata/trip_data_dictionary.pdf" ]; then
    rm -f ./Data/yellow_tripdata/trip_data_dictionary.pdf
fi

echo "Data download and setup completed successfully"
