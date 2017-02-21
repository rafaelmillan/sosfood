class DistributionsController < ApplicationController
  before_action :set_distribution, only: [:show, :edit, :update, :destroy]

  def index
    @distributions = policy_scope(Distribution)
  end

  def show
  end

  def new
    @distribution = Distribution.new
    authorize @distribution
  end

  def create
    @distribution = Distribution.create(distribution_params)
    @distribution.organization = current_organization
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
    @distribution.update(distribution_params)
    if @distribution.save
      redirect_to distribution_path(@distribution)
    else
      render :edit
    end
  end

  def destroy
    @distribution.destroy
    redirect_to distributions_path
  end

  private

  def set_distribution
    @distribution = Distribution.find(params[:id])
    authorize @distribution
  end

  def distribution_params
    params.require(:distribution).permit(:name, :address_1, :address_2, :postal_code, :city, :country, :station)
  end
end
