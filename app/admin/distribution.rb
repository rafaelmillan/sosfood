ActiveAdmin.register Distribution do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

  member_action :show do
      @distribution = Distribution.includes(versions: :item).find(params[:id])
      @versions = @distribution.versions
      @distribution = @distribution.versions[params[:version].to_i].reify if params[:version]
      show! #it seems to need this
  end

  member_action :history do
    @distribution = Distribution.find(params[:id])
    # @versions = @post.versions # <-- Sadly, versions aren't available in this scope, so use:
    @versions = PaperTrail::Version.where(item_type: 'Distribution', item_id: @distribution.id)
    render "layouts/history"
  end

  sidebar :versionate, :partial => "layouts/version", :only => :show

  permit_params(
    :name,
    :address_1,
    :address_2,
    :postal_code,
    :city,
    :country,
    :organization_id,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday,
    :event_type,
    :start_time,
    :end_time,
    :date,
    :status,
    :terms
  )
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  index do
    selectable_column
    column :id
    column :name
    column :address_1
    column :address_2
    column :postal_code
    column :city
    column :country
    column :latitude
    column :longitude
    column :organization_id
    column :monday
    column :tuesday
    column :wednesday
    column :thursday
    column :friday
    column :saturday
    column :sunday
    column :event_type
    column :start_time
    column :end_time
    column :date
    column :status
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :address_1
      f.input :address_2
      f.input :postal_code
      f.input :city
      f.input :country, as: :string, input_html: { value: 'France' }
      f.input :organization
      f.input :monday
      f.input :tuesday
      f.input :wednesday
      f.input :thursday
      f.input :friday
      f.input :saturday
      f.input :sunday
      f.input :event_type, as: :radio, collection: %w(regular once)
      f.input :start_time, as: :string
      f.input :end_time, as: :string
      f.input :date
      f.input :status, as: :radio, collection: %w(pending accepted declined)
      f.input :terms, input_html: { checked: 'checked' }
    end
    f.actions
  end

end
