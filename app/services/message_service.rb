class MessageService
  def initialize(recipient, test_mode = false)
    @recipient = recipient
    @test_mode = test_mode
  end

  def parse_and_reply(received_body)
    parse(received_body)
    @from_time = Time.current.in_time_zone("Paris")
    reply_body = generate_body(@action)
    send_sms(@recipient, reply_body)
  end

  def send_from_action(action, from_time)
    @action = action
    @from_time = from_time
    reply_body = generate_body(action, @recipient)
    send_sms(@recipient, reply_body)
  end

  private

  def send_sms(to, body)
    if @test_mode == true
      puts body
    else
      # Pre-sending actions
      @recipient.subscribe!(@coordinates, @parsed_address) if @action == :subscribe
      @recipient.subscribe!(@coordinates, @parsed_address, "ramadan") if @action == :special_event_subscription
      save_referrals(@meals) if [:send_next_meals, :send_tomorrows_meals, :send_specials].include?(@action)

      # SMS sending
      api = CALLR::Api.new(ENV['CALLR_USERNAME'], ENV['CALLR_PASSWORD'])
      result = api.call('sms.send', '+33644639696', @recipient.phone_number, body, force_encoding: 'GSM', nature: 'ALERTING')
      Message.create(content: body, sent_by_user: false, recipient: @recipient)
    end
  end

  def generate_body(action, custom_recipient = nil)
    if custom_recipient
      @parsed_address = custom_recipient.address
      @coordinates = [custom_recipient.latitude, custom_recipient.longitude]
    end

    if [:send_next_meals, :send_tomorrows_meals].include?(action)
      send_meals_message
    elsif action == :send_specials
      send_specials_message
    elsif action == :subscribe
      subscribe_message
    elsif action == :special_event_subscription
      special_event_subscription_message
    elsif action == :unvalid_address
      unvalid_address_message
    elsif action == :uncovered_area
      uncovered_area_message
    elsif action == :unsubscription_request
      unsubscription_request_message
    elsif action == :unsubscription_notification
      unsubscription_notification_message
    elsif action == :unsubscription_error
      unsubscription_notification_message
    end

  end

  def send_meals_message
    @meals = Distribution.find_next_three(@coordinates, @from_time)

    meals_array = @meals.map do |meal|
      <<~HEREDOC
      #{meal[:name]} (#{meal[:time].in_time_zone("Paris").strftime("%e/%m/%y de %Hh%M")} à #{meal[:time].end_time.in_time_zone("Paris").strftime("%Hh%M")})
      #{meal[:distribution].display_name}
      #{meal[:distribution].address_1}, #{meal[:distribution].address_2 + ', ' unless meal[:distribution].address_2.blank?}#{meal[:distribution].postal_code} #{meal[:distribution].city}
      Métro #{meal[:distribution].stations.first.name}
      HEREDOC
    end

    <<~HEREDOC
    Repas solidaires #{"pour demain " if @action == :send_tomorrows_meals}près de \"#{@parsed_address}\" :#{' Aucun repas trouvé dans les prochaines 24h' if meals_array.empty?}

    #{meals_array.join("\n\n")}#{"\n\nRépondez STOP pour vous désabonner" if @action == :send_tomorrows_meals}
    HEREDOC
  end

  def send_specials_message
    @meals = Distribution.find_special(@coordinates, @from_time)

    meals_array = @meals.map do |meal|
      <<~HEREDOC
      #{meal[:distribution].display_name}
      #{meal[:time].in_time_zone("Paris").strftime("%e/%m/%y de %Hh%M")} à #{meal[:time].end_time.in_time_zone("Paris").strftime("%Hh%M")}
      #{meal[:distribution].address_1}, #{meal[:distribution].address_2 + ', ' unless meal[:distribution].address_2.blank?}#{meal[:distribution].postal_code} #{meal[:distribution].city}
      Métro #{meal[:distribution].stations.first.name}
      HEREDOC
    end

    <<~HEREDOC
    Repas solidaires du ramadan pour demain près de \"#{@parsed_address}\" :#{' Aucun repas trouvé dans les prochaines 24h' if meals_array.empty?}

    #{meals_array.join("\n\n")}\n\nRépondez STOP pour vous désabonner
    HEREDOC
  end

  def subscribe_message
    "Bienvenue sur SOS Food. Votre inscription de 30 jours à été prise en compte à l'adresse \"#{@parsed_address}\". Chaque soir, vous recevrez par SMS trois propositions de repas pour le lendemain. À bientôt."
  end

  def special_event_subscription_message
    "Bienvenue sur SOS Food. Votre inscription aux alertes du ramadan à été prise en compte à l'adresse \"#{@parsed_address}\". Chaque soir, vous recevrez par SMS trois propositions de repas pour le lendemain. À bientôt."
  end

  def unvalid_address_message
    "Nous n'avons pas compris l'adresse \"#{@parsed_address}\". Merci de nous renvoyer une adresse, un code postal, ou une station de métro. À bientôt, SOS Food."
  end

  def uncovered_area_message
    "L'adresse \"#{@parsed_address}\" n'est pas encore couverte par SOS Food."
  end

  def unsubscription_request_message
    "Votre abonnement à SOS Food a été annulé. À bientôt."
  end

  def unsubscription_notification_message
    "Votre abonnement de 30 jours à SOS Food est terminé. Si vous voulez continuer à recevoir nos messages, répondez avec le mot-clé \"alerte\" suivi d'une adresse, un code postal ou un arrêt de métro."
  end

  def unsubscription_notification_message
    "Aucun abonnement à SOS Food n'existe pour ce numéro de portable."
  end

  def parse(body)
    body_words = body.split
    keyword = body_words[0].downcase
    if ["alerte", "alert", "alerter"].include?(keyword) # Starts with alert
      original_address = body_words[1..-1].join(" ")
      @action = :subscribe
      verify_address(original_address)
    elsif ["ramadan", "ramadhan"].include?(keyword) # Starts with ramadan
      original_address = body_words[1..-1].join(" ")
      @action = :special_event_subscription
      verify_address(original_address)
    elsif keyword == "stop" # Unsubscribtion
      if @recipient.unsubscribe!
        @action = :unsubscription_request
      else
        @action = :unsubscription_error
      end
    else # Send meals for next 24h
      original_address = body
      @action = :send_next_meals
      verify_address(original_address)
    end
  end

  def verify_address(original_address)
    # Checks if it's a metro station
    if station = Station.similar(original_address)
      @parsed_address = "Métro #{station.name}"
      @coordinates = [station.latitude, station.longitude]

    # Checks if the address is valid
    elsif (location = Geocoder.search("#{original_address}, Île-de-France, France")[0]).nil?
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
