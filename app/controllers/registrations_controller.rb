class RegistrationsController < Devise::RegistrationsController
  def create
    super
    @user.organization = Organization.create(name: params[:organization][:name])
    @user.save
  end
end
