class DistributionMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.distribution_mailer.accept.subject
  #
  def accept(user, distribution)
    @user = user
    email = @user.nil? ? "contact@sos-food.org" : @user.email
    @distribution = distribution

    mail(to: email, subject: "Votre distribution a été validée")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.distribution_mailer.decline.subject
  #
  def decline(user, distribution)
    @user = user
    email = @user.nil? ? "contact@sos-food.org" : @user.email
    @distribution = distribution

    mail(to: email || "contact@sos-food.org", subject: "Votre distribution n'a pas été validée")
  end

  def create(user, distribution)
    @user = user
    @distribution = distribution

    mail(to: @user.email || "contact@sos-food.org", subject: "Votre distribution est en cours de validation")
  end
end
