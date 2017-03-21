class AlertUserJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    Recipient.where(subscribed: true).each do |recipient|
      message_service = MessageService.new(recipient)
      message_service.send_from_action(:send_tomorrows_meals, Time.current.in_time_zone("Paris").midnight + 1.day)
    end
  end
end
