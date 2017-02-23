require 'csv'

Distribution.destroy_all
Organization.destroy_all

csv_options = { col_sep: ',', headers: :first_row }
filepath = File.open(File.join(Rails.root, 'db', 'import.csv'))

CSV.foreach(filepath, csv_options) do |row|
  if Organization.find_by(organization_name: row['Asso name']).nil?
    org = Organization.new(
      email: "#{row['Asso name'].gsub(/[^0-9A-Za-z]/, '').downcase}@sos-food.org",
      password: (0...8).map { (65 + rand(26)).chr }.join,
      organization_name: row['Asso name']
    )
    org.save!
  end
  schedule = IceCube::Schedule.new(Time.parse(row['Start time']), end_time: Time.parse(row['End time']))
    days = []
    days << :monday if row["Lu"] == "Y"
    days << :tuesday if row["Ma"] == "Y"
    days << :wednesday if row["Me"] == "Y"
    days << :thursday if row["Je"] == "Y"
    days << :friday if row["Ve"] == "Y"
    days << :saturday if row["Sa"] == "Y"
    days << :sunday if row["Su"] == "Y"
    schedule.rrule(IceCube::Rule.weekly.day(days))
    dis = Distribution.new(
      name: row['Distribution name'],
      address_1: row['Addresse ligne 1'],
      postal_code: row['Postal Code'],
      city: row['City'],
      country: "France",
      station: row['Transports'],
      organization: Organization.find_by(organization_name: row['Asso name']),
      recurrence: schedule.to_yaml
    )
  dis.save!
end
