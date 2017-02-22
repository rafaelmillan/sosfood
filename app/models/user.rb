class User < ApplicationRecord
  has_many :messages
  validates :phone_number, presence: true
  # validates :address, presence: true
end
