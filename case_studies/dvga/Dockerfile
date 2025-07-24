FROM python:3.8-alpine

# Install dependencies
RUN apk add --update curl git

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application dvga
WORKDIR /dvga
RUN git checkout 124b436e3c98de4d8c4de3838b52a409bbe5fb27

# Build the application
RUN pip3 install -r requirements.txt --user --no-warn-script-location
RUN python setup.py