class Station < ApplicationRecord
  has_many :stops, dependent: :destroy
  has_many :lines, through: :stops
  reverse_geocoded_by :latitude, :longitude

  def self.similar(station_a)
    Station.all.find do |station_b|
      station_a = ActiveSupport::Inflector.transliterate(station_a.downcase)
      station_b = ActiveSupport::Inflector.transliterate(station_b.name.downcase)
      station_a.similar(station_b) > 90
    end
  end
end
