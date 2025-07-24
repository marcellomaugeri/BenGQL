FROM node:22-alpine

# Install dependencies including OpenSSL for Prisma
RUN apk add --no-cache git python3 make g++ openssl-dev openssl curl \
    && npm install -g npm@9

WORKDIR /workspace

# Clone the repo and bootstrap
RUN git clone --depth 1 https://github.com/amplication/amplication.git .

# Ensure package-lock.json exists
RUN if [ ! -f package-lock.json ]; then npm install --package-lock-only; fi

# Install dependencies and setup
RUN npm ci
RUN npm run setup:dev

# Generate Prisma client
RUN npx nx run amplication-prisma-db:db:prisma:generate

# Expose GraphQL port
#EXPOSE 3001

# Set environment variables
#ENV NODE_ENV=development
#ENV PORT=9000

# Run the server in development mode
CMD ["npx", "nx", "serve", "amplication-server", "--port=3001", "--host=0.0.0.0"]
