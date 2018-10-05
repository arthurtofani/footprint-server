FROM ruby:2.5.1-alpine
# ...
RUN apk add --update \
  build-base \
  bash \
  libc6-compat \
  libxml2-dev \
  libxslt-dev \
  less \
  taglib-dev \
  tzdata \
  postgresql-dev \
  && rm -rf /var/cache/apk/*

# Use libxml2, libxslt a packages from alpine for building nokogiri
RUN bundle config build.nokogiri --use-system-libraries
RUN export PAGER=more
