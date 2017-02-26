class RenameUsersToRecipients < ActiveRecord::Migration[5.0]
  def change
    rename_table :users, :recipients
  end
end
