FROM ezcater-production.jfrog.io/ruby:2.7.4-d11s-pg12

COPY Gemfile Gemfile.lock /usr/src/app/

ARG BUNDLE_EZCATER__JFROG__IO

RUN apt-get update && apt-get upgrade -y
RUN gem install bundler -v 2.2.26

RUN bundle config set --local without 'test development' && bundle install

ADD . /usr/src/app

EXPOSE 3000
CMD rails server -p 3000 -b 0.0.0.0
