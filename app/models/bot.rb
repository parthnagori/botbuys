class Bot
  def self.send_message(context, message)
    # String botname = "weatherbot";
    # String botmessage = "Weather in"+cityName+" is -"+responseofWeatherAPI";
    url = "http://api.gupshup.io/sm/api/bot/botbuys/msg"
    body = {context:context,message:message}
    # RestClient.post(url, URI.encode_www_form_component(body), {:content_type => "application/x-www-form-urlencoded"})
    puts "sending message: #{message}"
    puts "curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'apikey: 8a4c72e89a27440bc491906efcef14c4' -d 'context=#{context.to_json}&message=#{message}' 'https://api.gupshup.io/sm/api/bot/BotBuy/msg'"
    `curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'apikey: 8a4c72e89a27440bc491906efcef14c4' -d 'context=#{context.to_json}&message=#{message}' 'https://api.gupshup.io/sm/api/bot/BotBuy/msg'`
  end

  def self.get_name(senderobj)
    case senderobj["channeltype"]
    when "telegram"
      return senderobj["display"].split(" ")[0]
    end
  end

  def self.command_msg
    message = "Use following commands\n"
    Bot::COMMANDS.each do |k,v|
      message = "#{message}#{k} - #{v}\n"
    end
    return message
  end

  def self.more_command_msg
    message = "More commands\n"
    Bot::MORE_COMMANDS.each do |k,v|
      message = "#{message}#{k} - #{v}\n"
    end
    return message
  end

  def self.response(command, value)
    # Bot.response(command, value)
    case command
    when "more"
      return Bot.more_command_msg
    end
    return "your command is #{command}, value is #{value}"
  end

  MORE_COMMANDS = {"email" => "My email address"}
  COMMANDS = {"+account" => "Add new Accout", "accounts" => "Details of all your Accouts", "surprize-me" => "Get amazed by Botbuys", "more" => "Get more options"}
end