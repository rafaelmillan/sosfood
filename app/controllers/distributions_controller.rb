class DistributionsController < ApplicationController
  before_action :set_distribution, only: [:show, :edit, :update, :destroy]

  def index
    @distributions = Distribution.all
  end

  def show
  end

  def new
    @distribution = Distribution.new
  end

  def create
    raise
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
    params.require(:distribution).permit(:name, :address_1, :address_2, :postal_code, :city, :country, :station, :date, :frequency, :start_time, :end_time, :weekdays, :monthdates)
  end

  def generate_recurrence

  end

end
