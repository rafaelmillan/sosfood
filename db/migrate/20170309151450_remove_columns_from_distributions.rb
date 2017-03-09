class RemoveColumnsFromDistributions < ActiveRecord::Migration[5.0]
  def change
    remove_column :distributions, :draft_id
    remove_column :distributions, :published_at
    remove_column :distributions, :trashed_at
  end
end
