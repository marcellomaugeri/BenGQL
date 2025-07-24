---
name: Add new case study
about: Use this template to add a new case study to the benchmark.
title: 'feat: Add new case study <case_study_name>'
labels: 'enhancement'
---

**Case study name**
A clear and concise name for the new case study.

**Case study repository URL**
The URL of the repository for the case study.

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

**Additional context**
Add any other context or screenshots about the feature request here.
