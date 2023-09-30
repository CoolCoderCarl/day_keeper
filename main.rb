require 'uri'
require 'json'
require 'logger'
require 'net/http'
require 'telegram/bot' # https://github.com/atipugin/telegram-bot-ruby

logger = Logger.new('/proc/1/fd/1')
logger.level = Logger::INFO
logger.info("Starting...")

# url = URI("https://date.nager.at/api/v3/PublicHolidays/2023/ES")

logger.info("Set variables...")
URL = "https://date.nager.at/api/v3"

FIRST_D, FIRST_M = "01", "01"


def RequestToAPI(endpoint)

    url = URI("#{URL}#{endpoint}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'

    response = http.request(request)
    return JSON.parse(response.read_body)
end

# puts RequestToAPI("/CountryInfo/ES")

# puts RequestToAPI("/LongWeekend/#{year}/ES")

# DATA = RequestToAPI("/PublicHolidays/#{year}/ES")
# DATA = RequestToAPI("/IsTodayPublicHoliday/ES")

# puts RequestToAPI("/NextPublicHolidaysWorldwide")

# DATA = RequestToAPI("/NextPublicHolidays/ES")

TELEGRAM_BOT_TOKEN = ENV["TELEGRAM_BOT_TOKEN"]
TELEGRAM_API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/sendMessage"
TELEGRAM_CHAT_ID = ENV["TELEGRAM_CHAT_ID"]

def report_to_telegram(endpoint)
    result = RequestToAPI(endpoint)
    # logger.info("Send to telegram...") #  main.rb:49:in `report_to_telegram': undefined local variable or method `logger' for main:Object (NameError)
    sleep(1)
    begin
        Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
            for data in result do
                bot.api.send_message(chat_id: TELEGRAM_CHAT_ID, 
                text: "Date: #{data["date"]} 
                \n Local Name: #{data["localName"]}
                \n Fixed: #{data["fixed"]}
                \n Global: #{data["global"]}
                \n Types: #{data["types"][0..]}"
                )
            end
        end
    rescue
        logger.error("Err while sending to telegramm")
    end
end

# Main 
while true
    year = Time.now.year
    case Time.new.strftime("%H:%M")
    # Send when new year come        
    when "10:00", FIRST_D == Time.now.day, FIRST_M == Time.now.month
        report_to_telegram("/PublicHolidays/#{year}/ES")
        sleep(70)
    when "09:00", FIRST_D == Time.now.day
        report_to_telegram("/NextPublicHolidays/ES")
        sleep(70)
    when "08:00"
        report_to_telegram("/IsTodayPublicHoliday/ES")
        sleep(70)
    end
end