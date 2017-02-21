class AddCoordinatesToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :latitude, :float
    add_column :distributions, :longitude, :float
  end
end
