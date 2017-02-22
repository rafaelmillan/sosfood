class Distribution < ApplicationRecord
  belongs_to :organization
  validates :address_1, presence: true
  validates :postal_code, presence: true
  validates :station, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :recurrence, presence: true

  geocoded_by :address
  after_validation :geocode, if: (:address_1_changed? || :postal_code_changed? || :city_changed? || :country_changed? )

  attr_accessor :date, :frequency, :start_time, :end_time, :weekdays, :monthdates

  def address
    [address_1, postal_code, city, country].compact.join(', ')
  end

end
