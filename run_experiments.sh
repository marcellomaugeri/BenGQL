#!/bin/bash

# --- Configuration ---
# Generate a 5-digit random number for default experiment name
DEFAULT_EXP_NAME="exp-$(printf "%05d" $((RANDOM % 90000 + 10000)))"
DEFAULT_MAX_PARALLEL_TESTS=5 # Default maximum number of parallel tests to run
RESULTS_DIR="./results" # Host path for all experiment outputs
TOOLS_DIR="./tools" # Directory containing all tools
CASE_STUDIES_DIR="./case_studies" # Directory containing all case studies
DEFAULT_TIME_BUDGET=60 # Time budget in seconds for each test (default: 60 seconds)

# --- Temporary Directory for test results (status markers) ---
TMP_RESULTS_DIR=$(mktemp -d "/tmp/${DEFAULT_EXP_NAME}_results_XXXXXX")
if [ ! -d "$TMP_RESULTS_DIR" ]; then
    echo "Failed to create temporary directory. Exiting."
    exit 1
fi

cleanup() {
    log "Cleaning up temporary results directory: $TMP_RESULTS_DIR"
    rm -rf "$TMP_RESULTS_DIR"
}
trap cleanup EXIT SIGINT SIGTERM

# --- Helper Functions ---
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

get_all_tools() {
    find "$TOOLS_DIR" -maxdepth 1 -mindepth 1 -type d \
        -exec test -f '{}/docker-compose.yml' \; -print0 | xargs -0 -I {} basename '{}' | sort -u
}

get_all_case_studies() {
    find "$CASE_STUDIES_DIR" -maxdepth 1 -mindepth 1 -type d \
        -exec test -f '{}/docker-compose.yml' \; \
        -a -exec test -f '{}/ENDPOINT' \; -print0 | xargs -0 -I {} basename '{}' | sort -u
}

# --- Argument Parsing ---
EXP_NAME="$DEFAULT_EXP_NAME" 
INPUT_TOOLS_LIST="" # Comma-separated list of tools to run, or "all" for all available tools
INPUT_CASE_STUDIES_LIST="" # Comma-separated list of case studies to run, or "all" for all available case studies
MAX_PARALLEL_TESTS="$DEFAULT_MAX_PARALLEL_TESTS" # Maximum number of parallel tests (a test consists of a pair <tool, case_study>) to run
TIME_BUDGET="$DEFAULT_TIME_BUDGET" # Time budget in seconds for each test (default: 60 seconds)

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --exp_name) EXP_NAME="$2"; shift ;;
        --tools) INPUT_TOOLS_LIST="$2"; shift ;;
        --case_studies) INPUT_CASE_STUDIES_LIST="$2"; shift ;;
        --max_parallel_tests) MAX_PARALLEL_TESTS="$2"; shift ;;
        --time_budget) TIME_BUDGET="$2"; shift ;;
        -h|--help) 
            echo "Usage: $0 [--exp_name EXP_NAME] [--tools TOOL1,TOOL2,... | all] [--case_studies CS1,CS2,... | all] [--max_parallel_tests N] [--time_budget TIME_IN_SECONDS]"
            echo "Default experiment name: $DEFAULT_EXP_NAME"
            echo "Default max parallel tests: $DEFAULT_MAX_PARALLEL_TESTS"
            echo "Default time budget (in seconds): $DEFAULT_TIME_BUDGET"
            echo "Available tools: $(get_all_tools | tr '\n' ', ')"
            echo "Available case studies: $(get_all_case_studies | tr '\n' ', ')"
            exit 0 ;;
        *) log "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ "$MAX_PARALLEL_TESTS" -le 0 ]; then
    log "Invalid maximum parallel tests value: $MAX_PARALLEL_TESTS. Must be greater than 0."
    exit 1
fi
if [ "$TIME_BUDGET" -le 0 ]; then
    log "Invalid time budget value: $TIME_BUDGET. Must be greater than 0."
    exit 1
fi

# --- Resolve Tool and Case Study Lists ---
ALL_AVAILABLE_TOOLS=($(get_all_tools))
ALL_AVAILABLE_CASE_STUDIES=($(get_all_case_studies))

if [ "$INPUT_TOOLS_LIST" == "all" ]; then
    SELECTED_TOOLS=("${ALL_AVAILABLE_TOOLS[@]}")
