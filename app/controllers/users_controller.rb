class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: :show

  def show
    if current_user.organization.nil?
      redirect_to new_organization_path
    else
      @distributions = current_user.organization.distributions
    end
  end
end
