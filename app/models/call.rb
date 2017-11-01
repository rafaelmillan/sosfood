class Call < ApplicationRecord
  belongs_to :recipient

  state_machine :state, initial: :welcoming do
    event :expect_language do
      transition welcoming: :expecting_language
    end

    event :expect_postal_code do
      transition expecting_language: :expecting_postal_code
    end

    event :mark_as_subscribed do
      transition expecting_postal_code: :subscribed
    end
  end

  def french!
    update(locale: "fr")
  end

  def english!
    update(locale: "en")
  end

  def french?
    locale == "fr"
  end

  def english?
    locale == "en"
  end
end
