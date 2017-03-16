class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :beta]
  skip_after_action :verify_authorized, only: [:home, :beta]

  def home
  end

  def beta
  end
end
