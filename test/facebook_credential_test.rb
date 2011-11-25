require File.expand_path('../test_helper', __FILE__)

class FacebookCredentialTest < ActiveSupport::TestCase  
  def setup
    @code = 'AAAEj8jKX2a8BAA4kNheRhOs6SlECVcZCE9o5pPKMytOjjoiNAoZBGZAwuL4KrrxXWesfJRhzDZCJiqrcQG3UdjRRNtyMJQMZD'
    @credential = Credentials::Facebook.new
    @credential.facebook_uid = '1181310542'
    @credential.key = 'AAAEj8jKX2a8BAOBMZCjxBe4dw7cRoD1JVxUgZAtB6ozJlR4Viazh6OAYcHB5kZAtUwgjpDy7a54ZA1DObLmBT9X99CLWYOj5Stqx8bHwnE7EzyBS1WxY'
    @credential.user = users(:bill)
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
  
  test "uid_from_token" do
    assert_equal '1011950666', Credentials::Facebook.uid_from_token(@code)
  end

  test "for with existing access token" do
    flexmock(Credentials::Facebook).should_receive(:uid_from_token).with(@code).
        and_return(credentials(:jane_facebook).facebook_uid)
        
    assert_equal credentials(:jane_facebook), Credentials::Facebook.for(@code),
                 'Wrong token'
    assert_equal @code, credentials(:jane_facebook).reload.key,
                 'Token not refreshed'
  end
  
  test "for with new access token" do
    credential = nil
    flexmock(Credentials::Facebook).should_receive(:uid_from_token).
        with(@credential.key).and_return('123456789')
    assert_difference 'Credentials::Facebook.count', 1 do      
      credential = Credentials::Facebook.for @credential.key
    end
    assert_equal '123456789', credential.facebook_uid 
    assert_equal @credential.key, credential.key
    assert !credential.new_record?, 'New credential not saved'
    assert !credential.user.new_record?, "New credential's user not saved"
    assert_operator credential.user.credentials, :include?, credential,
        "New user's credentials does not include Facebook credential"    
  end  

  test 'User#facebook_credential' do
    user = users(:john)
    assert_equal credentials(:john_facebook), user.facebook_credential
  end
  
  test 'User#for_facebook_token' do
    flexmock(Credentials::Facebook).should_receive(:uid_from_token).
        with(credentials(:john_facebook).key).
        and_return(credentials(:john_facebook).facebook_uid)
    assert_equal users(:john),
        User.for_facebook_token(credentials(:john_facebook).key)
  end
end
