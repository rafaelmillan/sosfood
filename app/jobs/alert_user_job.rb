class AlertUserJob < ApplicationJob
  queue_as :serial

  def perform(recipient_id, test = false)
    sleep 4
    recipient = Recipient.find(recipient_id)
    message_service = MessageService.new(recipient, test)
    if recipient.alerts_count < 29
      recipient.alerts_count += 1
      recipient.save
      message_service.send_from_action(action: :send_tomorrows_meals, from_time: Time.current.in_time_zone("Paris").midnight + 1.day)
    else
      recipient.unsubscribe!
      message_service.send_from_action(action: :send_tomorrows_meals, from_time: Time.current.in_time_zone("Paris").midnight + 1.day)
      sleep 4
      message_service.send_from_action(action: :unsubscription_notification, from_time: Time.current.in_time_zone("Paris").midnight + 1.day)
    end
  end
end
