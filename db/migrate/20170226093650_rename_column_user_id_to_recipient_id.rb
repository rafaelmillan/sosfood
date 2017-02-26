class RenameColumnUserIdToRecipientId < ActiveRecord::Migration[5.0]
  def change
    rename_column :messages, :user_id, :recipient_id
  end
end
