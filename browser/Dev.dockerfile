FROM node:18.7.0
LABEL maintainer="Midnight Riders <info@midnightriders.com>"

WORKDIR /tmp
COPY package.json package-lock.json ./
RUN npm install

WORKDIR /app
RUN cp -r /tmp/node_modules /app
