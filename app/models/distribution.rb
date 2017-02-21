class Distribution < ApplicationRecord
  belongs_to :organization
  validates :address_1, presence: true
  validates :postal_code, presence: true
  validates :station, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :recurrence, presence: true
end
