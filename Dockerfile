FROM debian:sid-slim

ENTRYPOINT ["bash"]

RUN useradd -mUs /usr/bin/bash -u 1000 user || true && \
    mkdir -p /ebook-tools || true && \
    chown user:user /ebook-tools || true && \
    mkdir -p /organized-books || true && \
    chown user:user /organized-books || true && \
    mkdir -p /unorganized-books || true && \
    chown user:user /unorganized-books || true && \
    mkdir -p /corrupt-books || true && \
    chown user:user /corrupt-books || true && \
    mkdir -p /uncertain-books || true && \
    chown user:user /uncertain-books || true && \
    mkdir -p /pamphlets || true && \
    chown user:user /pamphlets || true

# Set environment variables
ENV LANG="en_US.UTF-8" PATH="${PATH}:/ebook-tools"

# Set the working directory
WORKDIR /ebook-tools