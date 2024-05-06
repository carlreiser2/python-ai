ARG WORK_DIR="/code"

# ubuntu:18.04
FROM python:3.12-slim as base

COPY . .

# Install libpq-dev
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libpq-dev python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt

ENTRYPOINT [ "jupyter", "lab", "--ip", "0.0.0.0", "--port", "8888" ]
