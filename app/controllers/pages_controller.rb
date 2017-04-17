class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :beta]
  skip_after_action :verify_authorized, only: [:home, :beta]

  def home
    @distributions = Distribution.all.reject{|d| d.schedule.next_occurrence.nil? }.sort_by {|d| d.schedule.next_occurrence.start_time }[0..2]
  end

  def beta
  end
end
