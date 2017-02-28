class Organization < ApplicationRecord
  has_many :distributions, dependent: :destroy
  has_many :users, dependent: :nullify
  validates :name, presence: true, uniqueness: true
  accepts_nested_attributes_for :users
end
