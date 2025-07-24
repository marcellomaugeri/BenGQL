# Dockerfile
FROM directus/directus:latest

# if the base image is Alpine-based
USER root
RUN apk add --no-cache curl

# (If it turns out to be Debian/Ubuntu-based,
# replace the above with:
#   RUN apt-get update \
#    && apt-get install -y curl \
#    && rm -rf /var/lib/apt/lists/*
# )

# switch back to the non-root user (optional; Directus default)
#USER directus
