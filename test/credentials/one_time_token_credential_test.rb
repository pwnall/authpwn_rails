require File.expand_path('../../test_helper', __FILE__)

class OneTimeTokenCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::OneTimeToken.new(
        :code => 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo')
    @credential.user = users(:bill)
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

  test 'user presence' do
    @credential.user = nil
    assert !@credential.valid?
  end
  
  test 'spend destroys the token' do
    credential = credentials(:john_token)
    assert_equal Credentials::OneTimeToken, credential.class, 'bad setup'
    
    assert_difference 'Credential.count', -1 do
      credential.spend
    end
    assert credential.frozen?, 'not destroyed'
  end
  
  test 'random_for' do
    token = Credentials::OneTimeToken.random_for users(:john)
    assert token.valid?, 'valid token'
    assert_equal users(:john), token.user
    assert_equal Credentials::OneTimeToken, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:john).credentials, :include?, token
  end
end
