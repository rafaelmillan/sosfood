class Message < ApplicationRecord
  belongs_to :recipient

  validates :content, presence: true
  validates :sent_by_user, inclusion: { in: [true, false] }
end
