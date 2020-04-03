class AddCovid19StatusToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :covid_19_status, :integer, default: 0, null: false
  end
end
