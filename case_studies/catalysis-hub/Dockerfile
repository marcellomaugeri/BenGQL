FROM python:3.10.15-slim

# Install git and curl
RUN apt-get update && \
    apt-get install -y git libpq-dev curl build-essential && \
    rm -rf /var/lib/apt/lists/*

# Clone the repo and checkout the specific commit
RUN git clone https://github.com/SUNCAT-Center/CatalysisHubBackend.git
WORKDIR /CatalysisHubBackend
RUN git checkout 5d46106d28fd80049e925db082cdabdfc48e5e05

# Install Python dependencies
RUN pip install -r requirements_no_deps.txt --no-deps

# Fix the db host in the main.py file
RUN sed -i 's/localhost/postgres/' app.py

CMD [ "gunicorn", "app:app", "--preload", "--threads", "3", "--bind", "0.0.0.0:8000" ]