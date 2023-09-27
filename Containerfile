FROM ruby:3.2.2

RUN gem install rails bundler

WORKDIR /opt/app

RUN gem install telegram-bot-ruby -v 1.0.0

COPY main.rb /opt/app

CMD ["ruby", "main.rb"]
