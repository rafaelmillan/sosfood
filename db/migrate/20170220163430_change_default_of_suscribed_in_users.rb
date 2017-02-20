class ChangeDefaultOfSuscribedInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:users, :subscribed, false)
  end
end
