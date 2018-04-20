# To build run: docker build -t avro-schema-registry .

FROM ruby:2.4.2

RUN mkdir /app
WORKDIR /app

RUN apt-get update && apt-get install -y wget

# install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler --no-document && bundle install --jobs 20 --retry 5

COPY . /app

# Run the app as a non-root user. The source code will be read-only,
# but the process will complain if it can't write to tmp or log (even
# though we're writing the logs to STDOUT).
RUN mkdir /app/tmp /app/log
RUN groupadd --system avro && \
    useradd --no-log-init --system --create-home --gid avro avro && \
    chown -R avro:avro /app/tmp /app/log
USER avro

ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV PORT=5000

EXPOSE $PORT

# Start puma
CMD bin/docker_start
