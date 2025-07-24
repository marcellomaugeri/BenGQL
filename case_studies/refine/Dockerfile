FROM node:22-alpine

RUN apk add --update git

RUN git clone --depth=1 https://github.com/refinedev/refine.git
WORKDIR /refine
RUN git checkout 124618dd3f3ef04b61aa59633fd5ec7d6554feb1