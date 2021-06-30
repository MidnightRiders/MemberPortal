FROM ruby:2.6.6-alpine
LABEL maintainer "Midnight Riders<webczar@midnightriders.com>"

RUN apk update
RUN apk add --no-cache --virtual build-dependencies \
  build-base \
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
RUN gem install bundler --version 1.17.3
COPY Gemfile Gemfile.lock /tmp/
ENV BUNDLE_PATH /bundler-cache
RUN bundle check || bundle install
RUN apk del build-base

WORKDIR /usr/src/member-portal
COPY . /usr/src/member-portal
