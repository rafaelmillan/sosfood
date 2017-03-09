class DropDraftsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :drafts
  end
end
