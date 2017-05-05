class AddTermsToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_column :distributions, :terms, :boolean
  end
end
