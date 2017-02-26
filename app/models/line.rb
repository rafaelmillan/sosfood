class Line < ApplicationRecord
  has_many :stops, dependent: :destroy
end
