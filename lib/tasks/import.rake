namespace :import do
  desc "Import public transport stations and lines"
  task :public_transport => :environment do

    require 'csv'

    Station.destroy_all
    Line.destroy_all
    Stop.destroy_all

    lines_csv_options = { col_sep: ',', headers: :first_row }
    lines_filepath = File.open(File.join(Rails.root, 'lib', 'assets', 'lines.csv'))

    CSV.foreach(lines_filepath, lines_csv_options) do |row|
      Line.create!(
        name: row["name"],
        text_color: row["text_color"],
        background_color: row["bg_color"]
      )
    end

    stations_csv_options = { col_sep: ';', headers: :first_row }
    stations_filepath = File.open(File.join(Rails.root, 'lib', 'assets', 'stations.csv'))

    CSV.foreach(stations_filepath, stations_csv_options) do |row|
      if Station.find_by(name: row["NOMLONG"]).nil?
        coordinates = row['Geo Point'].split(", ")
        station = Station.new(name: row["NOMLONG"],
          latitude: coordinates[0],
          longitude: coordinates[1]
        )
        station.save!
      else
        station = Station.find_by(name: row["NOMLONG"])
      end
      Stop.create!(
        station: station,
        line: Line.find_by(name: row["LIGNE"])
      )
    end

  end
end


