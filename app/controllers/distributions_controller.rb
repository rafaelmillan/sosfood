class DistributionsController < ApplicationController
  before_action :set_distribution, only: [:show, :edit, :update, :destroy, :accept, :decline]
  skip_before_action :authenticate_user!, only: [:search, :show, :explore]
  skip_after_action :verify_authorized, only: [:search, :show, :explore]


  def index
    @distributions = policy_scope(Distribution)
  end

  def show
    @alert_message = " You are viewing #{@distribution.name}"
    @distribution_coordinates = { lat: @distribution.latitude, lng: @distribution.longitude }
    @distributions_around = Distribution.near([@distribution.latitude, @distribution.longitude], 5, units: :km)[0..5].delete_if { |d| d == @distribution }

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
    if @distribution.save
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @distribution.destroy
    redirect_to distributions_path
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

    @results = Distribution.near(coordinates, 5).reject { |d| d.latitude.nil? || d.longitude.nil? }
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

  def generate_recurrence
    now = Time.now

    freq = params[:distribution][:frequency]

    start_hour = params[:distribution][:start_time][0..1]
    start_min = params[:distribution][:start_time][3..4]

    end_hour = params[:distribution][:end_time][0..1]
    end_min = params[:distribution][:end_time][3..4]

    day = params[:distribution][:date][0..1]
    month = params[:distribution][:date][3..4]
    year = params[:distribution][:date][6..9]

    weekdays = params[:distribution][:weekdays]

    if freq == "once"
      time = Time.new(year, month, day, start_hour, start_min)
      duration = Time.new(year, month, day, end_hour, end_min) - time
      schedule = IceCube::Schedule.new(time, duration: duration)
    elsif freq == "regular"
      time = Time.new(now.year, now.month, now.day, start_hour, start_min)
      duration = Time.new(now.year, now.month, now.day, end_hour, end_min) - time
      schedule = IceCube::Schedule.new(time, duration: duration)
      days = []
      days << :monday if weekdays.include?("mon")
      days << :tuesday if weekdays.include?("tue")
      days << :wednesday if weekdays.include?("wed")
      days << :thursday if weekdays.include?("thu")
      days << :friday if weekdays.include?("fri")
      days << :saturday if weekdays.include?("sat")
      days << :sunday if weekdays.include?("sun")
      schedule.rrule(IceCube::Rule.weekly.day(days))
    end

    return schedule.to_yaml
  end

  def set_recurrence
    schedule = @distribution.schedule
    frequency = schedule.rrules.first.to_hash[:rule_type]
    days = schedule.rrules.first.to_hash[:validations][:day]
    recurrence = {}
    if frequency == "IceCube::WeeklyRule"
      recurrence[:weekly] = true
      recurrence[:days] = []
      [:sun, :mon, :tue, :wed, :thu, :fri, :sat].each_with_index do |day, i|
        recurrence[:days] << day if days.include? i
      end
    end
    recurrence[:start_min] = schedule.start_time.strftime("%Hh%M")
    recurrence[:end_time] = schedule.end_time.strftime("%Hh%M")
    return recurrence
  end

end
