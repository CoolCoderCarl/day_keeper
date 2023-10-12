# frozen_string_literal: true

require 'uri'
require 'json'
require 'logger'
require 'net/http'
require 'telegram/bot' # https://github.com/atipugin/telegram-bot-ruby

logger = Logger.new('/proc/1/fd/1')
logger.level = Logger::INFO
logger.info('Starting...')

# url = URI("https://date.nager.at/api/v3/PublicHolidays/2023/ES")

logger.info('Set variables...')
URL = 'https://date.nager.at/api/v3'

FIRST_D = 1
FIRST_M = 1
send_mode = 'default'

def RequestToAPI(endpoint, mode)
  url = URI("#{URL}#{endpoint}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request['accept'] = 'application/json'

  response = http.request(request)
  case response
  when Net::HTTPNoContent
    'No Content'
  when Net::HTTPUnauthorized
    'Unauthorized'
  when Net::HTTPServerError
    'HTTPServerError'
  when Net::HTTPOK
    return 'Today is a public Holiday' if mode == 'default'
    JSON.parse(response.read_body)
  else
    JSON.parse(response.read_body)
  end
end

# puts RequestToAPI("/LongWeekend/#{year}/ES")

# DATA = RequestToAPI("/PublicHolidays/#{year}/ES")

# puts RequestToAPI("/NextPublicHolidaysWorldwide")

TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_BOT_TOKEN']
# TELEGRAM_API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/sendMessage"
TELEGRAM_CHAT_ID = ENV['TELEGRAM_CHAT_ID']

def report_to_telegram(endpoint, mode)
  result = RequestToAPI(endpoint, mode)
  # logger.info("Send to telegram...") #  main.rb:49:in `report_to_telegram': undefined local variable or method `logger' for main:Object (NameError)
  sleep(1)
  case mode
  when 'year'
    begin
      Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
        for data in result
          bot.api.send_message(chat_id: TELEGRAM_CHAT_ID,
                               text: "Date: #{data['date']}
                                    \n Local Name: #{data['localName']}
                                    \n Fixed: #{data['fixed']}
                                    \n Global: #{data['global']}
                                    \n Types: #{data['types'][0..]}")
        end
      end
    rescue StandardError => e
      # logger.error('Err while sending to telegramm')
      puts "Err while sending to telegramm - #{e.class}: #{e.message}"
    end
  when 'month'
    begin
      Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
        for data in result
          bot.api.send_message(chat_id: TELEGRAM_CHAT_ID,
                               text: "Date: #{data['date']}
                                    \n Local Name: #{data['localName']}
                                    \n Fixed: #{data['fixed']}
                                    \n Global: #{data['global']}
                                    \n Types: #{data['types'][0..]}")
        end
      end
    rescue StandardError => e
      # logger.error('Err while sending to telegramm')
      puts "Err while sending to telegramm - #{e.class}: #{e.message}"
    end
  when 'default'
    begin
      Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
        bot.api.send_message(chat_id: TELEGRAM_CHAT_ID,
                             text: result)
      end
    rescue StandardError => e
      # logger.error('Err while sending to telegramm')
      puts "Err while sending to telegramm - #{e.class}: #{e.message}"
    end
  end
end

# Main
loop do
  year = Time.now.year
  case Time.new.strftime('%H:%M')
  # Send when new year
  when '08:00'
    send_mode = 'year'
    if (Time.now.day == FIRST_D) && (Time.now.month == FIRST_M)
      report_to_telegram("/PublicHolidays/#{year}/ES", mode = send_mode)
      sleep(70)
    end
  when '09:00'
    send_mode = 'month'
    if Time.now.day == FIRST_D # TODO: remove sending all other monthes only the current one # puts RequestToAPI('/NextPublicHolidays/ES')[0]["date"].split("-")[1]
      report_to_telegram('/NextPublicHolidays/ES', mode = send_mode)
      sleep(70)
    end
  when '10:00'
    report_to_telegram('/IsTodayPublicHoliday/ES', mode = send_mode)
    sleep(70)
  end
end
