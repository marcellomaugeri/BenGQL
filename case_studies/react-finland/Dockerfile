FROM node:21-alpine

ENV NODE_ENV=development

# Install dependencies
RUN apk add git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/ReactFinland/graphql-api.git
WORKDIR /graphql-api
RUN git checkout 336da31f9f297bd9dbc20991a4caaa8c94723e6e

#Build the application
RUN npm install
RUN npm run build