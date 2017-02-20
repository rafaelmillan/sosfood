class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :sent_by_user, presence: true
end
