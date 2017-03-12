class Recipient < ApplicationRecord
  has_many :messages
  validates :phone_number, presence: true
  # validates :address, presence: true

  def subscribe!(latitude, longitude)
    self.subscribed = true
    self.latitude = latitude
    self.longitude = longitude
    self.save
  end
end
