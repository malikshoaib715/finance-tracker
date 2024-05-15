# Preview at http://localhost:3000/rails/mailers/summary_mailer/monthly
class SummaryMailerPreview < ActionMailer::Preview
  def monthly
    SummaryMailer.monthly(User.first, month: Date.current)
  end
end
