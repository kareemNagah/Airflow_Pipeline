# Airflow ETL Pipeline

## Prerequisites
Ensure you have the following installed:
- Docker
- Docker Compose
- Python 3.x
- Git

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/kareemNagah/Airflow_Pipeline.git
cd Airflow_Pipeline
```

### 2. Set Up Environment Variables
Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```
Edit the `.env` file with your PostgreSQL credentials before proceeding.

For testing, your `.env` file should look like this:
```
# PostgreSQL credentials
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow

# Airflow credentials
AIRFLOW_USERNAME=airflow
AIRFLOW_PASSWORD=airflow
```

### 3. Make Scripts Executable
Run the following command to make the setup scripts executable:
```bash
chmod +x get_data.sh build_psql.sh py_setup.sh setup.sh
```

### 4. Run the Setup Script
Execute the setup script to automate the environment setup:
```bash
./setup.sh
```
This script will:
- Set up the Python virtual environment
- Download the NYC taxi data
- Set up PostgreSQL and load the data
- Start Airflow services

### 5. Access Airflow UI
Once the setup is complete, open your browser and navigate to:
```
http://localhost:8080
```
Use the default credentials:
- **Username:** `airflow`
- **Password:** `airflow`

## Running the ETL Pipeline

### 1. Trigger the DAG
- In the Airflow UI, locate the **nyc_taxi_etl** DAG.
- Click the **Play** button to trigger the pipeline.

### 2. Monitor the Pipeline
You can monitor the progress of the ETL pipeline in the Airflow UI.
The pipeline consists of three tasks:
- **Extract:** Logs that raw data is available in PostgreSQL.
- **Transform:** Runs the transformation script (`transform_data.py`).
- **Load:** Creates the final ML-ready table (`ml_ready_data`).

## Accessing the ML-Ready Data

### 1. Export the Data
Run the following script to export the ML-ready data to a CSV file:
```bash
./ml_data.sh
```
The data will be saved to `./Data/ml_ready_data.csv`.

### 2. Use the Data
You can now use the exported CSV file for machine learning or further analysis.

## Troubleshooting

### 1. Airflow Not Starting
Ensure Docker services are running and restart Airflow:
```bash
docker-compose down
docker-compose up -d
```

### 2. Database Connection Issues
Check your `.env` file and ensure PostgreSQL credentials are correct.
Restart PostgreSQL if necessary:
```bash
docker restart postgres_container
```

## Contributing
Feel free to submit issues or contribute improvements via pull requests.


