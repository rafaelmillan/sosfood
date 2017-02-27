class RemoveStationFromDistributions < ActiveRecord::Migration[5.0]
  def change
    remove_column :distributions, :station
  end
end
