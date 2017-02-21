class DistributionsController < ApplicationController
  before_action :set_distribution, only: [:show, :edit, :update, :destroy]

  def index
    @distributions = Distribution.all
  end

  def show
    @recurrence = IceCube::Schedule.from_yaml(@distribution.recurrence) unless @distribution.recurrence.nil?
  end

  def new
    @distribution = Distribution.new
  end

  def create
    @distribution = Distribution.create(distribution_params)
    @distribution.organization = current_organization
    if @distribution.save
      redirect_to distribution_path(@distribution)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @distribution = Distribution.update(distribution_params)
    if @distribution.save
      redirect_to distribution_path(@distribution)
    else
      render :edit
    end
  end

  def destroy
    @distribution.destroy
  end

  private

  def set_distribution
    @distribution = Distribution.find(params[:id])
  end

  def distribution_params
    params.require(:distribution).permit(:name, :address_1, :address_2, :postal_code, :city, :country, :station, :date, :frequency, :start_time, :end_time, :weekdays, :monthdates).merge(recurrence: generate_recurrence)
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
    year = params[:distribution][:date][6..7]

    weekdays = params[:distribution][:weekdays]

    if freq == "Once"
      time = Time.new(year, month, day, start_hour, start_min)
      duration = Time.new(year, month, day, end_hour, end_min) - time
      schedule = IceCube::Schedule.new(time, duration: duration)
    elsif freq == "Daily"
      time = Time.new(now.year, now.month, now.day, start_hour, start_min)
      duration = Time.new(now.year, now.month, now.day, end_hour, end_min) - time
      schedule = IceCube::Schedule.new(time, duration: duration)
      schedule.rrule(IceCube::Rule.daily)
    elsif freq == "Weekly"
      time = Time.new(now.year, now.month, now.day, start_hour, start_min)
      duration = Time.new(now.year, now.month, now.day, end_hour, end_min) - time
      schedule = IceCube::Schedule.new(time, duration: duration)
      schedule.rrule(IceCube::Rule.weekly.day(:monday)) if weekdays.include?("Mon")
      schedule.rrule(IceCube::Rule.weekly.day(:tuesday)) if weekdays.include?("Tue")
      schedule.rrule(IceCube::Rule.weekly.day(:wednesday)) if weekdays.include?("Wed")
      schedule.rrule(IceCube::Rule.weekly.day(:thursday)) if weekdays.include?("Thu")
      schedule.rrule(IceCube::Rule.weekly.day(:friday)) if weekdays.include?("Fri")
      schedule.rrule(IceCube::Rule.weekly.day(:saturday)) if weekdays.include?("Sat")
      schedule.rrule(IceCube::Rule.weekly.day(:sunday)) if weekdays.include?("Sun")
    elsif freq == "monthly"
      schedule = IceCube::Schedule.new
    end

    return schedule.to_yaml
  end

end
