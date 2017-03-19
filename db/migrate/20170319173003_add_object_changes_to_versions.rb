class AddObjectChangesToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :object_changes, :string
  end
end
