FROM python:3.12.10-alpine3.21

# Install git
RUN apk add --no-cache git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/nikitastupin/clairvoyance.git
WORKDIR /clairvoyance
RUN git checkout 227f4c5428c18f14021a414bbaa3b203f242131b

# Install dependencies
RUN pip install poetry
RUN poetry install

# Download the wordlists
RUN git clone https://github.com/Escape-Technologies/graphql-wordlist.git wordlists

# Entrypoint
ENTRYPOINT [ "poetry", "run", "python", "-m", "clairvoyance" ]
CMD [ "--help" ]