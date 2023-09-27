require 'uri'
require 'json'
require 'logger'
require 'net/http'
require 'telegram/bot' # https://github.com/atipugin/telegram-bot-ruby

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

# url = URI("https://date.nager.at/api/v3/PublicHolidays/2023/ES")

# https://date.nager.at/swagger/index.html

URL = "https://date.nager.at/api/v3"

YEAR = Time.now.year
time_to_send = "08:00" #Time.new.strftime("%H:%M")

logger.info("Starting...")

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

# puts RequestToAPI("/LongWeekend/#{YEAR}/ES")

# DATA = RequestToAPI("/PublicHolidays/#{YEAR}/ES")
# DATA = RequestToAPI("/IsTodayPublicHoliday/ES")
DATA = RequestToAPI("/NextPublicHolidays/ES")
# puts RequestToAPI("/NextPublicHolidaysWorldwide")

# DATA = RequestToAPI("/NextPublicHolidays/ES")

TELEGRAM_BOT_TOKEN = "1802734430:AAHESIJUGFg8d6P_OpF-w1BO_vgl0n0FzzI" #ENV["TELEGRAM_BOT_TOKEN"]
TELEGRAM_API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/sendMessage"
TELEGRAM_CHAT_ID = "411906804" #ENV["TELEGRAM_CHAT_ID"]

def report_to_telegram
    logger.info("Send to telegram...")
    sleep(1)
    Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
        for data in DATA do
            bot.api.send_message(chat_id: TELEGRAM_CHAT_ID, 
            text: "Date: #{data["date"]} 
            \n Local Name: #{data["localName"]}
            \n Fixed: #{data["fixed"]}
            \n Global: #{data["global"]}
            \n Types: #{data["types"][0..]}"
            )
        end
    end
end

# Main 
while true
    if time_to_send == Time.new.strftime("%H:%M")
        begin
            report_to_telegram
        rescue
            logger.err("Err while sending to telegramm")
        end
    end
end