FROM node:20

WORKDIR /app

RUN corepack enable && corepack prepare yarn@stable --activate

RUN yarn create redwood-app my-redwood-project --no-git --force  --typescript -y

WORKDIR /app/my-redwood-project

RUN yarn install

EXPOSE 8910

CMD ["yarn", "redwood", "dev"]
