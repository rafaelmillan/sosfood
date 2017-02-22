class OrganizationsController < ApplicationController
  skip_before_action :authenticate_organization!, only: :show

  def show
    @organization = Organization.find(params[:id])
    authorize @organization
    @distribution = @organization.distributions
  end

end
