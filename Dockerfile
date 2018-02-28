FROM ezcater-production.jfrog.io/ruby:9443b94540

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' >> /etc/apt/sources.list.d/postgresql.list
RUN wget --no-check-certificate -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add -
RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential postgresql-client-9.6

RUN mkdir /usr/src/myapp
WORKDIR /usr/src/myapp

COPY Gemfile /usr/src/myapp
COPY Gemfile.lock /usr/src/myapp
RUN bundle install

ADD . /usr/src/myapp

CMD rails server -p $PORT -b 0.0.0.0
