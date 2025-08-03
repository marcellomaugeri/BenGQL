FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y git libmagic-dev  build-essential libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/saleor/saleor.git
WORKDIR /saleor
RUN git checkout bdb2f9d05d339fb0f07d9aa6946c60284b08a836

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:$PATH"

RUN curl -sSL https://install.python-poetry.org | python3 -

RUN poetry install --no-root --no-interaction --no-ansi