class Organization < ApplicationRecord
  has_many :distributions, dependent: :destroy
  validates :name, presence: true
end
