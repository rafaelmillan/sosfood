class Recipient < ApplicationRecord
  has_many :messages, dependent: :nullify
  validates :phone_number, presence: true
  # validates :address, presence: true

  def subscribe!(coordinates, address, preference = nil)
    self.update(
      subscribed: true,
      latitude: coordinates[0],
      longitude: coordinates[1],
      address: address,
      preference: preference
    )
  end

  def unsubscribe!
    if self.subscribed
      self.update(subscribed: false, alerts_count: 0)
      return true
    else
      return false
    end
  end
end
