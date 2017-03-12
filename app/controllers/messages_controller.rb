class MessagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :receive
  skip_before_action :verify_authenticity_token, only: :receive
  skip_after_action :verify_authorized, only: :receive

  def receive
     # Verifies http request comes from Twilio
    if params["key"] == ENV['SMS_WEBHOOK_KEY']

      from = params["From"]
      body = params["Body"]
      test_mode = params["test_mode"] == "true" ? true : false

      if Recipient.find_by(phone_number: from) # If recipient exists
        recipient = Recipient.find_by(phone_number: from)
      else # If recipient is new
        recipient = Recipient.new(phone_number: from)
        recipient.save
      end

      message_processor = MessageProcessingService.new
      result = message_processor.process(body)

      # Send message
      if test_mode
        puts result[:body]
      else
        Message.create(content: body, sent_by_user: true, recipient: sender)
        recipient.subscribe!(result[:latitude], result[:longitude]) if result[:action] == :subscribed

        @client = Twilio::REST::Client.new ENV['TWILIO_ACCCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
        @client.account.messages.create(
          from: '+33644647897',
          to: result[:recipient].phone_number,
          body: result[:body]
        )

        Message.create(content: result[:body], sent_by_user: false, recipient: message_details[:recipient])
      end


    end
  end
end
