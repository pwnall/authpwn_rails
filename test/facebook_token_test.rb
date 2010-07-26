require File.expand_path('../test_helper', __FILE__)

class FacebookTokenTest < ActiveSupport::TestCase
  setup do
    @code = '125502267478972|057806abb79e632e0f7dde62-100001181310542|y5SoPVcXoEl214vfs--F3y-Z0Xk.'
  end
  
  test "uid_from_token" do
    assert_equal '100001181310542', FacebookToken.uid_from_token(@code)
  end
  
  test "for with existing access token" do
    assert_equal facebook_tokens(:jane), FacebookToken.for(@code),
                 'Wrong token'
    assert_equal @code, facebook_tokens(:jane).reload.access_token,
                 'Token not refreshed'
  end
  
  test "for with new access token" do
    token = nil
    assert_difference 'FacebookToken.count', 1 do      
      token = FacebookToken.for @code.gsub('100001181310542', '3141592')
    end
    assert_equal '3141592@graph.facebook.com', token.user.email
    assert !token.new_record?, 'New token not saved'
    assert !token.user.new_record?, "New token's user not saved"    
  end
end
