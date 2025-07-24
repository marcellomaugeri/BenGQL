#!/bin/bash

CASES_DIR="./case_studies"
SUMMARY=""

# List all available cases (subdirectories with a docker-compose.yml)
get_all_cases() {
  find "$CASES_DIR" -maxdepth 1 -mindepth 1 -type d | while read -r dir; do
    if [ -f "$dir/docker-compose.yaml" ] || [ -f "$dir/docker-compose.yml" ]; then
      basename "$dir"
    fi
  done
}

# Function to display help
show_help() {
  echo "Usage: $0 {up|down|ps} {case1 case2 ... | all}"
  echo ""
  echo "Available case studies:"
  for case in $(get_all_cases); do
    echo "- $case"
  done
}

# Function to process and print exposed ports for the current case
print_summary() {
  local case_path="$1"
  local exp_flag="$2"
  local case_name
  case_name=$(basename "$case_path")
  # Capture container IDs using docker compose ps -q
  CONTAINER_IDS=$(cd "$case_path" && docker compose $exp_flag ps -q)
  for id in $CONTAINER_IDS; do
    # Get the container name using docker ps filtering by the container ID
    container_name=$(docker ps --filter "id=$id" --format "{{.Names}}")

    # Only include containers that match the expected pattern (avoid other containers in the same compose file)
    if [[ "$container_name" != *"${EXP_NAME}-${case_name}"* ]]; then
      continue
    fi

    # Extract the host port from the docker port output.
    # This assumes an output format like: 0.0.0.0:8080 -> 3000/tcp
    host_port=$(docker port "$id" | sed -n 's/.*0\.0\.0\.0:\([0-9]*\).*/\1/p')
    
    # Print the container name and the extracted port (if any)
    echo "$container_name : $host_port"
    SUMMARY="${SUMMARY}\n$container_name : $host_port"
  done
}

# If no arguments provided or 'help' is the first argument, display help and exit.
if [ "$#" -eq 0 ] || [ "$1" == "help" ]; then
  show_help
  exit 0
fi

COMMAND=$1
shift

# Expand 'all' into the full list
if [ "$1" == "all" ]; then
  shift
  CASES=$(get_all_cases)
else
  CASES="$@"
fi

# Validate command
if [[ "$COMMAND" != "up" && "$COMMAND" != "down" && "$COMMAND" != "ps" && "$COMMAND" != "build" ]]; then
  echo "Usage: $0 {up|down|ps|build} {case1 case2 ... | all}"
  exit 1
fi

# Execute command for each case
for CASE in $CASES; do
  CASE_PATH="$CASES_DIR/$CASE"

  if [ -f "$CASE_PATH/docker-compose.yaml" ] || [ -f "$CASE_PATH/docker-compose.yml" ]; then
    echo "==> $COMMAND: $CASE"

    # If EXP_NAME is set, add the project flag with the value: case-EXP_NAME
    if [ -n "$EXP_NAME" ]; then
      EXP_FLAG="-p ${CASE}-${EXP_NAME}"
    else
      EXP_FLAG=""
    fi

    if [ "$COMMAND" == "ps" ]; then
      (cd "$CASE_PATH" && docker compose $EXP_FLAG ps)
      # Print exposed ports for ps as well
      print_summary "$CASE_PATH" "$EXP_FLAG"
    elif [ "$COMMAND" == "down" ]; then
      (cd "$CASE_PATH" && docker compose $EXP_FLAG down)
    elif [ "$COMMAND" == "up" ]; then        
      (cd "$CASE_PATH" && docker compose $EXP_FLAG up -d --build)
      # Process and print exposed ports after running up
      print_summary "$CASE_PATH" "$EXP_FLAG"
    elif [ "$COMMAND" == "build" ]; then
      (cd "$CASE_PATH" && docker compose build)
    fi
  else
    echo "!! Skipping '$CASE' — no docker-compose file found."
  fi
done

# Print the final summary after processing all cases
if [ "$COMMAND" == "up" ]; then
  echo -e "\nExperiments Running:"
  echo -e "$SUMMARY"
fi