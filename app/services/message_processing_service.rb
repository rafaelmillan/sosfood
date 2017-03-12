class MessageProcessingService
  def process(body, test_mode)

    action = set_sms_type(body)

    result = {
      body: generate_body(action),
      action: action
    }

    if [:subscribe, :send_meals, :uncovered_area].include? action
      result[:latitude] = @coordinates[0]
      result[:longitude] = @coordinates[1]
      result[:address] = @location.address
    end

    if test_mode == false && action == :send_meals
      @meals.each do |meal|
        Referral.create(
          address: @location.address,
          latitude: @coordinates[0],
          longitude: @coordinates[1],
          distribution: meal[:distribution]
        )
      end
    end

    return result

  end

  private

  def set_sms_type(body)
    # Subscription
    body_words = body.split
    keyword = body_words[0].downcase
    if keyword == "alerte" || keyword == "alert" # Starts with alert
      @original_address = body_words[1..-1].join(" ")
      verify_address(@original_address, :subscribe)
    else # Send meals for next 24h
      @original_address = body
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
      @meals = Distribution.find_next_three(@coordinates)

      meals_array = @meals.map do |meal|
"#{meal[:name]} - #{meal[:time].strftime("%e/%m/%y de %Hh%M")} à #{meal[:time].end_time.strftime("%Hh%M")}
#{meal[:distribution].display_name}
#{meal[:distribution].address_1}, #{meal[:distribution].postal_code} #{meal[:distribution].city}
Métro #{meal[:distribution].stations.first.name}"
      end

"[SOS Food est en phase de test, les repas proposés sont donnés à titre indicatif.]
Repas solidaires près de \"#{@location.address}\" :#{' Aucun repas trouvé dans les prochaines 24h' if meals_array.empty?}

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
