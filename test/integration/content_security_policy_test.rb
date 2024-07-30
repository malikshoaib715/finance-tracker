require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "pages send a nonce-based script policy and tag scripts with it" do
    sign_in users(:ayesha)
    get dashboard_url

    csp = response.headers["Content-Security-Policy"]
    nonce = csp[/'nonce-([^']+)'/, 1]
    assert_match "script-src 'self' 'nonce-", csp
    assert_match "frame-ancestors 'none'", csp
    assert_select "script[type=importmap][nonce=?]", nonce
    assert_select "script[nonce=?]", nonce, minimum: 2
  end
end
