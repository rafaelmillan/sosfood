class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: :show

  def show
    if current_user.admin == true
      @distributions = Distribution.all
    else
      @distributions = current_user.organization.distributions
    end
  end
end
