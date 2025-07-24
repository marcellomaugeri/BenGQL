FROM node:18

# Install dependencies
RUN apt update && apt install -y python3-venv python3-pip build-essential git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/trevorblades/countries.git
WORKDIR /countries
RUN git checkout bba0d75181a7e2b454532a8f69a9cf245afaac0b
# Add the line send_metrics = false in `wrangler.toml`
RUN echo "send_metrics = false" >> wrangler.toml

# Build the application
RUN yarn

CMD ["yarn", "start"]