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

    Distribution.near(coordinates)
  end

  def create

  end
end
