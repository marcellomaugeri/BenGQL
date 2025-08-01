FROM python:3.12-slim

# Install git
RUN apt-get update && apt-get install -y git

# Download the repository
RUN git clone git clone https://github.com/dolevf/graphw00f.git

# Set the working directory
WORKDIR /graphw00f


# Install the required Python packages
RUN pip install requests

# Set the entry point to the Python script so arguments can be passed
ENTRYPOINT ["python", "main.py"]