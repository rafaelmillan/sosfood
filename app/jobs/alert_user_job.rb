class AlertUserJob < ApplicationJob
  queue_as :default

  def perform(recipient_id, test = false)
    message_service = MessageService.new(Recipient.find(recipient_id), test)
    message_service.send_from_action(:send_tomorrows_meals, Time.current.in_time_zone("Paris").midnight + 1.day)
  end
end
