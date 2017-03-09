class AddColumnsToDistribution < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :monday, :boolean
    add_column :distributions, :tuesday, :boolean
    add_column :distributions, :wednesday, :boolean
    add_column :distributions, :thursday, :boolean
    add_column :distributions, :friday, :boolean
    add_column :distributions, :saturday, :boolean
    add_column :distributions, :sunday, :boolean
    add_column :distributions, :type, :string
    add_column :distributions, :start_time, :datetime
    add_column :distributions, :end_time, :datetime
    add_column :distributions, :date, :date
  end
end
