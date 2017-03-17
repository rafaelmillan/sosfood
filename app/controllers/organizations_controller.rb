class OrganizationsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  skip_before_action :authenticate_user!, only: :index
  skip_after_action :verify_policy_scoped, only: :index

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

  def index
    if params[:query].blank?
      @organizations = Organization.all.order(:name)
    else
      @organizations = Organization.where("name ILIKE ?", "%#{params[:query]}%").order(:name)
    end
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def create
    @organization = Distribution.new(name: params[:name])
    if @distribution.save
      current_user.organization = @organization
      current_user.save
      redirect_to users_path(current_user)
    else
      render :new
    end
  end
end
