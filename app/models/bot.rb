class Bot
  def self.send_message(context, message)
    # String botname = "weatherbot";
    # String botmessage = "Weather in"+cityName+" is -"+responseofWeatherAPI";
    url = "http://api.gupshup.io/sm/api/bot/botbuys/msg"
    body = {context:context,message:message}
    # RestClient.post(url, URI.encode_www_form_component(body), {:content_type => "application/x-www-form-urlencoded"})
    puts "curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'apikey: 8a4c72e89a27440bc491906efcef14c4' -d 'context=#{context.to_json}&message=#{message}' 'https://api.gupshup.io/sm/api/bot/BotBuy/msg'"
    `curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'apikey: 8a4c72e89a27440bc491906efcef14c4' -d 'context=#{context.to_json}&message=#{message}' 'https://api.gupshup.io/sm/api/bot/BotBuy/msg'`
  end
end