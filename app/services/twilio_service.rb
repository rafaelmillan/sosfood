class TwilioService
  def send_message(number, coordinates)
    # Uncomment below for production
    # @client = Twilio::REST::Client.new ENV['TWILIO_ACCCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    # @client.account.messages.create(
    #   from: '+33644647897',
    #   to: number,
    #   body: generate_message(coordinates)
    # )

    # Uncomment below for testing
    puts generate_message(coordinates)

  end

  private

  def generate_message(coordinates)
    meals = Distribution.find_next_three(coordinates)

    message = "#{meals[0][:name]}
#{meals[0][:time].strftime("%m/%e/%y %Hh%M")}
#{meals[0][:distribution].address_1}

#{meals[1][:name]}
#{meals[1][:time].strftime("%m/%e/%y %Hh%M")}
#{meals[1][:distribution].address_1}

#{meals[2][:name]}
#{meals[2][:time].strftime("%m/%e/%y %Hh%M")}
#{meals[2][:distribution].address_1}"

    return message
  end
end
