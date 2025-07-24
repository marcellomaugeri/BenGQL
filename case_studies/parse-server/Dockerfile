# Dockerfile.parse
FROM parseplatform/parse-server:latest

# Escalate to root so we can install packages
USER root

# If this image is Alpine-based (most official Node images are),
# use apk. Otherwise, swap to apt-get here.
RUN if [ -f /etc/alpine-release ]; then \
      apk add --no-cache curl; \
    else \
      apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*; \
    fi

# Drop back to the unprivileged user that runs Parse Server
#USER node
