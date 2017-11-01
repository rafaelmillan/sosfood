class CreateCalls < ActiveRecord::Migration[5.0]
  def change
    create_table :calls do |t|
      t.string :state
      t.string :locale
      t.integer :callr_id, limit: 8
      t.references :recipient, foreign_key: true

      t.timestamps
    end
  end
end
