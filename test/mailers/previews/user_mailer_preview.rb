class UserMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first
    UserMailer.welcome(user)
  end

  def remind_distributions
    user = User.first
    UserMailer.remind_distributions(user)
  end
end
