FROM node:22-alpine

RUN apk add --no-cache git


RUN git clone --depth 1 https://github.com/twentyhq/twenty.git

WORKDIR /twenty
RUN cp ./packages/twenty-server/.env.example ./packages/twenty-server/.env

RUN yarn
RUN npx nx database:reset twenty-server

CMD ["sh", "-c", "npx nx start twenty-server && npx nx worker twenty-server"]
