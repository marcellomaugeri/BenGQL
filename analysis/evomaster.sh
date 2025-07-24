#!/bin/bash

# Check if an experiment folder name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <experiment_folder_name>"
  exit 1
fi

# Set the base directory for results relative to the script's location
RESULTS_DIR="./results"
EXPERIMENT_FOLDER="$RESULTS_DIR/$1/EvoMaster"

# Check if the experiment folder exists
if [ ! -d "$EXPERIMENT_FOLDER" ]; then
  echo "Error: Experiment folder '$EXPERIMENT_FOLDER' not found."
  exit 1
fi

# Print the table header using printf for alignment
printf "%-25s %-10s %-10s %-10s %-10s\n" "Case" "Requests" "Req/s" "Faults" "Succ. (%)"
echo "-----------------------------------------------------------------------"

# Loop through each case study directory in the EvoMaster folder
for case_study_dir in "$EXPERIMENT_FOLDER"/*/; do
  if [ -d "$case_study_dir" ]; then
    case_name=$(basename "$case_study_dir")
    log_file="${case_study_dir}_EvoMaster.log"

    if [ -f "$log_file" ]; then
      # Extract data from the log file
      requests=$(grep "Evaluated actions:" "$log_file" | awk '{print $4}')
      passed_time=$(grep "Passed time (seconds):" "$log_file" | awk '{print $5}')
      faults=$(grep "Potential faults:" "$log_file" | awk '{print $4}')
      succ_perc=$(grep "Successfully executed" "$log_file" | sed -n 's/.*(\([0-9]*\)%).*/\1/p')

      # Calculate requests per second
      if (( $(echo "$passed_time > 0" | bc -l) )); then
        req_per_sec=$(echo "scale=2; $requests / $passed_time" | bc)
      else
        req_per_sec=0
      fi

      # Print the formatted table row
    printf "%-25s %-10s %-10s %-10s %-10s\n" "$case_name" "$requests" "$req_per_sec" "$faults" "$succ_perc"
    fi
  fi
done