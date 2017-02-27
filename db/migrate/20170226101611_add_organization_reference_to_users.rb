class AddOrganizationReferenceToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :organization, index: true
    add_column :users, :admin, :boolean
  end
end
