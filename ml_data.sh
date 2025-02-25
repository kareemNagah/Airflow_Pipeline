#!/bin/bash 

docker exec -it postgres_db psql -U airflow -d nyc_taxi -c "\copy (SELECT * FROM ml_ready_data) TO '/tmp/ml_ready_data.csv' CSV HEADER"
docker cp postgres_db:/tmp/ml_ready_data.csv ./Data/ml_ready_data.csv