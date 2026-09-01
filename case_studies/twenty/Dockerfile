FROM node:24.19.0-alpine3.23

RUN apk add --no-cache curl git


RUN git clone --no-checkout --depth 1 https://github.com/twentyhq/twenty.git && \
    cd twenty && \
    git fetch --depth 1 origin 17cf55103bc1b97d0548b5eeccd6bcc5c13dccc0 && \
    git checkout 17cf55103bc1b97d0548b5eeccd6bcc5c13dccc0

WORKDIR /twenty

RUN yarn
ENV THREADS_WORKER_INIT_TIMEOUT=60000
RUN npx nx run twenty-server:lingui:extract && \
    npx nx run twenty-server:lingui:compile && \
    npx nx run twenty-emails:lingui:extract && \
    npx nx run twenty-emails:lingui:compile && \
    npx nx run twenty-server:build

CMD ["sh", "-c", "cd packages/twenty-server && yarn database:init:prod && exec yarn start:prod"]
