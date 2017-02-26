class Line < ApplicationRecord
  has_many :stops, dependent: :destroy
  has_many :stations, through: :stops
end
