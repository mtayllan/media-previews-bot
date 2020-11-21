# frozen_string_literal: true

require 'telegram/bot'
require 'uri'
require_relative './instagram'

TELEGRAM_TOKEN = ENV['TELEGRAM_TOKEN']

Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when %r{/d}
      urls = URI.extract(message.text)
      if urls[0]&.include?('instagram')
        data = GetInstagramMedia.call(urls[0])
        bot.api.send_message(chat_id: message.chat.id, text: "#{data[:description]}\n\n #{data[:media]}")
      else
        bot.api.send_message(chat_id: message.chat.id, text: 'Nenhuma media detectada.')
      end
    end
  end
end
