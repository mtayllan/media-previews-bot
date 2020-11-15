# frozen_string_literal: true

require 'telegram/bot'
require 'uri'
require 'net/http'

FB_TOKEN = ENV['FB_TOKEN']
TELEGRAM_TOKEN = ENV['TELEGRAM_TOKEN']

GetInstagramThumbnail = lambda do |url|
  uri = URI('https://graph.facebook.com/v9.0/instagram_oembed')
  params = {
    url: url,
    access_token: FB_TOKEN,
    fields: 'thumbnail_url',
    omitscript: true
  }
  uri.query = URI.encode_www_form(params)

  res = Net::HTTP.get_response(uri)
  JSON.parse(res.body)['thumbnail_url'] if res.is_a?(Net::HTTPSuccess)
end

Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when %r{/d}
      urls = URI.extract(message.text)
      if urls[0]
        thumb_url = GetInstagramThumbnail.call(urls[0])
        bot.api.send_message(chat_id: message.chat.id, text: thumb_url)
      else
        bot.api.send_message(chat_id: message.chat.id, text: 'Nenhuma url detectada.')
      end
    end
  end
end
