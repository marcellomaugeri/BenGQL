FROM python:3.10-slim-bullseye

# Install git
RUN apt-get update && apt-get install -y git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/Escape-Technologies/ClairvoyanceNext.git
WORKDIR /ClairvoyanceNext
RUN git checkout 8b101f041300b52383b086ee4830764b71c9559d

# Install dependencies
RUN pip install poetry
RUN poetry install

# Download the wordlists
RUN git clone https://github.com/Escape-Technologies/graphql-wordlist.git wordlists

# Entrypoint
ENTRYPOINT [ "poetry", "run", "python", "-m", "clairvoyance" ]
CMD [ "--help" ]