else
    IFS=',' read -r -a SELECTED_TOOLS <<< "$INPUT_TOOLS_LIST"
fi

if [ "$INPUT_CASE_STUDIES_LIST" == "all" ]; then
    SELECTED_CASE_STUDIES=("${ALL_AVAILABLE_CASE_STUDIES[@]}")
else
    IFS=',' read -r -a SELECTED_CASE_STUDIES <<< "$INPUT_CASE_STUDIES_LIST"
fi

if [ ${#SELECTED_TOOLS[@]} -eq 0 ]; then
    log "No tools selected or found. Exiting."
    exit 1
fi
if [ ${#SELECTED_CASE_STUDIES[@]} -eq 0 ]; then
    log "No case studies selected or found. Exiting."
    exit 1
fi

log "Experiment Name: $EXP_NAME" 
log "Max Parallel Tests: $MAX_PARALLEL_TESTS"
log "Temporary result markers will be stored in: $TMP_RESULTS_DIR"
log "Tool outputs will be in: $RESULTS_DIR/$EXP_NAME"
log "Time Budget per Test: $TIME_BUDGET seconds"
log "Selected Tools: ${SELECTED_TOOLS[*]}"
log "Selected Case Studies: ${SELECTED_CASE_STUDIES[*]}"


# --- Main Test Execution Function (to be run in background) ---
run_single_test() {
    local tool_name="$1"
    local case_study_name="$2"
    local current_exp_name="$3"
    local current_tmp_results_dir="$4"

    local test_id="${tool_name}_${case_study_name}" # Unique identifier for this test
    local result_file="${current_tmp_results_dir}/${test_id}.result" # For ✅/❌ status
    log "[$test_id] Starting test."

    local case_study_project_name="${current_exp_name}_${case_study_name}_${tool_name}" # MUST BE LOWERCASE
    case_study_project_name=$(echo "$case_study_project_name" | tr '[:upper:]' '[:lower:]') # Ensure project name is lowercase
    local tool_project_name="${current_exp_name}_${tool_name}_${case_study_name}" # MUST BE LOWERCASE
    tool_project_name=$(echo "$tool_project_name" | tr '[:upper:]' '[:lower:]') # Ensure project name is lowercase

    local case_study_dir="${CASE_STUDIES_DIR}/${case_study_name}"
    local tool_dir="${TOOLS_DIR}/${tool_name}"

    # Directory *inside the tool's container* where it should place its output files.
    # The tool's docker-compose.yml MUST map the host's $RESULTS_DIR to /results in the container.
    local tool_output_dir_container_path="/results/${current_exp_name}/${tool_name}/${case_study_name}"

    # Create the output directory on the host if it doesn't exist
    mkdir -p "${RESULTS_DIR}/${current_exp_name}"
    mkdir -p "${RESULTS_DIR}/${current_exp_name}/${tool_name}"
    mkdir -p "${RESULTS_DIR}/${current_exp_name}/${tool_name}/${case_study_name}"

    # Default result to failure, overwrite on success
    echo "❌ (Setup)" > "$result_file"

    # Save the tool's output log file path
    local cs_log_file="../..${tool_output_dir_container_path}/_${case_study_name}.log"

    # 1. Start Case Study
    log "[$test_id] Starting case study '$case_study_name' which will be targeted by tool '$tool_name'."

    # Run the case study, tee output, and capture the exit code of the cs (not tee)
    (cd "$case_study_dir" && docker compose -p "$case_study_project_name" up -d --wait --remove-orphans | tee "$cs_log_file" > /dev/null)
    case_study_exit_code=${PIPESTATUS[0]}
    # Truncate cs_log_file to 50 lines if it exceeds that length
    if [ -f "$cs_log_file" ]; then
        log_file_lines=$(wc -l < "$cs_log_file")
        if [ "$log_file_lines" -gt 50 ]; then
            tail -n 50 "$cs_log_file" > "${cs_log_file}.tmp" && mv "${cs_log_file}.tmp" "$cs_log_file"
        fi
    fi

    if [ $case_study_exit_code -ne 0 ]; then
        # If the case study fails to start, we log the error and clean up.
        log "[$test_id] ERROR: Failed to start case study '$case_study_name'."
        echo "❌ (Case Study Start)" > "$result_file"
        (cd "$case_study_dir" && docker compose -p "$case_study_project_name" down -v --remove-orphans &>/dev/null) || true
        return 1
    fi
    log "[$test_id] Case study '$case_study_name' for the tool '$tool_name' started successfully."

    # 2. Get Case Study Port, endpoint and eventual authentication header
    local case_study_port
    local raw_port_info

    log "[$test_id] Attempting to get exposed host port for service '$case_study_name' in project '$case_study_project_name'."

    # Get port mapping(s) for the service.
    case_study_port=$(docker ps --filter "label=com.docker.compose.project=$case_study_project_name" --filter "label=com.docker.compose.service=$case_study_name" --format "{{.Ports}}" 2>/dev/null | sed -n 's/.*:\([0-9]*\)->.*/\1/p')


    if [ -z "$case_study_port" ] || ! [[ "$case_study_port" =~ ^[0-9]+$ ]]; then
        # If the pipeline failed (e.g., 'docker compose port' gave no output, or awk failed to parse),
        # case_study_port will be empty or non-numeric.
        log "[$test_id] ERROR: Failed to get or parse a valid host port for service '$case_study_name'. Parsed value: '$case_study_port'."
        echo "❌ (Case Study: Port Error)" > "$result_file"
        (cd "$case_study_dir" && docker compose -p "$case_study_project_name" down -v --remove-orphans &>/dev/null) || true
        return 1
    fi

    local case_study_endpoint_path
    case_study_endpoint_path=$(cat "${case_study_dir}/ENDPOINT")
    local target_url="http://host.docker.internal:${case_study_port}${case_study_endpoint_path}"
    log "[$test_id] Case study target URL: $target_url"

    # Export CASE_STUDY_ENDPOINT for the auth script (note that it runs locally, not in the container)
    # By default, authentication scripts starts from the root path, but some case studies may have a different endpoint.
    export CASE_STUDY_ENDPOINT="http://localhost:${case_study_port}"
    # Some others could run on the graphql path, so we check a list of case studies (for now just react-ecommerce)
    if [[ "$case_study_name" == "react-ecommerce" || "$case_study_name" == "ADD-HERE-OTHER-CASE-STUDIES" ]]; then
        export CASE_STUDY_ENDPOINT="http://localhost:${case_study_port}${case_study_endpoint_path}"
    fi

    # Here we check if the case study has an authentication header script. If yes, we execute it to get the header.
    local auth_script_path="${case_study_dir}/auth.sh"
    local auth_header
    if [ -f "$auth_script_path" ]; then
        log "[$test_id] Found authentication script for case study '$case_study_name'. Executing to get auth header on the endpoint: $CASE_STUDY_ENDPOINT"
        auth_header=$(bash "$auth_script_path" 2>/dev/null)
        # Fail if:
        # 1. auth_header starts with "Authorization:" or "Cookie:" but lacks a header-value
        # 2. auth_header doesn't start with those prefixes and is empty
        if { [[ "$auth_header" =~ ^(Authorization:|Cookie:) ]] \
        && ! [[ "$auth_header" =~ ^(Authorization:|Cookie:)[[:space:]]+.+ ]] ; } \
        || { ! [[ "$auth_header" =~ ^(Authorization:|Cookie:) ]] \
        && [ -z "$auth_header" ] ; }; then
            log "[$test_id] ERROR: Authentication script for case study '$case_study_name' returned an empty header: '$auth_header'."
            echo "❌ (Case Study: Auth Error)" > "$result_file"
            (cd "$case_study_dir" && docker compose -p "$case_study_project_name" down -v --remove-orphans &>/dev/null) || true
            return 1
        fi
        log "[$test_id] Authentication header for case study '$case_study_name': $auth_header"
    fi

    unset CASE_STUDY_ENDPOINT # Unset the variable to avoid conflicts in the tool execution

    # 3. Run Tool
    local tool_command_args # This will hold the arguments part of the command

    # Define tool command arguments based on tool_name
    # {TARGET_URL}, {OUTPUT_DIR_PATH}, {AUTH_HEADER}, {TIME_BUDGET} are available placeholders and will be replaced later.
    # ==================================== clairvoyance / Clairvoyance-Next =========================================
    if [ "$tool_name" == "clairvoyance" ] || [ "$tool_name" == "Clairvoyance-Next" ]; then
        tool_command_args="poetry run clairvoyance {TARGET_URL} -o {OUTPUT_DIR_PATH}/schema.json"
        log "[$test_id] Using specific command for tool '$tool_name'."
    # ==================================== EvoMaster =========================================
    elif [ "$tool_name" == "EvoMaster" ]; then
        if [ -n "$auth_header" ]; then
            tool_command_args="--problemType GRAPHQL --bbTargetUrl {TARGET_URL} --outputFolder {OUTPUT_DIR_PATH} --maxTime {TIME_BUDGET}s --header0 \"{AUTH_HEADER}\" --blackBox true --outputFormat PYTHON_UNITTEST"
            log "[$test_id] Using specific command for tool '$tool_name'."
        else
            tool_command_args="--problemType GRAPHQL --bbTargetUrl {TARGET_URL} --outputFolder {OUTPUT_DIR_PATH} --maxTime {TIME_BUDGET}s --blackBox true --outputFormat PYTHON_UNITTEST"
            log "[$test_id] Using specific command for tool '$tool_name'."
        fi
    # ==================================== curl =========================================
    elif [ "$tool_name" == "curl" ]; then
        # Curl tool for making HTTP requests.
# Curl tool for making HTTP requests.
    if [ -n "$auth_header" ]; then
        tool_command_args="-X POST {TARGET_URL} -H \"Content-Type: application/json\" -H \"{AUTH_HEADER}\" -d '{\"query\": \"{ __typename }\"}'"
    else
        tool_command_args="-X POST {TARGET_URL} -H \"Content-Type: application/json\" -d '{\"query\": \"{ __typename }\"}'"
    fi
    # ==================================== Rover =========================================
    elif [ "$tool_name" == "rover" ]; then
        # Rover tool for GraphQL schema introspection.
        if [ -n "$auth_header" ]; then
            # Rover expects a key:value format, so if there is a space between Authorization: and Bearer, we need to remove it.
            # Also, if there is a space between Bearer and the token, we need to escape it
            auth_header="$(echo "$auth_header" | sed -E 's#^Authorization:[[:space:]]*Bearer[[:space:]]*(.+)$#Authorization:Bearer \1#')"
            tool_command_args="graph introspect -H \"{AUTH_HEADER}\" --output {OUTPUT_DIR_PATH}/schema.graphql {TARGET_URL}"
        else
            # If no auth header is provided, we use the default command without it.
            tool_command_args="graph introspect {TARGET_URL} --output {OUTPUT_DIR_PATH}/schema.graphql"
    fi
    # ==================================== graphql-cop =========================================
    elif [ "$tool_name" == "graphql-cop" ]; then
        # GraphQL Cop tool for security analysis.
        if [ -n "$auth_header" ]; then
            # GraphQL Cop expects the auth header to be passed in a json format. So we split it into key-value pairs.
            # e.g. '"Authorization": "Bearer <token>"' we split it into '{"Authorization": "Bearer <token>"}'
            # This is a workaround to pass the header correctly.
            auth_header="$(echo "$auth_header" | sed -E 's/^([^:]+): (.+)$/{"\1": "\2"}/')"
            tool_command_args="--target {TARGET_URL} --header {AUTH_HEADER}"
        else
            tool_command_args="--target {TARGET_URL}"
        fi
        log "[$test_id] Using specific command for tool '$tool_name'."
    # ==================================== graphqlw00f =========================================
    elif [ "$tool_name" == "graphqlw00f" ]; then
        if [ -n "$auth_header" ]; then
            tool_command_args="-d -f --target {TARGET_URL} -H {AUTH_HEADER}"
        else
            tool_command_args="-d -f --target {TARGET_URL}"
        fi
        log "[$test_id] Using specific command for tool '$tool_name'."

    # ==================================== GraphQLer =========================================
    elif [ "$tool_name" == "GraphQLer" ]; then
        # GraphQLer tool for schema introspection.
        if [ -n "$auth_header" ]; then
            # GraphQLer expects only the token part of the header, so we extract it. E.g. "Authorization : Bearer <token>" becomes just "Bearer <token>"
            auth_header="$(echo "$auth_header" | sed -E 's/^Authorization: (.+)$/\1/')"
            tool_command_args="--mode run --url {TARGET_URL} --path {OUTPUT_DIR_PATH} --auth {AUTH_HEADER}"
        else
            tool_command_args="--mode run --url {TARGET_URL} --path {OUTPUT_DIR_PATH}"
        fi
        log "[$test_id] Using specific command for tool '$tool_name'."

    # Add elif blocks for other tools with specific command structures
    # elif [ "$tool_name" == "AnotherTool" ]; then
    #    tool_command_args="--input {TARGET_URL} --out-dir {OUTPUT_DIR_PATH}"
    else
        # Default: tool's entrypoint takes target URL as its main argument.
        # Output directory is implicitly known by the tool via its mapped /results volume.
        tool_command_args="{TARGET_URL}"
        log "[$test_id] Using default command for tool '$tool_name'."
    fi

    # Replace placeholders in the chosen command template
    tool_command_args="${tool_command_args//\{TARGET_URL\}/$target_url}"
    tool_command_args="${tool_command_args//\{OUTPUT_DIR_PATH\}/$tool_output_dir_container_path}"
    tool_command_args="${tool_command_args//\{AUTH_HEADER\}/$auth_header}"
    tool_command_args="${tool_command_args//\{TIME_BUDGET\}/$TIME_BUDGET}"

    # Convert the single string into an array, honoring any embedded quotes:
    eval "tool_args_array=( $tool_command_args )"

    log "[$test_id] Running tool '$tool_name' for case study '$case_study_name' with service '$tool_name' and args: ${tool_args_array[*]}"
    # Tee redirects the tool's output to a log file in the results directory. The path is relative to the host.

    local tool_log_file="../..${tool_output_dir_container_path}/_${tool_name}.log"
    
    # Run the tool, tee output, and capture the exit code of the tool
    (cd "$tool_dir" && docker compose -p "$tool_project_name" run -T --rm "$tool_name" "${tool_args_array[@]}" | tee "$tool_log_file" > /dev/null)
    tool_exit_code=${PIPESTATUS[0]}

    if [ $tool_exit_code -ne 0 ]; then
        log "[$test_id] ERROR: Tool '$tool_name' failed for case study '$case_study_name'."
        echo "❌ (Tool Fail)" > "$result_file"
    else
        log "[$test_id] Tool '$tool_name' completed for case study '$case_study_name'."
        # Truncate tool_log_file to 1000 lines if it exceeds that length
        if [ -f "$tool_log_file" ]; then
            log_file_lines=$(wc -l < "$tool_log_file")
            if [ "$log_file_lines" -gt 1000 ]; then
                log "[$test_id] Tool log file '$tool_log_file' has more than 1000 lines. Truncating to the last 1000 lines."
                tail -n 1000 "$tool_log_file" > "${tool_log_file}.tmp" && mv "${tool_log_file}.tmp" "$tool_log_file"
            fi
        fi
        echo "✅" > "$result_file" # Mark success based on tool exit code
    fi

    # 4. Check Case Study Health Post-Tool
    local cs_main_service_status
    cs_main_service_status=$(docker compose -p "$case_study_project_name" -f "${case_study_dir}/docker-compose.yml" ps $case_study  --format '{{if .Health}}{{.Health}}{{else}}{{.State}}{{end}}' 2>/dev/null)
    log "[$test_id] Case study status after tool run: $cs_main_service_status"

    # If the case study service is not 'healthy' or not 'running', it's a critical failure.
    # This overrides any previous status in $result_file (e.g., if the tool reported ✅).
    if ! [[ "$cs_main_service_status" == "healthy" || "$cs_main_service_status" == "running" ]]; then
        log "[$test_id] Case study '$case_study_name' is not healthy/running (Status: $cs_main_service_status). Marking as unhealthy."
        echo "❌ (Case Study Unhealthy after Tool Run)" > "$result_file"
    fi
    
    # 5. Cleanup Case Study
    log "[$test_id] Stopping case study '$case_study_name' for the tool '$tool_name'."
    (cd "$case_study_dir" && docker compose -p "$case_study_project_name" down -v &>/dev/null) || true # The true is to ignore errors if the compose file was not found or the service was already stopped.

    log "[$test_id] Finished test. Result: $(cat "$result_file")"
}
export -f run_single_test log
export CASE_STUDIES_DIR TOOLS_DIR RESULTS_DIR # Export simple and default config variables

# --- Parallel Execution ---
job_pids=() # Array to store PIDs of background jobs
task_counter=0
total_tasks=$((${#SELECTED_TOOLS[@]} * ${#SELECTED_CASE_STUDIES[@]}))

log "Total test combinations to run: $total_tasks"

for tool in "${SELECTED_TOOLS[@]}"; do
    for case_study in "${SELECTED_CASE_STUDIES[@]}"; do
        task_counter=$((task_counter + 1))
        log "Queueing task $task_counter/$total_tasks: Tool '$tool', Case Study '$case_study'"

        if [ ! -d "${CASE_STUDIES_DIR}/${case_study}" ] || [ ! -f "${CASE_STUDIES_DIR}/${case_study}/ENDPOINT" ]; then
            log "ERROR: Case study directory, docker-compose.yml or ENDPOINT file missing for '$case_study'. Skipping."
            echo "❌ (Case Study Not Supported)" > "${TMP_RESULTS_DIR}/${tool}_${case_study}.result"
            continue
        fi

        if [ ! -d "${TOOLS_DIR}/${tool}" ] || [ ! -f "${TOOLS_DIR}/${tool}/docker-compose.yml" ]; then
            log "ERROR: Tool directory or docker-compose.yml missing for '$tool'. Skipping."
            echo "❌ (Tool Not Supported)" > "${TMP_RESULTS_DIR}/${tool}_${case_study}.result"
            continue
        fi

        # Manage parallel jobs
        while (( ${#job_pids[@]} >= MAX_PARALLEL_TESTS )); do
            log "Max parallel jobs ($MAX_PARALLEL_TESTS) reached. Checking for finished jobs..."
            found_finished_job=0
            for i in "${!job_pids[@]}"; do
                pid_to_check="${job_pids[$i]}"
                if ! kill -0 "$pid_to_check" 2>/dev/null; then
                    wait "$pid_to_check"
                    unset 'job_pids[$i]'
                    found_finished_job=1
                    log "Job with PID $pid_to_check finished."
                    break
                fi
            done
            job_pids=("${job_pids[@]}") # Re-index
            if (( found_finished_job == 0 )); then
                sleep 1
            fi
        done

        run_single_test "$tool" "$case_study" "$EXP_NAME" "$TMP_RESULTS_DIR" &
        job_pids+=($!)
        log "Launched job for $tool on $case_study with PID $! Current active jobs: ${#job_pids[@]}"
    done
done

log "All tasks queued. Waiting for remaining ${#job_pids[@]} jobs to complete..."
for pid in "${job_pids[@]}"; do
    wait "$pid"
done
log "All jobs completed."

# --- Print Summary Table ---
log "Experiment Results Summary ($EXP_NAME):"

# Header
printf "| %-20s " "Tool"
for cs in "${SELECTED_CASE_STUDIES[@]}"; do
    printf "| %-20s " "$cs"
done
printf "|\n"

# Separator
printf "|-%-20s-" "--------------------"
for cs in "${SELECTED_CASE_STUDIES[@]}"; do
    printf "|-%-20s-" "--------------------"
done
printf "|\n"

# Rows
for tool in "${SELECTED_TOOLS[@]}"; do
    printf "| %-20s " "$tool"
    for cs in "${SELECTED_CASE_STUDIES[@]}"; do
        result_file_path="${TMP_RESULTS_DIR}/${tool}_${cs}.result"
        result_content="❓"
        if [ -f "$result_file_path" ]; then
            result_content=$(cat "$result_file_path")
            if [ -z "$result_content" ]; then result_content="❓ (Empty)"; fi
        fi
        printf "| %-20s " "$result_content"
    done
    printf "|\n"
done

# Save a CSV version of the results
RESULTS_CSV_FILE="${RESULTS_DIR}/${EXP_NAME}/results.csv"
mkdir -p "$(dirname "$RESULTS_CSV_FILE")"
{
    echo "Tool,${SELECTED_CASE_STUDIES[*]}"
    for tool in "${SELECTED_TOOLS[@]}"; do
        line="$tool"
        for cs in "${SELECTED_CASE_STUDIES[@]}"; do
            result_file_path="${TMP_RESULTS_DIR}/${tool}_${cs}.result"
            if [ -f "$result_file_path" ]; then
                line+=",$(cat "$result_file_path")"
            else
                line+=",❓ (No Result)"
            fi
        done
        echo "$line"
    done
} > "$RESULTS_CSV_FILE"
log "Results saved to $RESULTS_CSV_FILE"

# --- Cleanup Temporary Results Directory ---
rm -rf "$TMP_RESULTS_DIR"

log "Experiment finished. Tool outputs are in $RESULTS_DIR/$EXP_NAME. Summary printed in the file $RESULTS_CSV_FILE."
