require_relative '../test_helper'

class PasswordVerificationTokenTest < ActiveSupport::TestCase
  setup do
    @credential = Tokens::PasswordReset.new
    @credential.code = 'fitobg6hzsk7odiiw3ca45ltghget4tlbbapxikgdsugfa36llwq'
    @credential.user = users(:john)
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

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'password_credential' do
    assert_equal credentials(:john_password), @credential.password_credential
    assert_equal credentials(:jane_password),
                 credentials(:jane_password_token).password_credential

    @credential.user = users(:bill)
    assert_nil @credential.password_credential
  end

  test 'spend blanks out the password and destroys the token' do
    password_credential = credentials(:jane_password)
    credential = credentials(:jane_password_token)
    assert_equal Tokens::PasswordReset, credential.class, 'bad setup'

    assert_difference -> { Credential.count }, -2 do
      assert_difference -> { Credentials::Password.count }, -1 do
        credential.spend
      end
    end
    assert credential.frozen?, 'not destroyed'
    assert_nil Credential.where(id: password_credential.id).first,
               'password not blanked out'
  end

  test 'spend works on password-less user and still destroys the token' do
    password_credential = credentials(:jane_password)
    password_credential.destroy
    credential = credentials(:jane_password_token)

    assert_difference -> { Credential.count }, -1 do
      credential.spend
    end
    assert credential.frozen?, 'not destroyed'
  end

  test 'random_for' do
    token = Tokens::PasswordReset.random_for users(:john)
    assert token.valid?, 'valid token'
    assert_equal users(:john), token.user
    assert_equal Tokens::PasswordReset, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:john).credentials, :include?, token
  end
end
