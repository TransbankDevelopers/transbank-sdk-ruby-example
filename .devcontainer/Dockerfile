FROM mcr.microsoft.com/devcontainers/ruby:3-3.4-trixie

USER root

RUN apt update \
    && apt-get install -y --no-install-recommends ripgrep \
    && rm -rf /var/lib/apt/lists/*

USER vscode
