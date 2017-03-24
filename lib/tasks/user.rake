namespace :user do
  desc "Remind all users of distributions"
  task remind_distributions: :environment do
    User.all.each { |user| UserMailer.remind_distributions(user.id).deliver_later }
  end
end
