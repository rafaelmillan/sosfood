class MessagesController < ApplicationController
  skip_before_action :authenticate_organization!, only: :receive
  skip_before_action :verify_authenticity_token, only: :receive
  skip_after_action :verify_authorized, only: :receive

  def receive
    body = params["Body"]
    sender = params["From"]
    if User.find_by(phone_number: sender) # If user exists
      user = User.find_by(phone_number: sender)
    else # If user is new
      user = User.new(phone_number: sender)
      user.save
    end
    message = Message.new(content: body, sent_by_user: true, user: user)
    message.save
    coordinates = Geocoder(body + " France")
    lat = coordinates[0]
    lon = coordinates[1]

    generate_message(coordinates)
  end

  private

  def generate_message
    distributions = Distribution.near(coordinates)

    now = Time.now

    breakfast_min = Time.new(now.year, now.month, now.day, 06, 00)
    breakfast_max = Time.new(now.year, now.month, now.day, 11, 00)
    lunch_min = Time.new(now.year, now.month, now.day, 11, 00)
    lunch_max = Time.new(now.year, now.month, now.day, 17, 00)
    dinner_min = Time.new(now.year, now.month, now.day, 18, 00)
    dinner_max = Time.new(now.year, now.month, now.day, 23, 00)

    if now.hour < 9
      # break lunch dinner
    elsif now.hour < 12
      # lunch diner breakfast+
      breakfast_min += 1.day
      breakfast_max += 1.day
    elsif now.hour < 19
      # dinner breakfast+ lunch+
      breakfast_min += 1.day
      breakfast_max += 1.day
      lunch_min += 1.day
      lunch_max += 1.day
    elsif now.hour >= 19
      # break+ lunch+ dinner+
      breakfast_min += 1.day
      breakfast_max += 1.day
      lunch_min += 1.day
      lunch_max += 1.day
      dinner_min += 1.day
      dinner_max += 1.day
    end

    # Finding breakfast
    distributions.each do |dis|
      schedule = IceCube::Schedule.from_yaml(distribution.recurrence)
      if schedule.occurs_between?(breakfast_min, breakfast_max)
        breakfast = {
          distribution = distribution,
          time = schedule.next_occurrence(breakfast_min)
        }
      end
      break unless breakfast == nil
    end

    # Finding lunch
    distributions.each do |dis|
      schedule = IceCube::Schedule.from_yaml(distribution.recurrence)
      if schedule.occurs_between?(lunch_min, lunch_max)
        lunch = {
          distribution = distribution,
          time = schedule.next_occurrence(lunch_min)
        }
      end
      break unless lunch == nil
    end

    # Finding dinner
    distributions.each do |dis|
      schedule = IceCube::Schedule.from_yaml(distribution.recurrence)
      if schedule.occurs_between?(dinner_min, dinner_max)
        dinner = {
          distribution = distribution,
          time = schedule.next_occurrence(dinner_min)
        }
      end
      break unless dinner == nil
    end



  end
end
