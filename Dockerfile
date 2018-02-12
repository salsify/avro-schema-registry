# To build run: docker build -t avro-schema-registry .

FROM ruby:2.4.2

RUN mkdir /app
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler --no-document && bundle install --jobs 20 --retry 5

COPY . /app

ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV PORT=5000

EXPOSE 5000

# Start puma
CMD bundle exec puma -C config/puma.rb
