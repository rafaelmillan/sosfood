class AddPausedToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :paused, :boolean, default: false
  end
end
