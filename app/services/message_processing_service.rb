class MessageProcessingService
  def process(sender_body, sender_number)

    sender = set_sender(sender_number)
    save_message(sender_body, sender)

    action = set_sms_type(sender_body)

    if action == :subscribed
      sender.subscribed = true
      sender.latitude = @coordinates[0]
      sender.longitude = @coordinates[1]
      sender.save
    end

    return {
      body: generate_body(action),
      recipient: sender
    }

  end

  private

  def save_message(sender_body, sender)
    message = Message.new(content: sender_body, sent_by_user: true, recipient: sender)
    message.save
  end

  def set_sender(sender_number)
    if Recipient.find_by(phone_number: sender_number) # If recipient exists
      @recipient = Recipient.find_by(phone_number: sender_number)
    else # If recipient is new
      @recipient = Recipient.new(phone_number: sender_number)
      @recipient.save
    end
  end

  def set_sms_type(sender_body)
    # Subscription
    body_words = sender_body.split
    keyword = body_words[0].downcase
    if keyword == "alerte" || keyword == "alert" # Starts with alert
      @original_address = body_words[1..-1].join(" ")
      verify_address(@original_address, :subscribe)
    # Send meals for next 24h
    else
      @original_address = sender_body
      verify_address(@original_address, :send_meals)
    end
  end

  def verify_address(address, sms_type)
    @location = Geocoder.search(address + " France")[0]
    # Checks if the address is valid
    return :unvalid_address if @location.blank?
    # Checks if location is close to Paris (20km)
    @coordinates = @location.coordinates
    if Geocoder::Calculations.distance_between([48.85661400000001,2.3522219000000177], @coordinates) > 20
      :uncovered_area
    else
      sms_type
    end
  end

  def generate_body(action)

    if action == :send_meals
      meals = Distribution.find_next_three(@coordinates)

      meals_array = meals.map do |meal|
"#{meal[:name]} - #{meal[:time].strftime("%e/%m/%y de %Hh%M")} à #{meal[:time].end_time.strftime("%Hh%M")}
#{meal[:distribution].display_name}
#{meal[:distribution].address_1}, #{meal[:distribution].postal_code} #{meal[:distribution].city}
Métro #{meal[:distribution].stations.first.name}"
      end

"SOS Food
Repas solidaires près de \"#{@location.address}\" :

#{meals_array.join("\n\n")}"
    elsif action == :subscribe
"Bienvenue sur SOS Food. Votre abonnement à été pris en compte à l'adresse \"#{@location.address}\". Chaque soir, vous recevrez par SMS trois propositions de repas pour le lendemain. À bientôt, SOS Food."
    elsif action == :unvalid_address
"Nous n'avons pas compris l'adresse \"#{@original_address}\". Merci de nous renvoyer une adresse, un code postal, ou une station de métro. À bientôt, SOS Food."
    elsif action == :uncovered_area
"L'adresse \"#{@location.address}\" n'est pas encore couverte par SOS Food."
    end

  end

end
