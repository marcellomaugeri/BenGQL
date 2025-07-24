FROM base_image

# Install nodejs
RUN apt-get install -y nodejs npm curl wget

FROM node:14.21.3

# Clone the repo and install dependencies
RUN git clone https://github.com/react-shop/react-ecommerce.git
WORKDIR /react-ecommerce
RUN git checkout bc0f268e6d38806910e6d1c198460a0c3fdd81d1

# Install dependencies
RUN yarn
WORKDIR /react-ecommerce/packages/server
#RUN npm install

# Run the server
#CMD ["yarn", "start"]
