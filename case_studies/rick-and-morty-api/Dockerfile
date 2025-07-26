FROM node:12-alpine

#ENV NODE_ENV=development

# Install dependencies
RUN apk add git mongodb-tools curl

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/afuh/rick-and-morty-api.git
WORKDIR /rick-and-morty-api
RUN git checkout ca9118a9da49e69c6387357e0f02163f53a79be4

# Change the "localhost" to "mongo" in the package.json
RUN sed -i 's/localhost/mongo/g' package.json

# Change also mongodb://localhost to mongodb://mongo in server.js
RUN sed -i 's/mongodb:\/\/localhost/mongodb:\/\/mongo/g' server.js

#Build the application
RUN npm i --only=prod
# add --only=prod to install only production dependencies