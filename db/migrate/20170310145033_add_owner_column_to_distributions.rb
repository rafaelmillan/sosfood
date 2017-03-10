class AddOwnerColumnToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_reference :distributions, :user, foreign_key: true
  end
end
