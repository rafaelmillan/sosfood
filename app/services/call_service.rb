class CallService
  include LocationSupport

  def initialize(call)
    @call = call
  end

  def generate_response(command)
    @command = command

    if @call.welcoming?
      @call.expect_language
      language_voice
    elsif @call.expecting_language?
      set_call_language
    elsif @call.expecting_postal_code?
      subscribe_recipient
    elsif @call.subscribed?
      { command: "hungup" }
    end
  end

  private

  def set_call_language
    if @command == 1
      @call.french!
      @call.expect_postal_code
      postal_code_voice
    elsif @command == 2
      @call.english!
      @call.expect_postal_code
      postal_code_voice
    else
      unkown_language_voice
    end
  end

  def subscribe_recipient
    location = find_location(@command)

    if location_covered?(location)
      @call.recipient.subscribe!(location.coordinates, location.formatted_address)
      notify_subscription
      @call.mark_as_subscribed
      subscribtion_successful_voice
    else
      subscribtion_unsuccessful_voice
    end
  end

  def notify_subscription
    MessageService.new(@call.recipient).send_from_action(action: :subscribe)
  end

  def language_voice
    voice_response(
      text: "Bienvenue sur S.O.S. Food. Pour français, tapez 1. For English, press tou",
      locale: :fr,
      digits: 1
    )
  end

  def postal_code_voice
    if @call.french?
      voice_response(
        text: "S.O.S. Food est un service qui vous informe des associations qui servent des repas solidaires autour de vous. Pour vous abonner à nos alertes SMS gratuites, tapez les 5 chiffres de votre code postal, suivi de la touche dièse.",
        locale: :fr,
        digits: 5
      )
    elsif @call.english?
      voice_response(
        text: "S.O.S. Food informs you of charities that serve free meals around your location. To subscribe to our free SMS alertes, enter the 5 digits of your postal code, followed by the pound key.",
        locale: :en,
        digits: 5
      )
    end
  end

  def subscribtion_successful_voice
    if @call.french?
      voice_response(
        text: "Nous avons bien reçu votre demande, vous recevrez un SMS tous les soirs avec des adresses où vous pouvez manger le lendemain. À bientôt.",
        locale: :fr
      )
    elsif @call.english?
      voice_response(
        text: "We have received your request. Every evening, you will receive an SMS with addresses of places that serve free meals the next day. Good-bye.",
        locale: :en
      )
    end
  end

  def subscribtion_unsuccessful_voice
    if @call.french?
      voice_response(
        text: "Nous n'avons pas pu vous abonner à notre service. Actuellement, nous couvrons uniquement Paris et sa petite couronne. Veuillez taper les 5 chiffres de votre code postal, suivi de la touche dièse.",
        locale: :fr,
        digits: 5
      )
    elsif @call.english?
      voice_response(
        text: "We were not able to subscribe you to our SMS. Right now, only Paris and its surroundings are covered by our service. Enter the 5 digits of your postal code, followed by the pound key.",
        locale: :en,
        digits: 5
      )
    end
  end

  def unkown_language_voice
    voice_response(
      text: "Désolé, nous n'avons pas compris votre saisie. Pour français, tapez 1. For English, press tou",
      locale: :fr,
      digits: 1
    )
  end

  def voice_response(text:, locale:, digits: 1)
    {
      command: "read",
      command_id: 1,
      params: {
        media_id: voice(locale) + text,
        max_digits: digits,
        attempts: 1,
        timeout_ms: 10000
      }
    }
  end

  def voice(locale)
    if locale == :fr
      "TTS|TTS_FR-FR_AUDREY|"
    elsif locale == :en
      "TTS|TTS_EN-GB_DANIEL|"
    end
  end
end
