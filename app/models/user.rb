class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :organization
  has_many :distributions

  validates :organization_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  accepts_nested_attributes_for :organization
end
