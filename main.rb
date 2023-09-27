require 'uri'
require 'json'
require 'net/http'
require 'telegram/bot' # https://github.com/atipugin/telegram-bot-ruby

# url = URI("https://date.nager.at/api/v3/PublicHolidays/2023/ES")

# https://date.nager.at/swagger/index.html

URL = "https://date.nager.at/api/v3"

YEAR = Time.now.year

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

# parsed_json = JSON.parse(RequestToAPI("/CountryInfo/ES"))

# puts parsed_json["commonName"]
# puts RequestToAPI("/LongWeekend/#{YEAR}/ES")

DATA = RequestToAPI("/PublicHolidays/#{YEAR}/ES")
# puts RequestToAPI("/IsTodayPublicHoliday/ES")
# puts RequestToAPI("/NextPublicHolidays/ES")
# puts RequestToAPI("/NextPublicHolidaysWorldwide")

# DATA = RequestToAPI("/NextPublicHolidays/ES")

TELEGRAM_BOT_TOKEN = ENV["TELEGRAM_BOT_TOKEN"]
TELEGRAM_API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/sendMessage"
TELEGRAM_CHAT_ID = ENV["TELEGRAM_CHAT_ID"]

def report_to_telegram
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

report_to_telegram