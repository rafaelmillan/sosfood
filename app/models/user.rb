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
  after_create :subscribe_to_newsletter

  accepts_nested_attributes_for :organization

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end

  def subscribe_to_newsletter
    SubscribeToNewsletterService.new(self).call
  end
end
