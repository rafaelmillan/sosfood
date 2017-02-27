class RemoveOrganizationFromDistribution < ActiveRecord::Migration[5.0]
  def change
    remove_column :distributions, :organization_id
  end
end
