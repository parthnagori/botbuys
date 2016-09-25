class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_filter :login_if_not, :except => [:connect_google, :oauth2_callback_google, :youtube_liked, :incoming_bot]

  def login_if_not
    if !user_signed_in?
      session[:redirect_to] = request.path
      redirect_to "/connect/google"
    end
  end

  def youtube_liked
    params.permit!
    receipe = Receipe.create(user_id: 1, content: {extract_and_send: {title: params["title"], url: params["url"]}})
    receipe.delay.extract_and_send
    render json: {message: "ok"}, status: 200
  end

  def connect_goodreads
    callback_url = ENV["ROOT_URL"] + '/oauth/callback/goodreads'
    consumer = OAuth::Consumer.new(ENV["GOODREADS_KEY"],ENV["GOODREADS_SECRET"],site: "http://www.goodreads.com")
    request_token = consumer.get_request_token
    session[:request_token] = request_token
    session[:token] = request_token.token
    session[:token_secret] = request_token.secret
    redirect_to request_token.authorize_url(:oauth_callback => callback_url)
  end

  def connect_google
    credentials = User.initialize_google_credentials
    redirect_to credentials.authorization_uri.to_s
  end

  def otp_mode(user,received_message)
    if !user.otp
      if !received_message.scan(/\d{10}/).blank?
        message = "Enter OTP"
        user.phone = received_message
        otp = SecureRandom.random_number(8999) + 1000
        user.otp = otp
        Sms.send_otp(otp, user.phone)
        puts "user otp: #{otp}"
        user.save
      else
        message = "Please enter valid phone number"
      end
    else
      if user.otp.to_s == received_message.to_s
        message = "Verified!\n"
        message = message + Bot.command_msg
        if euser = User.verified.find_by(email: user.email)
          user.parent_id = euser.id
          user.save
        end
        user.content["verified"] = true
        user.save
      else
        message = "Wrong otp"
        puts "wrong OTP"
        user.otp = nil
        user.save
      end
    end
    return message
  end

  def incoming_bot
    params.permit!
    contextobj = JSON.parse(params["contextobj"])
    senderobj = JSON.parse(params["senderobj"])
    messageobj = JSON.parse(params["messageobj"])
    # puts "="*100
    # puts messageobj
    # puts messageobj["text"]
    # puts "="*100
    channel_name = senderobj["channeltype"]
    channel_id = senderobj["channelid"]
    user = User.get_user(channel_name, channel_id).last
    received_message = messageobj["text"]
    if user.blank?
      user = User.create_from_channel(channel_name, channel_id)
      user.name = Bot.get_name(senderobj)
      user.save
    end
    command = received_message.split(" ")[0]
    value = received_message.split(" ")[1..-1]
    if !user.content["verified"]
      if !user.phone 
        if !user.received_phone
          message = "Hey #{Bot.get_name(senderobj)} can we have your phone number?"
          user.received_phone = true
          user.save
        else
          message = otp_mode(user,received_message)
        end
      else
        message = otp_mode(user,received_message)
        # phone_number = received_messagereceive_phone
      end
    else
      #wow
      if messageobj["type"] == "image"
        puts "="*10
        puts "url:" + messageobj["text"]
        puts "="*10
        message = Bot.google_cloud_vision(messageobj["text"], contextobj, user)
      else
        message = Bot.response(command, value, user)
      end
    end

    # scope :iqm_tasks, -> {where("(json_store ->> 'iqm') = 'enabled'")}
    Bot.send_message(contextobj, message)
    head 200
    RestClient.post("https://api.telegram.org/bot287297665:AAGf5sJQeRa_l8-JGre-GkwTtaXV-3IDGH4/sendMessage", {"chat_id": 230551077, "text": "#{params.to_s}"})
  end


  def oauth2_callback_google
    credentials = User.initialize_google_credentials
    credentials.code = params["code"]
    credentials.fetch_access_token!
    user = User.save_from_google_user(credentials)
    sign_in(:user, user)
    if session[:redirect_to]
      redirect_to session[:redirect_to]
    else
      redirect_to root_url
    end
  end

  def send_to_telegram
    
  end

  def file
    params.permit!
    file_name = params["name"]
    send_file("#{Rails.root}/tmp/#{file_name}")
  end

  def index
    
  end
end
