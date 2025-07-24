import os
import sys
import yaml

def validate_port_mapping(mapping):
    """
    Validates that a port mapping is not fixed to a specific host port.
    - ":8080" (valid)
    - "8080:8080" (invalid)
    """
    if not isinstance(mapping, str):
        return False # TODO: add support for list of mappings in the future
    parts = mapping.split(':')
    if len(parts) > 1 and parts[-2]:
        return False
    return True

def main(case_studies_root):
    errors_found = False
    
    case_study_dirs = sorted([d.path for d in os.scandir(case_studies_root) if d.is_dir() and not d.name.startswith('.')])

    for case_study_dir in case_study_dirs:
        case_study_name = os.path.basename(case_study_dir)
        print(f"--- Validating: {case_study_name} ---")

        # 1. Check for non-empty ENDPOINT file
        endpoint_path = os.path.join(case_study_dir, 'ENDPOINT')
        if not os.path.exists(endpoint_path):
            print(f"❌ ERROR: 'ENDPOINT' file is missing.")
            errors_found = True
        elif os.path.getsize(endpoint_path) == 0:
            print(f"❌ ERROR: 'ENDPOINT' file is empty.")
            errors_found = True

        # 2. Check for docker-compose.yml and parse it
        compose_path = os.path.join(case_study_dir, 'docker-compose.yml')
        if not os.path.exists(compose_path):
            print(f"❌ ERROR: 'docker-compose.yml' file is missing.")
            errors_found = True
            continue # Skip other checks for this case study

        try:
            with open(compose_path, 'r') as f:
                compose_data = yaml.safe_load(f)
            if not compose_data or 'services' not in compose_data:
                 print(f"❌ ERROR: 'docker-compose.yml' is invalid or has no 'services' section.")
                 errors_found = True
                 continue
        except yaml.YAMLError as e:
            print(f"❌ ERROR: Could not parse 'docker-compose.yml': {e}")
            errors_found = True
            continue

        services = compose_data.get('services', {})
        main_service_config = services.get(case_study_name)
        total_port_mappings = 0

        # 3. Check healthcheck on the main service
        if not main_service_config:
            print(f"❌ ERROR: Main service '{case_study_name}' not found in docker-compose.yml.")
            errors_found = True
        elif 'healthcheck' not in main_service_config:
            print(f"❌ ERROR: Main service '{case_study_name}' is missing a 'healthcheck'.")
            errors_found = True

        # 4. Check platform and port rules for all services
        for service_name, config in services.items():
            # Platform check
            if config.get('platform') != 'linux/amd64':
                print(f"❌ ERROR: Service '{service_name}' is missing 'platform: linux/amd64'.")
                errors_found = True
            
            # Port check
            if 'ports' in config:
                if service_name != case_study_name:
                    print(f"❌ ERROR: Service '{service_name}' has a port mapping, but only the main service is allowed to.")
                    errors_found = True
                
                port_mappings = config['ports']
                total_port_mappings += len(port_mappings)

                for port in port_mappings:
                    if not validate_port_mapping(port):
                        print(f"❌ ERROR: Service '{service_name}' has a fixed host port '{port}'. Only dynamic ports are allowed.")
                        errors_found = True

        # 5. Check total port mapping count
        if total_port_mappings != 1:
            print(f"❌ ERROR: Found {total_port_mappings} port mappings. Exactly one is required (on the main service).")
            errors_found = True
            
    if errors_found:
        print("\nValidation failed.")
        sys.exit(1)
    else:
        print("\nAll case studies validated successfully.")

if __name__ == "__main__":
    main("./case_studies")