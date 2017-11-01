class AlertSpecialEventJob < ApplicationJob
  queue_as :serial

  def perform(recipient_id, test = false)
    sleep 4
    recipient = Recipient.find(recipient_id)
    message_service = MessageService.new(recipient, test)
    if Time.current.in_time_zone("Paris") < Time.parse("24/06/2017").in_time_zone("Paris")
      message_service.send_from_action(action: :send_specials, from_time: Time.current.in_time_zone("Paris").midnight + 1.day)
    else
      recipient.unsubscribe!
      message_service.send_from_action(action: :unsubscription_notification, from_time: Time.current.in_time_zone("Paris").midnight + 1.day)
    end
  end
end
