class ChangeColumnNameTypeToEventTypeInDistributions < ActiveRecord::Migration[5.0]
  def change
    rename_column :distributions, :type, :event_type
  end
end
