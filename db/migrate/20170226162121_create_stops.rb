class CreateStops < ActiveRecord::Migration[5.0]
  def change
    create_table :stops do |t|
      t.references :station, foreign_key: true
      t.references :line, foreign_key: true

      t.timestamps
    end
  end
end
