require File.expand_path('../test_helper', __FILE__)

class FacebookCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::Facebook.new :name => '100001181310542',
        :key => '125502267478972|057806abb79e632e0f7dde62-100001181310542|y5SoPVcXoEl214vfs--F3y-Z0Xk.',
        :user => users(:bill)
  end
  
  test 'setup' do
    assert @credential.valid?
  end
  
  test 'key required' do
    @credential.key = nil
    assert !@credential.valid?
  end
  
  test 'user presence' do
    @credential.user = nil
    assert !@credential.valid?
  end
  
  test 'user uniqueness' do
    @credential.user = users(:john)
    assert !@credential.valid?
  end
  
  
  test 'facebook_token' do
    assert_nil @user.facebook_token
    
    user = users(:john)
    assert_equal facebook_tokens(:john), user.facebook_token
  end
  
  
  test 'for_facebook_token' do
    assert_equal users(:john),
        User.for_facebook_token(users(:john). facebook_token.access_token)
  end
end
