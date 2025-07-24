FROM node:18

RUN apt-get update && apt-get install -y git build-essential python3

# Install Gatsby CLI globally
RUN npm install -g gatsby-cli@5.14.0

# Download the starter with Git (https://github.com/gatsbyjs/gatsby-starter-default.git) and checkout the specific version (68539c6017d9f179c84b83e6596c557211c2364a)
RUN git clone --no-checkout --depth 1 https://github.com/gatsbyjs/gatsby-starter-default.git && \
    cd gatsby-starter-default && \
    git fetch --depth 1 origin 68539c6017d9f179c84b83e6596c557211c2364a && \
    git checkout 68539c6017d9f179c84b83e6596c557211c2364a

# Create a new Gatsby project.
RUN gatsby new my-gatsby-site ./gatsby-starter-default

# Change working directory into the newly created project
WORKDIR /my-gatsby-site

# Install dependencies for the new project
RUN npm install

# Build the gatsby application, setting NODE_OPTIONS for more memory
RUN gatsby build

# Expose the port the app runs on.
EXPOSE 9000

# Command to run the app.
CMD ["gatsby", "serve", "--host", "0.0.0.0", "--port", "9000"]