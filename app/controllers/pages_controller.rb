class PagesController < ApplicationController
  skip_before_action :authenticate_organization!, only: :home

  def home
  end
end
