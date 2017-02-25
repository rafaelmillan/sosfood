class OrganizationsController < ApplicationController
  skip_before_action :authenticate_organization!, only: :show

  def show
    @organization = Organization.find(params[:id])
    @distributions = @organization.distributions.where.not(latitude: nil, longitude: nil)

    @hash = Gmaps4rails.build_markers(@distributions) do |distribution, marker|
      marker.lat distribution.latitude
      marker.lng distribution.longitude
      marker.infowindow "<h4>#{distribution.name}</h4><p>#{distribution.address_1}</p><p>#{distribution.postal_code}</p>"
      end
      # @recurrence = @organization.distributions.each do |dis|
      # dis.start_time
    authorize @organization
  end
end
