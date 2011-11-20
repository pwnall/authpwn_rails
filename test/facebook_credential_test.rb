require File.expand_path('../test_helper', __FILE__)

class FacebookCredentialTest < ActiveSupport::TestCase  
  def setup
    @code = 'AAAEj8jKX2a8BAOBMZCjxBe4dw7cRoD1JVxUgZAtB6ozJlR4Viazh6OAYcHB5kZAtUwgjpDy7a54ZA1DObLmBT9X99CLWYOj5Stqx8bHwnE7EzyBS1WxY'
    @credential = Credentials::Facebook.new :facebook_uid => '1181310542',
        :key => '125502267478972|057806abb79e632e0f7dde62-1181310542|y5SoPVcXoEl214vfs--F3y-Z0Xk.',
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
  
  test 'facebook_uid uniqueness' do
    @credential.facebook_uid = credentials(:jane_facebook).facebook_uid
    assert !@credential.valid?
  end
  
  test 'facebook_token' do
    user = users(:john)
    assert_equal credentials(:john_facebook), user.facebook_token
  end
  
  
  test 'for_facebook_token' do
    assert_equal users(:john),
        User.for_facebook_token(users(:john). facebook_token.key)
  end
  
  test "uid_from_token" do
    assert_equal '1011950666', Credentials::Facebook.uid_from_token(@code)
  end
  
  test "for with existing access token" do
    assert_equal credentials(:jane_facebook), Credentials::Facebook.for(@code),
                 'Wrong token'
    assert_equal @code, credentials(:jane_facebook).reload.key,
                 'Token not refreshed'
  end
  
  test "for with new access token" do
    credential = nil
    assert_difference 'Credentials::Facebook.count', 1 do      
      credential = Credentials::Facebook.for @credential.key
    end
    assert !credential.new_record?, 'New credential not saved'
    assert !credential.user.new_record?, "New credential's user not saved"    
  end  
end
