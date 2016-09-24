module Sms
  class << self
    def send_otp(otp, phone)
      twilio_sid = "AC1cf1b6dfdf5180b3f4c2eadde78860da"
      twilio_token = "6010682900ee93a4ac5b462d5335915d"
      twilio_phone_number = "3477089548"

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
