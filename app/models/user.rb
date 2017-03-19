class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :organization
  has_many :distributions, dependent: :nullify

  validates :organization_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  after_create :send_welcome_email

  accepts_nested_attributes_for :organization

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
end
