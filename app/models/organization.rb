class Organization < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :distributions, dependent: :destroy
  has_many :recurrences, through: :distributions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
