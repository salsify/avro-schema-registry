FROM ezcater-production.jfrog.io/ruby:2a0246f11f

COPY Gemfile Gemfile.lock /usr/src/app/

ARG BUNDLE_EZCATER__JFROG__IO

RUN bundle install

ADD . /usr/src/app

EXPOSE 3000
CMD rails server -p 3000 -b 0.0.0.0
