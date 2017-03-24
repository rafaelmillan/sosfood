class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user

    mail(to: @user.email, subject: "Bienvenue sur SOS Food")
  end

  def remind_distributions(user_id)
    @user = User.find(user_id)
    @week_start = Time.current.in_time_zone("Paris").sunday
    @week_end = @week_start + 1.week
    @distributions = @user.organization.distributions.where(status: "accepted").select do |dis|
      dis.schedule.occurring_between?(@week_start, @week_end)
    end

    return if @distributions.blank?

    mail(to: @user.email, subject: "Vos distributions de repas sont-elles à jour ?")
  end
end
