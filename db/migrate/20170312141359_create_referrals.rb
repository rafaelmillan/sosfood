class CreateReferrals < ActiveRecord::Migration[5.0]
  def change
    create_table :referrals do |t|
      t.string :address
      t.float :latitude
      t.float :longitude
      t.references :distribution, foreign_key: true

      t.timestamps
    end
  end
end
