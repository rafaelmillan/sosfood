class DistributionsController < ApplicationController
  before_action :set_distribution, only: [:show, :edit, :update, :destroy, :accept, :decline]
  skip_before_action :authenticate_user!, only: [:search, :show, :explore]
  skip_after_action :verify_authorized, only: [:search, :show, :explore]

  def show
    @alert_message = " You are viewing #{@distribution.name}"
    @distribution_coordinates = { lat: @distribution.latitude, lng: @distribution.longitude }
    @distributions_around = Distribution.near([@distribution.latitude, @distribution.longitude], 5, units: :km).where(status: "accepted").where.not(id: @distribution.id)[0..4]

    @hash = Gmaps4rails.build_markers(@distribution) do |distribution, marker|
      marker.lat distribution.latitude
      marker.lng distribution.longitude
      marker.infowindow "<h4>#{distribution.name}</h4><p>#{distribution.address_1}</p><p>#{distribution.postal_code}</p>"
    end

    @recurrence = @distribution.schedule
  end

  def new
    @distribution = Distribution.new
    authorize @distribution
  end

  def create
    @distribution = Distribution.new(distribution_params)
    @distribution.organization = current_user.organization
    @distribution.user = current_user
    authorize @distribution

    if @distribution.save
      redirect_to distribution_path(@distribution)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @distribution.assign_attributes(distribution_params)
    @distribution.user = current_user
    if @distribution.save
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @distribution.destroy
    redirect_to user_path(current_user)
  end

  def search
    begin
      @date = Date.parse(params[:date])
    rescue ArgumentError
      @date = Date.today
    end
    @address = params[:address]
    coordinates = [params[:lat].to_f, params[:lon].to_f]
    @results = Distribution.find_by_date(coordinates, @date)

    @distributions = @results.map { |r| r[:distribution] }
    @distributions.reject! { |d| d.latitude.nil? || d.longitude.nil? }
    # @distributions = Distribution.where.not(latitude: nil, longitude: nil)
    @hash = Gmaps4rails.build_markers(@distributions) do |distribution, marker|
      marker.lat distribution.latitude
      marker.lng distribution.longitude
      marker.infowindow "<h4>#{distribution.organization.name}</h4><p>#{distribution.address_1}</p><p>#{distribution.postal_code}</p>"
    end
  end

  def explore
    @address = params[:address]
    coordinates = [params[:lat].to_f, params[:lon].to_f]

    @results = Distribution.near(coordinates, 5).where(status: "accepted").reject { |d| d.latitude.nil? || d.longitude.nil? }
    @hash = Gmaps4rails.build_markers(@results) do |distribution, marker|
      marker.lat distribution.latitude
      marker.lng distribution.longitude
      marker.infowindow "<h4>#{distribution.organization.name}</h4><p>#{distribution.address_1}</p><p>#{distribution.postal_code}</p>"
    end
  end

  def accept
    @distribution.accept!
    redirect_to user_path(current_user)
  end

  def decline
    @distribution.decline!
    redirect_to user_path(current_user)
  end

  private

  def set_distribution
    @distribution = Distribution.find(params[:id])
    authorize @distribution
  end

  def distribution_params
    params.require(:distribution).permit(
      :name,
      :address_1,
      :address_2,
      :postal_code,
      :city,
      :country,
      :date,
      :address,
      :event_type,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :sunday,
      :start_time,
      :end_time
    )
  end

end
