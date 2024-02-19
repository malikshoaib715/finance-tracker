# Demo data for local development. Safe to run more than once:
#
#   bin/rails db:seed
#
# Sign in with demo@example.com / password123

demo = User.find_or_initialize_by(email: "demo@example.com")
demo.assign_attributes(name: "Demo User", password: "password123", currency: "PKR", time_zone: "Karachi")
demo.skip_confirmation!
demo.save!
Category.create_defaults_for(demo)

puts "Seeded demo user: #{demo.email} / password123"
