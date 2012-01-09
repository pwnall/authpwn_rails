require File.expand_path('../test_helper', __FILE__)

require 'authpwn_rails/generators/templates/session_mailer.rb'

# Run the tests in the generator, to make sure they pass.
require 'authpwn_rails/generators/templates/session_mailer_test.rb'

class SessionMailerApiTest < ActionMailer::TestCase
  setup do
    @email = credentials(:jane_email).email
    @reset_token = credentials(:jane_password_token)
    @host = 'test.host'
  end

  test 'password_reset email contents' do
    email = SessionMailer.reset_password_email(@email, @reset_token, @host).
                          deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert_equal 'test.host password reset', email.subject
    assert_equal ['admin@test.host'], email.from
    assert_equal '"test.host staff" <admin@test.host>', email['from'].to_s
    assert_equal [@email], email.to
    assert_match @reset_token.code, email.encoded    
  end
end