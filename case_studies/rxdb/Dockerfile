FROM node:18-alpine

RUN apk add --no-cache curl git

RUN git clone --depth=1 --branch 15.0.0 https://github.com/pubkey/rxdb.git /rxdb
WORKDIR /rxdb/examples/graphql

RUN npm pkg set dependencies.rxdb=15.0.0 && \
    npm pkg delete scripts.preinstall && \
    npm install --legacy-peer-deps

EXPOSE 10102

CMD ["npm", "run", "server"]
