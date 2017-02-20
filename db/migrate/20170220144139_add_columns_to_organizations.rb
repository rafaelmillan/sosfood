class AddColumnsToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :first_name, :string
    add_column :organizations, :last_name, :string
    add_column :organizations, :organization_name, :string
    add_column :organizations, :phone_number, :integer
    add_column :organizations, :admin, :boolean
  end
end
