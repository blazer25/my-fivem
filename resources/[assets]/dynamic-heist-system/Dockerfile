# Dockerfile for Dynamic Heist System

FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y lua5.3

WORKDIR /app

COPY . /app

CMD [ "lua", "server/main.lua" ]
