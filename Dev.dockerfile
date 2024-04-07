FROM node:20.12-alpine AS node
FROM ruby:3.1.3-alpine
LABEL maintainer="Midnight Riders<webczar@midnightriders.com>"

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

WORKDIR /tmp

# Install system-level dependencies

COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
  ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
  ln -s /usr/local/lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack

RUN apk update
RUN apk add --no-cache --virtual \
    build-dependencies \
    build-base \
    chromium \
    chromium-chromedriver \
    gcompat \
    yaml-dev \
    postgresql-dev \
    ruby-nokogiri \
    tzdata \
    build-base \
    imagemagick \
    imagemagick-c++ \
    imagemagick-dev \
    imagemagick-libs && \
  rm -rf /var/cache/apk/*

WORKDIR /tmp
RUN gem install debase-ruby_core_source
COPY Gemfile Gemfile.lock /tmp/
RUN gem install foreman && \
  bundle install --without=local
RUN apk del build-base

WORKDIR /usr/src/member-portal

COPY package.json package-lock.json ./
RUN npm install && \
  npm cache clean --force
