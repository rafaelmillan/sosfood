class MessagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :receive
  skip_before_action :verify_authenticity_token, only: :receive
  skip_after_action :verify_authorized, only: :receive

  def receive
     # Verifies http request comes from Twilio
    if params["key"] == ENV['SMS_WEBHOOK_KEY']

      sender = params["From"]
      body = params["Body"]

      message_processor = MessageProcessingService.new
      message_details = message_processor.process(body, sender)

      # Send message
      test_mode = params["test_mode"] == "true" ? true : false
      if test_mode
        puts message_details[:body]
      else
        @client = Twilio::REST::Client.new ENV['TWILIO_ACCCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

        @client.account.messages.create(
          from: '+33644647897',
          to: message_details[:recipient].phone_number,
          body: message_details[:body]
        )
      end

    end
  end

end
