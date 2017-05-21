class AddSpecialEventToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :special_event, :string
  end
end
