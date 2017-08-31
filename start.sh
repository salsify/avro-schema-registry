#!/bin/bash

bundle exec rails s -p 21000 -b '0.0.0.0';
rake db:setup;

