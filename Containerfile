FROM ruby:3.2.2

RUN gem install rails bundler

RUN bundle install

COPY main.rb /opt/app

CMD ["ruby", "main.rb"]