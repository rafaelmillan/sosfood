class Distribution < ApplicationRecord
  belongs_to :organization
  validates :address_1, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :event_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  geocoded_by :address
  after_validation :geocode, if: (:address_1_changed? || :postal_code_changed? || :city_changed? || :country_changed? )

  after_validation :send_email if :status_changed?

  attr_accessor :date, :frequency, :weekdays, :monthdates, :address

  def address
    [address_1, postal_code, city, country].compact.join(', ')
  end

  def schedule
    schedule = IceCube::Schedule.new(start_time, end_time: end_time)
    days = []
    days << :monday if monday
    days << :tuesday if tuesday
    days << :wednesday if wednesday
    days << :thursday if thursday
    days << :friday if friday
    days << :saturday if saturday
    days << :sunday if sunday
    schedule.rrule(IceCube::Rule.weekly.day(days))
    return schedule
  end

  def mon?
    monday
  end

  def tue?
    tuesday
  end

  def wed?
    wednesday
  end

  def thu?
    thursday
  end

  def fri?
    friday
  end

  def sat?
    saturday
  end

  def sun?
    sunday
  end

  def display_name
    if name.blank?
      organization.name
    else
      name
    end
  end

  def stations
    Station.near([latitude, longitude], 0.5)
  end

  def accept!
    self.status = "accepted"
    self.save
  end

  def decline!
    self.status = "declined"
    self.save
  end

  def self.find_next_three(coordinates)
    distributions = Distribution.near(coordinates).where(status: "accepted")

    meals = set_meal_hashes

    meals.each do |meal|
      distributions.each do |dis|
        schedule = dis.schedule
        if schedule.occurs_between?(meal[:min_time], meal[:max_time])
          meal[:distribution] = dis
          # The -1 avoids mismathing distributions that start at exactly the same time as the min_time
          meal[:time] = schedule.next_occurrence(meal[:min_time] - 1)
        end
        break unless meal[:distribution] == nil
      end
    end

    meals.select! { |meal| meal.key? :time }

    meals.sort_by! { |meal| meal[:time] }

    return meals
  end

  def self.find_by_date(coordinates, date)
    distributions = Distribution.near(coordinates).where(status: "accepted")
    results = []

    distributions.each do |dis|
      schedule = dis.schedule
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

  def send_email
    p "Hello!!!!!!!!!!!!!!"
    p status_changed?
    p changes
    p status_change == ["pending", "accepted"]
    if status_change == ["pending", "accepted"]
      DistributionMailer.accept(User.last, self).deliver_now
    elsif status_change == ["pending", "declined"]
      DistributionMailer.decline(User.last, self).deliver_now
    end
  end
end
