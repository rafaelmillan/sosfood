require 'csv'

Distribution.destroy_all
puts "Cleaning distributions..."
Organization.destroy_all
puts "Cleaning organizations..."
User.destroy_all
puts "Cleaning users..."

puts "Seeding distributions and organizations..."
csv_options = { col_sep: ',', headers: :first_row }
filepath = File.open(File.join(Rails.root, 'db', 'import.csv'))

CSV.foreach(filepath, csv_options) do |row|
  if Organization.find_by(name: row['Asso name']).nil?
    org = Organization.new(
      name: row['Asso name']
    )
    org.save!
  end
  dis = Distribution.new(
    name: row['Distribution name'],
    address_1: row['Addresse ligne 1'],
    postal_code: row['Postal Code'],
    city: row['City'],
    country: "France",
    organization: Organization.find_by(name: row['Asso name']),
    monday: row["Lu"] == "Y",
    tuesday: row["Ma"] == "Y",
    wednesday: row["Me"] == "Y",
    thursday: row["Je"] == "Y",
    friday: row["Ve"] == "Y",
    saturday: row["Sa"] == "Y",
    sunday: row["Di"] == "Y",
    event_type: "weekly",
    start_time: Time.parse(row['Start time']),
    end_time: Time.parse(row['End time'])
  )
  dis.save!
end
