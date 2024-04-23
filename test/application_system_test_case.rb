require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Turbo navigations after uploads can take a moment on a cold CI runner.
  Capybara.default_max_wait_time = 5

  include Warden::Test::Helpers
  teardown { Warden.test_reset! }
end
