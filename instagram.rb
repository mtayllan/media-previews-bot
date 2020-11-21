# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'net/http'
require 'watir'

FB_TOKEN = ENV['FB_TOKEN']

GetHtmlContent = lambda do |url|
  uri = URI('https://graph.facebook.com/v9.0/instagram_oembed')
  params = {
    url: url,
    access_token: FB_TOKEN,
    fields: 'html'
  }
  uri.query = URI.encode_www_form(params)

  res = Net::HTTP.get_response(uri)
  return unless res.is_a?(Net::HTTPSuccess)

  html = JSON.parse(res.body)['html']
  html.gsub('//platform.instagram.com/en_US/embeds.js', 'https://platform.instagram.com/en_US/embeds.js')
end

WriteToTempFile = lambda do |content|
  File.open('temp.html', 'w') { |f| f.write(content) }
end

GetInstagramMedia = lambda do |url|
  content = GetHtmlContent.(url)
  return if content.nil?

  WriteToTempFile.(content)
  browser = Watir::Browser.new(:chrome, headless: true)
  browser.goto("file://#{Dir.pwd}/temp.html")
  iframe = browser.iframe(id: 'instagram-embed-0')
  link = iframe.link(class: 'EmbeddedMedia')
  link.wait_until(&:present?)

  media = iframe.video.present? ? iframe.video.src : link.img.src
  description = iframe.div(class: 'Caption').text
  browser.close

  {
    description: description,
    media: media
  }
end
