FROM ruby:3.1.2-alpine
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
  nodejs-current=$(head -1 .node-version)-r0 \
  postgresql-dev \
  ruby-nokogiri \
  tzdata \
  build-base \
  imagemagick6 \
  imagemagick6-c++ \
  imagemagick6-dev \
  imagemagick6-libs && \
  rm -rf /var/cache/apk/*

RUN corepack enable

WORKDIR /tmp
COPY Gemfile Gemfile.lock /tmp/
RUN gem install foreman && \
  bundle install
RUN apk del build-base

WORKDIR /usr/src/member-portal

COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean
