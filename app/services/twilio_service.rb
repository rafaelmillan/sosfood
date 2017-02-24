class TwilioService
  def send_message(number, coordinates, test_mode = false)
    # Uncomment below for production
    if test_mode
      puts generate_message(coordinates)
    else
      @client = Twilio::REST::Client.new ENV['TWILIO_ACCCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

      @client.account.messages.create(
        from: '+33644647897',
        to: number,
        body: generate_message(coordinates)
      )
    end

  end

  private

  def generate_message(coordinates)
    meals = Distribution.find_next_three(coordinates)

    message = "#{meals[0][:name]} - #{meals[0][:time].strftime("%e/%m/%y %Hh%M")}
#{meals[0][:distribution].organization.organization_name}
#{meals[0][:distribution].address_1}, #{meals[0][:distribution].postal_code}

#{meals[1][:name]} - #{meals[1][:time].strftime("%e/%m/%y %Hh%M")}
#{meals[1][:distribution].organization.organization_name}
#{meals[1][:distribution].address_1}, #{meals[1][:distribution].postal_code}

#{meals[2][:name]} - #{meals[2][:time].strftime("%e/%m/%y %Hh%M")}
#{meals[2][:distribution].organization.organization_name}
#{meals[2][:distribution].address_1}, #{meals[2][:distribution].postal_code}"

    return message
  end
end
