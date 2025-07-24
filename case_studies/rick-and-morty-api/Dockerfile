FROM node:12-alpine

#ENV NODE_ENV=development

# Install dependencies
RUN apk add git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/afuh/rick-and-morty-api.git
WORKDIR /rick-and-morty-api
RUN git checkout ca9118a9da49e69c6387357e0f02163f53a79be4

#Build the application
RUN npm i --only=prod
# add --only=prod to install only production dependencies