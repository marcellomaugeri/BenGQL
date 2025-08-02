FROM node:22-alpine

# Install dependencies 
RUN apk add --no-cache git curl

# Clone the repo
RUN git clone https://github.com/payloadcms/payload
WORKDIR /payload
RUN git checkout 1b31c74d32b98b75306512728563241141ff0a16
# Copy just the templates/website directory
#RUN mv /payload/templates/website/ /payload-example
#RUN rm -rf /payload
WORKDIR /payload/templates/website/
# Install dependencies and setup
RUN npm install -g pnpm
RUN pnpm install

# Run the server in development mode
CMD ["pnpm", "dev"]