namespace :demo do
  desc "Wipe the demo user's data and regenerate a fresh year (EMAIL=demo@example.com)"
  task reset: :environment do
    user = User.find_by!(email: ENV.fetch("EMAIL", "demo@example.com"))
    [ :transactions, :transfers, :budgets, :goals, :rules, :recurring_transactions, :imports ].each { |a| user.public_send(a).delete_all }
    user.accounts.delete_all
    DemoData.new(user).generate
    puts "Regenerated demo data for #{user.email}: #{user.transactions.count} transactions"
  end
end
