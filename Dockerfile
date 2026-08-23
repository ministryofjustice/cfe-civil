# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=4.0.6

FROM ruby:$RUBY_VERSION-alpine3.24 AS base
# Chose alpine for the lower image size (lower attack surface and start-up speed):
# ruby:3.2.2-alpine3.18 is 80MB
# ruby:3.2.2-slim is 205MB (debian-based)

#
# Throw-away build stage to reduce size of final image
#
FROM base AS build

ENV RAILS_ENV=production

RUN set -ex

# Install packages needed to build gems
RUN apk --no-cache add build-base  \
                       yaml-dev \
                       postgresql-dev

# Install application gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY .ruby-version .ruby-version
RUN gem update --system
RUN bundle config --local without test:development && \
    bundle install && \
    # remove gem cache
    rm -rf /usr/local/bundle/cache && \
    # fix permissions for security - the 'os' gem was found to be world writable
    chmod -R o-w /usr/local/bundle

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apk --no-cache add postgresql-client

COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY . /myapp

WORKDIR /myapp

# Run and own only the runtime files as a non-root user for security
RUN adduser --disabled-password rails -u 1001 && \
    chown -R rails:rails /myapp
# (Numeric user needs to be used to show that it's non-root)
USER 1001

# set ping environment variables
ARG APP_BUILD_DATE
ENV APP_BUILD_DATE=${APP_BUILD_DATE}
ARG APP_BUILD_TAG
ENV APP_BUILD_TAG=${APP_BUILD_TAG}
ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}
ARG APP_BRANCH
ENV APP_BRANCH=${APP_BRANCH}

# allow public files to be served
ENV RAILS_SERVE_STATIC_FILES=true

# Rails entrypoint (can be overwritten at runtime)
CMD ["docker/run"]
EXPOSE 3000
