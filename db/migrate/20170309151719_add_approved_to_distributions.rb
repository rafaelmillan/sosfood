class AddApprovedToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :status, :string, default: "pending"
  end
end
