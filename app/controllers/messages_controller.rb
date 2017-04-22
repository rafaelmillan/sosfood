class MessagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :receive
  skip_before_action :verify_authenticity_token, only: :receive
  skip_after_action :verify_authorized, only: :receive

  def receive
     # Verifies http request comes from Callr
    if params["key"] == ENV['SMS_WEBHOOK_KEY']

      recipient = set_recipient(params["sender"])
      body = params["message"]
      test_mode = params["test_mode"] == "true"

      Message.create(content: body, sent_by_user: true, recipient: recipient) unless test_mode

      message_service = MessageService.new(recipient, test_mode)
      message_service.parse_and_reply(body)
      head 200
    end
  end

  private

  def set_recipient(from)
    if Recipient.find_by(phone_number: from) # If recipient exists
      recipient = Recipient.find_by(phone_number: from)
    else # If recipient is new
      recipient = Recipient.new(phone_number: from)
      recipient.save
      return recipient
    end
  end
end
