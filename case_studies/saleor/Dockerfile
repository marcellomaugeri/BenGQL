FROM python:3.12-slim


RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y libmagic-dev && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y libmagic-dev
RUN git clone https://github.com/saleor/saleor.git




WORKDIR /saleor
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python3 -

#EXPOSE 8000
RUN poetry install --no-root --no-interaction --no-ansi
