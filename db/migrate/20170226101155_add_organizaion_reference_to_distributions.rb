class AddOrganizaionReferenceToDistributions < ActiveRecord::Migration[5.0]
  def change
    add_reference :distributions, :organization, index: true
  end
end
