# Adding a New Case Study
Each case study must have its own folder inside the ```case_studies``` directory.
The folder name will be considered the case study name.
The folder usually contains: 

- ```docker-compose.yml``` - The docker-compose file to run the case study (required).
- ```ENDPOINT``` - The GraphQL endpoint of the service (required).
- ```Dockerfile``` - The Dockerfile to build the case study (optional, if the case study requires a custom Docker image).
- ```auth.sh``` - A script to retrieve the authentication token for the service (optional, only if the case study requires authentication).
- ```schema.graphql``` - The GraphQL schema of the service (optional, usually retrieved with the `rover` tool).

## Dockerfile
The Dockerfile includes the instructions to build the case study.
The Dockerfile should be named ```Dockerfile``` and should be located in the root of the case study folder.
An example Dockerfile is shown below, look at the other case studies for more examples.

### Example Dockerfile
```dockerfile
FROM FROM python:3.12-alpine

# Install dependencies
RUN apk add --update git

# Clone the repo and checkout the specific commit
RUN git clone /<case_study_repo>.git 
WORKDIR /<case_study_repo>
RUN git checkout <commit_hash>

# Install the project dependencies
RUN pip install -r requirements.txt
```

### Guidelines
- Use a lightweight base image (e.g. python3.12-alpine for Python projects or node:18-slim for Node.js projects).
- Use the ```git checkout``` command to check out a specific commit to ensure reproducibility.

### Checklist
- [ ] The `case_study_name` is unique and descriptive (Usually reflects the project name).
- [ ] The `docker-compose.yml` file is correctly configured to build the Docker image from the `Dockerfile` or pull an existing image.
- [ ] The version of the project is fixed to a specific commit (git checkout in the `Dockerfile`) or tag to ensure reproducibility.
- [ ] All services in `docker-compose.yml` are fixed to platform `linux/amd64` to ensure compatibility with the testing environment (Works on both Intel and Apple Silicon Macs).
- [ ] The `Dockerfile` uses a lightweight base image (e.g., `python:3.12-alpine` for Python projects or `node:18-slim` for Node.js projects).
- [ ] The `docker-compose.yml` file defines a healthcheck for the service which checks for the GraphQL endpoint to be running, not the overall service, as we are interested in the GraphQL API availability.
- [ ] The `docker-compose.yml` file does not specify a host port, allowing the case study to run on any port, enabling parallel experiment execution.
- [ ] The `docker-compose.yml` file uses the `<case_study_name>` as the image name and service name.
- [ ] The `docker-compose.yml` file is placed in the root of the case study folder.
- [ ] The `Dockerfile`, when present, is placed in the root of the case study folder.
- [ ] The `docker-compose.yml` file is named exactly as `docker-compose.yml`.
- [ ] The `Dockerfile` is named exactly as `Dockerfile`.
- [ ] The case study folder is placed inside the `case_studies` directory.
- [ ] The case study folder is named exactly as `<case_study_name>`.
- [ ] The case study is added to the `README.md`
- [ ] The `ENDPOINT` variable in the `docker-compose.yml` file is set to the correct GraphQL endpoint of the service.
- [ ] The `auth.sh` script (required only when the case study requires authentication) is executable and returns the correct authentication token for the service.