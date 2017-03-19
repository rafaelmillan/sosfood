class Distribution < ApplicationRecord
  belongs_to :organization
  belongs_to :user # Owner of the distribution (receives notifications)
  has_many :referrals, dependent: :nullify

  has_paper_trail

  validates :organization, presence: true
  validates :address_1, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :event_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :date, presence: true, if: "event_type == 'once'"
  validates_acceptance_of :terms, accept: true, allow_nil: false

  validate :validate_weekdays, if: "event_type == 'regular'"
  validate :end_time_greater_than_start_date, unless: "start_time.blank? || end_time.blank?"


  geocoded_by :address
  after_validation :geocode, if: (:address_1_changed? || :postal_code_changed? || :city_changed? || :country_changed? )

  around_save :send_review_email if :status_changed?

  attr_accessor :address

  def address
    [address_1, postal_code, city, country].compact.reject(&:empty?).join(', ')
  end

  def schedule
    if event_type == "regular"
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
    elsif event_type == "once"
      schedule_start = date + start_time.seconds_since_midnight.seconds
      schedule_end = date + end_time.seconds_since_midnight.seconds
      schedule = IceCube::Schedule.new(schedule_start, end_time: schedule_end)
    end
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
    now = Time.current.in_time_zone("Paris")

    breakfast_min = now.midnight + 6.hours
    breakfast_max = now.midnight + 10.hours + 59.minutes
    lunch_min = now.midnight + 11.hours
    lunch_max = now.midnight + 14.hours + 59.minutes
    dinner_min = now.midnight + 15.hours
    dinner_max = now.midnight + 23.hours

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

  def send_review_email
    if status_change == ["pending", "accepted"]
      yield
      DistributionMailer.accept(self.user, self).deliver_now unless self.user.nil?
    elsif status_change == ["pending", "declined"]
      yield
      DistributionMailer.decline(self.user, self).deliver_now unless self.user.nil?
    elsif status == "pending"
      yield
      DistributionMailer.create(self.user, self).deliver_now unless self.user.nil?
      DistributionMailer.review(self).deliver_now
    else
      yield
    end
  end

  def validate_weekdays
    errors.add(:event_type, "Sélectionnez au moins un jour de la semaine.") unless monday || tuesday || wednesday || thursday || friday || saturday || sunday
  end

  def end_time_greater_than_start_date
    if end_time < start_time
      errors.add(:end_time, "L'heure de fin doit être supérieure à l'heure de début.")
    end
  end
end
