class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :phone_number
      t.boolean :subscribed
      t.string :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
