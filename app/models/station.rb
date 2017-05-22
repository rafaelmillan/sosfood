class Station < ApplicationRecord
  has_many :stops, dependent: :destroy
  has_many :lines, through: :stops
  reverse_geocoded_by :latitude, :longitude

  def self.similar(station_a)
    results = Station.all.map do |station_b|
      similarity = ActiveSupport::Inflector.transliterate(station_a.downcase)
        .similar(ActiveSupport::Inflector.transliterate(station_b.name.downcase))
      { station: station_b, similarity: similarity }
    end

    return nil if results.empty?
    results.sort! { |o1, o2| o2[:similarity] <=> o1[:similarity] } if results.count > 1
    results.first[:similarity] > 75 ? results.first[:station] : nil
  end
end
