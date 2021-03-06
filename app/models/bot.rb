class Bot
  def self.send_message(context, message)
    # String botname = "weatherbot";
    # String botmessage = "Weather in"+cityName+" is -"+responseofWeatherAPI";
    url = "http://api.gupshup.io/sm/api/bot/botbuys/msg"
    body = {context:context,message:message}
    # RestClient.post(url, URI.encode_www_form_component(body), {:content_type => "application/x-www-form-urlencoded"})
    puts "sending message: #{message}"
    puts "curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'apikey: 8a4c72e89a27440bc491906efcef14c4' -d 'context=#{context.to_json}&message=#{message}' 'https://api.gupshup.io/sm/api/bot/BotBuy/msg'"
    `curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'apikey: 8a4c72e89a27440bc491906efcef14c4' -d 'context=#{context.to_json}&message=#{message.class != Hash ? message : message.to_json}' 'https://api.gupshup.io/sm/api/bot/BotBuy/msg'`
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

  def self.response(command, value, user)
    # Bot.response(command, value)
    command = command.downcase
    case command
    when "/more", "more"
      return Bot.more_command_msg
    when "/transactions", "transactions"
      result = ""
      hash = AnalyzeAccount.get_transaction_summary_for_customer("")
      hash.each do |acc_no, monthly_data|
        result = "#{result}#{acc_no}\n"
        monthly_data.each do |month, data|
          result = "#{result}  #{month}\n"
          data.each do |dir, amt|
            result = "#{result}    #{dir}: #{amt}\n"
          end
        end
      end
      return result
    when "/expenditure", "expenditure"
      result = ""
      hash = AnalyzeAccount.get_max_spends("")
      hash.each do |acc_no, data|
        result = "#{result}#{acc_no}\n"
        total = 0
        data.each do |where, amt|
          result = "#{result}  #{where}: #{amt}\n"
          total = total + amt.to_f
        end
        result = "#{result}  Total:#{total}\n"
      end
      return result
    when "/balance", "balance"
      result = ""
      hash = AnalyzeAccount.get_account_balances("")
      hash.each do |acc_no, amt|
        result = "#{result}#{acc_no}: #{amt}\n"
      end
      return result
    when "/accounts", "accounts"
      puts "&&&"*1000
      result = ""
      hash = AnalyzeAccount.get_account_types("")
      hash.each do |k,v|
        result = "#{result}#{k}:#{v}\n"
      end
      return result
    when "/email", "email"
      return "Your botbuys email address is #{user.email}"
    when "/phone"||  "phone"
      return "Your botbuys phone no. is #{user.phone}"
    when "buy"
      return "Buying #{user.products[value[0].to_i]}"
    when "/inv_opts", "inv_opts"
      result = ""
      AnalyzeAccount::INVESTMENT_OPTIONS.each do |k,v|
        result = "#{result}#{k}:  #{v["institute_name"]} Offering #{v["rate"]}, Tenure: #{v["min_tenure_months"]} month, Risk factor: #{v["risk"]}\n"
      end
      return result
    when "/inv_projection", "inv_projection"
      result = ""
      if value.count == 0 || value.count == 1
        return "Please give command in form /inv_projection AMOUNT TENURE"
      end
      hash = AnalyzeAccount.get_investment_suggestions("", value[0].to_s.to_i, value[1].to_s.to_i)
      hash.each do |k,v|
        result = "#{result}#{k}:\n"
        v.each do |k1,v1|
          result = "#{result} Option #{k1}\n"
          result = "#{result} Tenure:#{v1[0]}\n"
          result = "#{result} Rate:#{v1[1]}\n"
          result = "#{result} ProjAmt:#{v1[2]}\n"
          result = "#{result} Risk:#{v1[3]}\n"
        end
      end
      return result.gsub("*","")
    when "/loans", "loans"
      result = ""
      Loans::LENDERS.each_with_index do |hash, index|
        result = "#{result}#{index}. #{hash["institute_name"]}, Rate: #{hash["rate"]}, Tenure: #{hash["tenure"]}\n"
      end
      result = "#{result} Get detailed information by command loan followed by id and then amount. For Example:\n loan ID AMOUNT"
      return result
    when "/loan", "loan"
      result = ""
      hash = Loans.apply_loans(value[0], value[1].to_s.to_i)
      result = "EMI: #{hash["emi"]}, Repayment: #{hash["repayment"]}, Tenure: #{hash["tenure"]} months, Interest: #{hash["interest"]}"
      return result
    when "/pay", "pay"
      if value.count == 0
        result = "Get your payments done via this command. For Example:\n pay ID AMOUNT\n"
        a = Payments.get_payees("")
        a.parsed_response.each_with_index do |(k,v), i|
          result = "#{result}  #{i} #{v['nickName']}\n"
        end
        return result
      end
      if value.count == 1
        return "Please enter amount."
      end
      if value.count == 2
        otp = SecureRandom.random_number(8999) + 1000
        Sms::send_otp(otp, user.phone)
        user.trans_value = value + [otp.to_s]
        user.save
        return "Repeat same command with OTP in the end.\nFor example:\n #{command} #{value.join(" ")} RECEIVED_OTP."
      elsif user.trans_value == value
        Payments.transact(value[0], value[1])
        return "Payment successful."
      else
        return "Values doesn\'t match or OTP is wrong"
      end
    end
    return "Hey #{user.first_name},\n" + Bot.command_msg
  end

  def self.google_cloud_vision(url, context, user)
    a = SecureRandom.hex
    `wget #{url} -O #{a}`
    res = GoogleCloudVision::Classifier.new(ENV["GK"],[{ image: "./#{a}", detection: 'LABEL_DETECTION', max_results: 1 }])
    puts "res: #{res.response}"
    product_name = res.response["responses"][0]["labelAnnotations"][0]["description"]
    # return "Do you want to buy this #{product_name}"
        
    `wget "http://www.amazon.in/s/field-keywords=#{product_name}" -O ama`
    doc = Nokogiri::HTML(File.open("./ama", "r"))
    # puts doc
    send_message(context, "Amazon search for '#{product_name}'\n")
    # doc.css('.s-item-container').first(3).each_with_index do |el, index|
    #   # grab the title
    #   title = el.css('a.a-link-normal').first.content
    #   image = el.css('.s-access-image .cfMarker').attribute 'src'
    #   # grab the product link
    #   link = el.css('a.a-link-normal').attribute 'href'
    #   send_message(context, {"type": "image", "originalUrl": image, "previewUrl": "Result id:#{index} #{title} link:#{link}"})
    #   user.products[index] = "#{title} link: #{link}"
    #   user.save
    # end
    doc = Nokogiri::HTML(File.open("./ama", "r"))
      # puts doc
      # send_message(context, "Amazon search for '#{product_name}'\n")
      doc.css('.s-item-container').first(3).each_with_index do |el, index|
        # grab the title
      title = el.css('a.a-link-normal.s-access-detail-page.a-text-normal').first.content
      link = el.css('a.a-link-normal.s-access-detail-page.a-text-normal').attribute('href').value
      image = el.css('.s-access-image.cfMarker').attribute('src').value
      price = el.css('.a-size-base.a-color-price.s-price.a-text-bold').last.text rescue el.css('.a-size-base.a-color-price.s-price.a-text-bold').text
      puts "==========#{price}"
      # grab the product link
      # puts title
      # puts image
      # puts link
      send_message(context,"Result id:#{index} #{title} link:#{link} Price: #{price}")
      send_message(context, {"type" => "image", "previewUrl" => image, "originalUrl" => image})
      user.products[index] = "#{title} link: #{link}"
      user.save
    end
    return "Reply with buy 1,2 or 3 to buy respective product"
  end

  MORE_COMMANDS = {"/phone" => "My phone number"}
  COMMANDS = {"/accounts" => "Details of all your Accouts","/transactions" => "Get details of all your transactions", "/expenditure" => "Get details of ", "/balance" => "Get balance of your accouts", "/more" => "Get more options", "/pay" => "Get your payments done via this command. For Example:\n pay ID AMOUNT", "/inv_opts" => "Show me Investment options", "/loans" => "Get loan providers info", "/inv_projection" => "Get Investments projection for given amount. For Example: \ninv_projection AMOUNT TENURE\nWill give you amount of money you make by making this investment for given tenure. Take risk factor also into account :)"}
  # get_transaction_summary_for_customer(phone_no)
  # get_max_spends(phone_no)
  # get_account_balances(phone_no)
  # get_account_types(phone_no)

end