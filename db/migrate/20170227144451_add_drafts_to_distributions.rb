class AddDraftsToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :draft_id, :integer
    add_column :distributions, :published_at, :timestamp
    add_column :distributions, :trashed_at, :timestamp
  end
end
