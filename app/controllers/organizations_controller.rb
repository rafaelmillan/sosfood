class OrganizationsController < ApplicationController
  skip_before_action :authenticate_organization!, only: :show

  def show
    @organization = Organization.find(params[:id])
    @distributions = @organization.distributions.where.not(latitude: nil, longitude: nil)
    @hash = Gmaps4rails.build_markers(@distributions) do |distribution, marker|
      marker.lat distribution.latitude
      marker.lng distribution.longitude
    end
    authorize @organization
  end

end
