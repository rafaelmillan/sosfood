class CreateDistributions < ActiveRecord::Migration[5.0]
  def change
    create_table :distributions do |t|
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :station
      t.references :organization, foreign_key: true

      t.timestamps
    end
  end
end
