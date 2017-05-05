class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :beta, :apropos]
  skip_after_action :verify_authorized, only: [:home, :beta, :apropos]

  def home
    @distributions = Distribution
      .where(status: "accepted")
      .where.not(latitude: nil, longitude: nil)
      .reject{|d| d.schedule.next_occurrence.nil? }
      .sort_by {|d| d.schedule.next_occurrence.start_time }[0..2]
  end

  def beta
    render
  end
end
