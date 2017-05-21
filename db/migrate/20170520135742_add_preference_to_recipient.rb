class AddPreferenceToRecipient < ActiveRecord::Migration[5.0]
  def change
    add_column :recipients, :preference, :string
  end
end
