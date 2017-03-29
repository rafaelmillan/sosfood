class MessageService
  def initialize(recipient, test_mode = false)
    @recipient = recipient
    @test_mode = test_mode
  end

  def parse_and_reply(received_body)
    parse(received_body)
    reply_body = generate_body(@action, Time.current.in_time_zone("Paris"))
    send_sms(@recipient, reply_body)
  end

  def send_from_action(action, from_time)
    @action = action
    reply_body = generate_body(action, from_time, @recipient)
    send_sms(@recipient, reply_body)
  end

  private

  def send_sms(to, body)
    if @test_mode == true
      puts body
    else
      # Pre-sending actions
      @recipient.subscribe!(@coordinates, @parsed_address) if @action == :subscribe
      save_referrals(@meals) if @action == :send_next_meals || @action == :send_tomorrows_meals

      # SMS sending
      client = MessageBird::Client.new(ENV['MESSAGEBIRD_API_KEY'])
      client.message_create('+33644631192', @recipient.phone_number, body)
      Message.create(content: body, sent_by_user: false, recipient: @recipient)
    end
  end

  def generate_body(action, from_time, custom_recipient = nil)
    if custom_recipient
      @parsed_address = custom_recipient.address
      @coordinates = [custom_recipient.latitude, custom_recipient.longitude]
    end

    if action == :send_next_meals || action == :send_tomorrows_meals
      @meals = Distribution.find_next_three(@coordinates, from_time)

      meals_array = @meals.map do |meal|
"#{meal[:name]} (#{meal[:time].in_time_zone("Paris").strftime("%e/%m/%y de %Hh%M")} à #{meal[:time].end_time.in_time_zone("Paris").strftime("%Hh%M")})
#{meal[:distribution].display_name}
#{meal[:distribution].address_1}, #{meal[:distribution].address_2 + ', ' unless meal[:distribution].address_2.blank?}#{meal[:distribution].postal_code} #{meal[:distribution].city}
Métro #{meal[:distribution].stations.first.name}"
      end

"[SOS Food est en phase de test, les repas proposés sont donnés à titre indicatif.]
Repas solidaires #{"pour DEMAIN " if @action == :send_tomorrows_meals}près de \"#{@parsed_address}\" :#{' Aucun repas trouvé dans les prochaines 24h' if meals_array.empty?}

#{meals_array.join("\n\n")}"
    elsif action == :subscribe
"Bienvenue sur SOS Food. Votre abonnement à été pris en compte à l'adresse \"#{@parsed_address}\". Chaque soir, vous recevrez par SMS trois propositions de repas pour le lendemain. À bientôt, SOS Food."
    elsif action == :unvalid_address
"Nous n'avons pas compris l'adresse \"#{@parsed_address}\". Merci de nous renvoyer une adresse, un code postal, ou une station de métro. À bientôt, SOS Food."
    elsif action == :uncovered_area
"L'adresse \"#{@parsed_address}\" n'est pas encore couverte par SOS Food."
    end

  end

  def parse(body)
    # Subscription
    body_words = body.split
    keyword = body_words[0].downcase
    if keyword == "alerte" || keyword == "alert" # Starts with alert
      original_address = body_words[1..-1].join(" ")
      verify_address(original_address, :subscribe)
    else # Send meals for next 24h
      original_address = body
      verify_address(original_address, :send_next_meals)
    end
  end

  def verify_address(original_address, action)
    # Checks if it's a metro station
    if station = Station.similar(original_address)
      @parsed_address = "Métro #{station.name}"
      @coordinates = [station.latitude, station.longitude]
      @action = action

    # Checks if the address is valid
    elsif (location = Geocoder.search(original_address + " France")[0]).nil?
      @parsed_address = original_address
      @action = :unvalid_address

    # Checks if the location is close to Paris (20km)
    elsif Geocoder::Calculations.distance_between([48.85661400000001,2.3522219000000177], location.coordinates) > 20
      @parsed_address = location.address
      @coordinates = location.coordinates
      @action = :uncovered_area

    # Just sets the action and location
    else
      @parsed_address = location.address
      @coordinates = location.coordinates
      @action = action
    end
  end

  def save_referrals(meals)
    meals.each do |meal|
      Referral.create(
        address: @parsed_address,
        latitude: @coordinates[0],
        longitude: @coordinates[1],
        distribution: meal[:distribution]
      )
    end
  end
end
