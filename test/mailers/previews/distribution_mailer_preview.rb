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

  def create
    user = User.first
    distribution = Distribution.last
    DistributionMailer.create(user, distribution)
  end

  def review
    distribution = Distribution.last
    DistributionMailer.review(distribution)
  end
end
