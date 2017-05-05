class AddSubscriptionDaysToRecipients < ActiveRecord::Migration[5.0]
  def change
    add_column :recipients, :alerts_count, :integer, default: 0
  end
end
