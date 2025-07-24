FROM node:18-alpine

RUN npm install -g pnpm

RUN apk add --update git curl

RUN npm install -g pnpm

RUN git clone https://github.com/heyverse/hey.git

WORKDIR /hey

RUN git checkout 439d4dd0d7f5ed028fbd0f18b9ede10b6e5578d2

ENV VITE_IS_PRODUCTION = true
ENV NODE_ENV = production
ENV NEXT_PUBLIC_LENS_NETWORK = mainnet
ENV OPENAI_API_KEY=""
ENV ENABLE_AI_FEATURES=false

RUN pnpm install

RUN pnpm build
