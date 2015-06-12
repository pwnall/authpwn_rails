require_relative 'test_helper'

class SessionMailerApiTest < ActionMailer::TestCase
  setup do
    @reset_email = credentials(:jane_email).email
    @reset_token = credentials(:jane_password_token)
    @verification_token = credentials(:john_email_token)
    @verification_email = credentials(:john_email).email
    @root_url = 'hxxp://test.host:8808'

    # The generator template has the same return value for reset_password_from
    # and email_verification_from, so we need these stubs to ensure that the
    # e-mails use the right methods.
    #
    # NOTE: limited attempts at using flexmock failed.
    SessionMailer.class_eval do
      alias_method :_email_verification_from_old, :email_verification_from
      def email_verification_from(*params)
        'email_check@test.host'
      end

      alias_method :_reset_password_from_old, :reset_password_from
      def reset_password_from(*params)
        'reset@test.host'
      end
    end
  end

  teardown do
    SessionMailer.class_eval do
      undef :email_verification_from
      alias_method :email_verification_from, :_email_verification_from_old
      undef :_email_verification_from_old

      undef :reset_password_from
      alias_method :reset_password_from, :_reset_password_from_old
      undef :_reset_password_from_old
    end
  end

  test 'email verification email contents' do
    email_draft = SessionMailer.email_verification_email @verification_token,
                                                         @root_url
    email = email_draft.deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal 'test.host e-mail verification', email.subject
    assert_equal ['email_check@test.host'], email.from
    assert_equal [@verification_email], email.to
    assert_match @verification_token.code, email.encoded
    assert_match 'hxxp://test.host:8808/session/token/', email.encoded
  end

  test 'password reset email contents' do
    email_draft = SessionMailer.reset_password_email @reset_email,
                                                     @reset_token, @root_url
    email = email_draft.deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal 'test.host password reset', email.subject
    assert_equal ['reset@test.host'], email.from
    assert_equal [@reset_email], email.to
    assert_match @reset_token.code, email.encoded
    assert_match 'hxxp://test.host:8808/session/token/', email.encoded
  end
end
