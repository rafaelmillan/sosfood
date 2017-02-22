Distribution.destroy_all
Organization.destroy_all

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

addresses = [
  {
    address_1: "93 rue des Couronnes",
    postal_code: "75020",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "16 Villa Gaudelet",
    postal_code: "75011",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "17 avenue des Gobelins",
    postal_code: "7505",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "11 rue Victor Cousin",
    postal_code: "75005",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "4 rue Martel",
    postal_code: "75010",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "8 rue Edouard Lockroy",
    postal_code: "75011",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "6 avenue de Verdun",
    postal_code: "75010",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "7 place de la Bataille de Stalingrad",
    postal_code: "75019",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "20 rue Saint Marc",
    postal_code: "75002",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "12 rue de l'Asile Popincourt",
    postal_code: "75011",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "208 rue Saint-Maur",
    postal_code: "75010",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "83 Rue de Reuilly",
    postal_code: "75012",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "31 rue Mathis",
    postal_code: "75019",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "104 rue Ordener",
    postal_code: "75018",
    city: "Paris",
    country: "France"
  },
  {
    address_1: "24 boulevard Arago",
    postal_code: "75013",
    city: "Paris",
    country: "France"
  }
]

i = 0

Organization.all.each do |org|
  3.times do
    schedule = IceCube::Schedule.new
    weekdays = (0..3).to_a
    weekend = (4..6).to_a
    schedule.rrule(IceCube::Rule.weekly.day(weekdays.sample, weekend.sample))
    dis = Distribution.new(
      name: Faker::Company.name,
      address_1: addresses[i][:address_1],
      postal_code: addresses[i][:postal_code],
      city: addresses[i][:city],
      country: addresses[i][:country],
      station: Faker::Address.city,
      organization: org,
      recurrence: schedule.to_yaml
    )
    dis.save!
    i += 1
  end
end
