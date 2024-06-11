require "test_helper"

class User::OnboardingTest < ActiveSupport::TestCase
  test "a brand new user has everything to do" do
    user = User.create!(name: "New Person", email: "new@example.com", password: "password123")
    onboarding = User::Onboarding.new(user)
    assert_equal 0, onboarding.done_count
    assert_not onboarding.complete?
  end

  test "tracks progress through the steps" do
    onboarding = User::Onboarding.new(users(:ayesha))
    assert_equal [ true, true, true, false ], onboarding.steps.map(&:done)
  end
end
