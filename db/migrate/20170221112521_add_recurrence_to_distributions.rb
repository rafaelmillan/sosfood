class AddRecurrenceToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :recurrence, :string
  end
end
