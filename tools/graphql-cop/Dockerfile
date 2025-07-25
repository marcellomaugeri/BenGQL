FROM python:3.12-slim

# Install git
RUN apt-get update && apt-get install -y git

# Download the repository
RUN git clone https://github.com/dolevf/graphql-cop.git

# Set the working directory
WORKDIR /graphql-cop

# Install the required Python packages
RUN pip install -r requirements.txt

# Add non root user
RUN useradd -m appuser
USER appuser

# Set the entry point to the Python script so arguments can be passed
ENTRYPOINT ["python", "graphql-cop.py"]