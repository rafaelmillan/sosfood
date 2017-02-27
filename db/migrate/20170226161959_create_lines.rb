class CreateLines < ActiveRecord::Migration[5.0]
  def change
    create_table :lines do |t|
      t.string :name
      t.string :text_color_string
      t.string :background_color

      t.timestamps
    end
  end
end
