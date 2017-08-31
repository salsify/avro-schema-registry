FROM ruby:2.3.3
# https://docs.docker.com/compose/rails/#connect-the-database
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs telnet
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
#CMD ["bundle exec rails s -p 21000 -b '0.0.0.0'"]