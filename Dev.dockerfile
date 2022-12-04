FROM ruby:3.1.2-alpine
LABEL maintainer="Midnight Riders<webczar@midnightriders.com>"

RUN apk update
RUN apk add --no-cache --virtual \
  build-dependencies \
  build-base \
  gcompat \
  nodejs \
  postgresql-dev \
  ruby-nokogiri \
  tzdata \
  build-base \
  imagemagick6 \
  imagemagick6-c++ \
  imagemagick6-dev \
  imagemagick6-libs && \
  rm -rf /var/cache/apk/*

WORKDIR /tmp
COPY Gemfile Gemfile.lock /tmp/
RUN bundle install
RUN apk del build-base

WORKDIR /usr/src/member-portal
COPY . /usr/src/member-portal
