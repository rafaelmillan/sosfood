class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.text :content
      t.boolean :sent_by_user
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
