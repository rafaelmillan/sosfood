class ChangeTextColorStringColumnToTextColorInLines < ActiveRecord::Migration[5.0]
  def change
    rename_column :lines, :text_color_string, :text_color
  end
end
