class DistributionMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.distribution_mailer.accept.subject
  #
  def accept(user, distribution)
    @user = user
    @distribution = distribution

    mail(to: @user.email, subject: "Votre distribution a été validée")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.distribution_mailer.decline.subject
  #
  def decline(user, distribution)
    @user = user
    @distribution = distribution

    mail(to: @user.email, subject: "Votre distribution n'a pas été validée")
  end

  def create(user, distribution)
    @user = user
    @distribution = distribution

    mail(to: @user.email, subject: "Votre distribution est en cours de validation")
  end
end
