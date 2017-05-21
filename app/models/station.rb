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

    if results.empty?
      return nil
    elsif results.count > 1
      # Orders stations by similarity
      results.sort! { |o1, o2| o2[:similarity] <=> o1[:similarity] }
    end

    if results.first[:similarity] > 75
      return results.first[:station]
    else
      return nil
    end
  end
end
