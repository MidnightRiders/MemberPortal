FROM ruby:3.1.3-alpine
LABEL maintainer="Midnight Riders<webczar@midnightriders.com>"

WORKDIR /tmp
COPY .node-version .
RUN apk update
RUN apk add --no-cache --virtual \
    build-dependencies \
    build-base \
    chromium \
    chromium-chromedriver \
    gcompat \
    yaml-dev \
    nodejs="$(head -1 .node-version)-r0" \
    npm \
    postgresql-dev \
    ruby-nokogiri \
    tzdata \
    build-base \
    imagemagick \
    imagemagick-c++ \
    imagemagick-dev \
    imagemagick-libs && \
  rm -rf /var/cache/apk/* && \
  npm i -g corepack && \
    corepack enable

WORKDIR /tmp
RUN gem install debase-ruby_core_source
COPY Gemfile Gemfile.lock /tmp/
RUN gem install foreman && \
  bundle install
RUN apk del build-base

WORKDIR /usr/src/member-portal

COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean
