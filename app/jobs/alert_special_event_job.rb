class AlertSpecialEventJob < ApplicationJob
  queue_as :default

  def perform(recipient_id, test = false)
    sleep 4
    recipient = Recipient.find(recipient_id)
    message_service = MessageService.new(recipient, test)
    if Time.current.in_time_zone("Paris") < Time.parse("24/06/2017").in_time_zone("Paris")
      message_service.send_from_action(:send_specials, Time.current.in_time_zone("Paris").midnight + 1.day)
    else
      recipient.unsubscribe!
      message_service.send_from_action(:unsubscription_notification, Time.current.in_time_zone("Paris").midnight + 1.day)
    end
  end
end
