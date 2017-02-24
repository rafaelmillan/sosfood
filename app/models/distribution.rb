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

  def self.find_next_three(coordinates)
    distributions = Distribution.near(coordinates)

    meals = set_meal_hashes

    meals.each do |meal|
      distributions.each do |dis|
        schedule = IceCube::Schedule.from_yaml(dis.recurrence)
        if schedule.occurs_between?(meal[:min_time], meal[:max_time])
          meal[:distribution] = dis
          meal[:time] = schedule.next_occurrence(meal[:min_time])
        end
        break unless meal[:distribution] == nil
      end
    end

    meals.sort_by! { |meal| meal[:time] }
    p meals

    return meals
  end

  def self.find_by_date(coordinates, date)
    distributions = Distribution.near(coordinates)
    results = []

    distributions.each do |dis|
      schedule = IceCube::Schedule.from_yaml(dis.recurrence)
      if schedule.occurs_on?(date)
        schedule.occurrences_between(date.to_time, date.to_time + 1.day).each do |o|
          results << {
            occurrence: o,
            distribution: dis
          }
        end
      end
    end

    return results

  end

  private

  private_class_method def self.set_meal_hashes
    now = Time.now

    breakfast_min = Time.new(now.year, now.month, now.day, 06, 00)
    breakfast_max = Time.new(now.year, now.month, now.day, 11, 00)
    lunch_min = Time.new(now.year, now.month, now.day, 11, 00)
    lunch_max = Time.new(now.year, now.month, now.day, 15, 00)
    dinner_min = Time.new(now.year, now.month, now.day, 15, 00)
    dinner_max = Time.new(now.year, now.month, now.day, 23, 00)

    if now.hour > 10 && now.hour < 12
      breakfast_min += 1.day
      breakfast_max += 1.day
    elsif now.hour < 19
      breakfast_min += 1.day
      breakfast_max += 1.day
      lunch_min += 1.day
      lunch_max += 1.day
    elsif now.hour >= 19
      breakfast_min += 1.day
      breakfast_max += 1.day
      lunch_min += 1.day
      lunch_max += 1.day
      dinner_min += 1.day
      dinner_max += 1.day
    end

    [
      {
        min_time: breakfast_min,
        max_time: breakfast_max,
        name: "Petit déjeuner",
      },
      {
        min_time: lunch_min,
        max_time: lunch_max,
        name: "Déjeuner",
      },
      {
        min_time: dinner_min,
        max_time: dinner_max,
        name: "Dinner"
      }
    ]
  end
end
