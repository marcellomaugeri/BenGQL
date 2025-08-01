FROM node:12-alpine

#ENV NODE_ENV=development

# Install dependencies
RUN apk add git curl

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/Franqsanz/fruits-api.git
WORKDIR /fruits-api
RUN git checkout 5e50f478237b80a11f723447250ae21b4a8568b9

#Build the application
RUN npm i 
