class MessagesController < ApplicationController
  skip_before_action :authenticate_organization!, only: :receive
  skip_before_action :verify_authenticity_token, only: :receive
  skip_after_action :verify_authorized, only: :receive

  def receive
    body = params["Body"]
    sender = params["From"]
    test_mode = params["test_mode"] == "true" ? true : false
    if params["key"] == ENV['SMS_WEBHOOK_KEY']
      if Recipient.find_by(phone_number: sender) # If recipient exists
        recipient = Recipient.find_by(phone_number: sender)
      else # If recipient is new
        recipient = Recipient.new(phone_number: sender)
        recipient.save
      end
      message = Message.new(content: body, sent_by_user: true, recipient: recipient)
      message.save
      coordinates = Geocoder.coordinates(body + " France")

      twilio_service = TwilioService.new
      twilio_service.send_message(message.recipient.phone_number, coordinates, test_mode)
    end
  end
end
