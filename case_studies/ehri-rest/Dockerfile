# Builder
FROM maven:3.9.10-eclipse-temurin-8-alpine AS builder

RUN apk add --no-cache git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/EHRI/ehri-rest.git
WORKDIR /ehri-rest
RUN git checkout af2870f3ba3212255daf08da5d8f780b869eaf94

# Build the application
RUN mvn clean package -DskipTests

# Docker file for EHRI backend web service
FROM neo4j:3.5.28

LABEL git_commit=af2870f3ba3212255daf08da5d8f780b869eaf94

#Switch to root to allow package installs
USER root

# 3. Update package lists and install curl
RUN echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99insecure && \
    echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99insecure && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
# Revert back to the neo4j user
USER neo4j

ENV NEO4J_dbms_connector_http_enabled=true
ENV dbms.connector.http.listen_address=:7474

# Set Neo4j configuration
ENV NEO4J_HOME=/var/lib/neo4j
ENV NEO4J_AUTH=none
ENV NEO4J_dbms_unmanagedExtensionClasses=eu.ehri.project.ws=/ehri

# Copy the output of mvn package to the Neo4j plugin folder...
COPY --from=builder /ehri-rest/build/target/ehri-data*.jar plugins

# Initialise the database on container start...
COPY --from=builder /ehri-rest/scripts/lib.sh /ehri-rest/scripts/cmd /ehri-rest/scripts/initdb.sh $NEO4J_HOME/scripts/
ENV EXTENSION_SCRIPT=$NEO4J_HOME/scripts/initdb.sh