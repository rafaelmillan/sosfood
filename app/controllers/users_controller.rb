class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: :show

  def show
    if current_user.admin == true
      @distributions = Distribution.order(created_at: :desc)
    else
      @distributions = current_user.organization.distributions.order(created_at: :desc)
    end
  end
end
