Faker::UniqueGenerator.clear

5.times do
  org = Organization.new(
    email: Faker::Internet.unique.email,
    password: 123456,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    organization_name: Faker::Company.name,
    phone_number: 123456
  )
  org.save!
end

Organization.all.each do |org|
  3.times do
    schedule = IceCube::Schedule.new
    weekdays = (0..3).to_a
    weekend = (4..6).to_a
    schedule.rrule(IceCube::Rule.weekly.day(weekdays.sample, weekend.sample))
    dis = Distribution.new(
      address_1: Faker::Address.street_address,
      postal_code: Faker::Address.postcode,
      city: "Paris",
      country: "France",
      station: Faker::Address.city,
      organization: org,
      recurrence: schedule.to_yaml
    )
    dis.save!
  end
end
