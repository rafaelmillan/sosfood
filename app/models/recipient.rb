class Recipient < ApplicationRecord
  has_many :messages, dependent: :nullify
  validates :phone_number, presence: true
  # validates :address, presence: true

  def subscribe!(latitude, longitude, address)
    self.subscribed = true
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.save
  end
end
