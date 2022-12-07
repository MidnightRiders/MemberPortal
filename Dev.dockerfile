FROM ruby:3.1.2
LABEL maintainer="Midnight Riders<webczar@midnightriders.com>"

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    chromium \
    chromium-chromedriver \
    nodejs \
    postgresql-dev && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
COPY Gemfile Gemfile.lock /tmp/
RUN bundle install

WORKDIR /usr/src/member-portal
COPY . /usr/src/member-portal
