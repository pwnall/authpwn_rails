require_relative '../test_helper'

class EmailVerificationTokenTest < ActiveSupport::TestCase
  setup do
    @credential = Tokens::EmailVerification.new
    @credential.code = 'fitobg6hzsk7odiiw3ca45ltghget4tlbbapxikgdsugfa36llwq'
    @credential.key = 'jane@gmail.com'
    @credential.user = users(:jane)
  end

  test 'setup' do
    assert @credential.valid?
  end

  test 'code required' do
    @credential.code = nil
    assert !@credential.valid?
  end

  test 'code uniqueness' do
    @credential.code = credentials(:john_token).code
    assert !@credential.valid?
  end

  test 'email required' do
    @credential.email = nil
    assert !@credential.valid?
  end

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'email_credential' do
    assert_equal credentials(:jane_email), @credential.email_credential
    assert_equal credentials(:john_email),
                 credentials(:john_email_token).email_credential

    @credential.email = 'bill@gmail.com'
    assert_nil @credential.email_credential
  end

  test 'spend verifies the e-mail and destroys the token' do
    email_credential = credentials(:john_email)
    assert !email_credential.verified?, 'bad setup'
    credential = credentials(:john_email_token)
    assert_equal Tokens::EmailVerification, credential.class, 'bad setup'

    assert_difference -> { Credential.count }, -1 do
      credential.spend
    end
    assert credential.frozen?, 'not destroyed'
    assert email_credential.reload.verified?, 'e-mail not verified'
  end

  test 'spend does not verify a random e-mail and still destroys the token' do
    email_credential = credentials(:john_email)
    credential = credentials(:john_email_token)
    credential.email = 'bill@gmail.com'

    assert_difference -> { Credential.count }, -1 do
      credential.spend
    end
    assert credential.frozen?, 'not destroyed'
    assert !email_credential.reload.verified?, 'e-mail wrongly verified'
  end

  test 'random_for' do
    token = Tokens::EmailVerification.random_for credentials(:jane_email)
    assert token.valid?, 'valid token'
    assert_equal users(:jane), token.user
    assert_equal credentials(:jane_email).email, token.email
    assert_equal Tokens::EmailVerification, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:jane).credentials, :include?, token
  end
end
