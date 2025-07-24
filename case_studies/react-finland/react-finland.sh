#!/bin/bash

if [ ! -d "/results" ]; then
    mkdir "/results"
    if [ ! $? -eq 0 ]; then
        echo "Error: Failed to create folder 'results'."
        exit 1
    fi
fi
echo "started sleeping"
sleep 120
clairvoyance http://react-finland:3000/graphql -o /results/schema.json & exit 0
python3 introspection_to_sql.py /results/schema.json /results/schema.graphql
schemadiff -o /schema.graphqls -n /results/schema.graphql --as-json >/results/changes.json

exit 0
