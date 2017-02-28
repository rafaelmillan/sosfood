class RegistrationsController < Devise::RegistrationsController
  def create
    super
    if Organization.find_by(name: params[:organization][:name])
      @user.organization = Organization.find_by(name: params[:organization][:name])
      @user.save
    else
      @user.organization = Organization.create(name: params[:organization][:name])
      @user.save
    end
  end
end
