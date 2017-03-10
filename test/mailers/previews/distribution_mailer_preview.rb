class DistributionMailerPreview < ActionMailer::Preview
  def accept
    user = User.first
    distribution = Distribution.last
    DistributionMailer.accept(user, distribution)
  end

  def decline
    user = User.first
    distribution = Distribution.last
    DistributionMailer.decline(user, distribution)
  end
end
