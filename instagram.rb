# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

GetInstagramMedia = lambda do |url|
  doc = Nokogiri::HTML(URI.open(url))

  type = doc.at('meta[property="og:type"]')['content']
  description = doc.at('meta[property="og:title"]')['content']
  media = if type == 'video'
            doc.at('meta[property="og:video"]')['content']
          else
            doc.at('meta[property="og:image"]')['content']
          end

  {
    media: media,
    description: description
  }
end
