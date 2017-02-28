class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: :show

  def show
    @distributions = current_user.organization.distributions
  end
end
