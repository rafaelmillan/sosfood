class Station < ApplicationRecord
  has_many :stops, dependent: :destroy
  has_many :lines, through: :stops
  reverse_geocoded_by :latitude, :longitude
end
