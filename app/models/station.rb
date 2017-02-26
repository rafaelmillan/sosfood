class Station < ApplicationRecord
  has_many :stops, dependent: :destroy
end
