module Sms
  class << self
    def send_otp(otp, phone)
      twilio_sid = ENV["TWILIO_SID"]
      twilio_token = ENV["TWILIO_TOKEN"]
      twilio_phone_number = ENV["TWILIO_PHONE_NUMBER"]

      unless otp.blank? || phone.blank?
        @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token

        @twilio_client.messages.create(
          :from => "+1#{twilio_phone_number}",
          :to => "+91#{phone}",
          :body => "Your OTP is #{otp}."
        )
      end
    end
  end
end


