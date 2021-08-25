FROM ezcater-production.jfrog.io/ruby:2.6.8-pg12

COPY Gemfile Gemfile.lock /usr/src/app/

ARG BUNDLE_EZCATER__JFROG__IO

RUN gem install bundler -v 2.2.26

RUN bundle config set --local without 'test development' && bundle install

ADD . /usr/src/app

EXPOSE 3000
CMD rails server -p 3000 -b 0.0.0.0
