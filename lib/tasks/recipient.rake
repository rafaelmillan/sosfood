namespace :recipient do
  desc "Alerting subscribers (async)"
  task alert_subscribers: :environment do
    subscribers = Recipient.where(subscribed: true)
    puts "Enqueing alert for #{subscribers.size} subscribers..."
    subscribers.each { |subscriber| AlertUserJob.perform_later(subscriber.id) }
  end

  desc "Alerting subscribers (async)"
  task alert_ramadan_subscribers: :environment do
    subscribers = Recipient.where(subscribed: true, preference: "ramadan")
    puts "Enqueing alert for #{subscribers.size} subscribers..."
    subscribers.each { |subscriber| AlertSpecialEventJob.perform_later(subscriber.id) }
  end
end
