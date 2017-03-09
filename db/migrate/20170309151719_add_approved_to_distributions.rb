class AddApprovedToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :approved, :boolean, default: false
  end
end
