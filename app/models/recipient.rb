class Recipient < ApplicationRecord
  has_many :messages, dependent: :nullify
  validates :phone_number, presence: true
  # validates :address, presence: true

  def subscribe!(coordinates, address)
    self.subscribed = true
    self.latitude = coordinates[0]
    self.longitude = coordinates[1]
    self.address = address
    self.save
  end

  def unsubscribe!
    if self.subscribed
      self.update(subscribed: false)
      return true
    else
      return false
    end
  end
end
