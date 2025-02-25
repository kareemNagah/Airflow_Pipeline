#!/bin/bash

# Make  scripts executable
chmod +x get_data.sh build_psql.sh py_setup.sh


if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "Please edit .env file with your credentials before continuing"
    exit 1
fi

# Setup Python environment
echo "Setting up Python environment..."
./py_setup.sh
if [ $? -ne 0 ]; then
    echo "Error: Python setup failed"
    exit 1
fi

# Download data
echo "Downloading NYC taxi data..."
./get_data.sh
if [ $? -ne 0 ]; then
    echo "Error: Data download failed"
    exit 1
fi

# Setup PostgreSQL and load data
echo "Setting up PostgreSQL and loading data..."
./build_psql.sh
if [ $? -ne 0 ]; then
    echo "Error: PostgreSQL setup failed"
    exit 1
fi

# Create Airflow directories
echo "Creating Airflow directories..."
mkdir -p ./dags ./logs ./plugins
mkdir -p ./dags/scripts
sudo chmod -R 777 ./logs  #---> Everyone (owner, group, and others) gets All permissions

# Copy DAG and scripts
echo "Copying DAG and scripts..."
cp etl_pipeline.py dags/
cp scripts/transform_data.py dags/scripts/

# Start Airflow services
echo "Starting Airflow services..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "Error: Failed to start Airflow services"
    exit 1
fi

echo "Setup completed successfully!"
echo "Airflow UI is available at: http://localhost:8080"
echo "Username: airflow"
echo "Password: airflow" 