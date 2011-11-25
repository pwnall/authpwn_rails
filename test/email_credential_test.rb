require File.expand_path('../test_helper', __FILE__)

class EmailCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::Email.new :email => 'dvdjohn@mit.edu'
    @credential.user = users(:bill)
  end
  
  test 'setup' do
    assert @credential.valid?
  end
  
  test 'verified required' do
    @credential.verified = ''
    assert !@credential.valid?
  end
  
  test 'user presence' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'email presence' do
    @credential.email = nil
    assert !@credential.valid?
  end
  
  test 'email length' do
    @credential.email = 'abcde' * 25 + '@mit.edu'
    assert !@credential.valid?, 'Overly long email'
  end
  
  test 'email format' do
    ['cos tan@gmail.com', 'costan@x@mit.edu'].each do |email|
      @credential.email = email
      assert !@credential.valid?, "Bad email format - #{email}"
    end    
  end
  
  test 'email uniqueness' do
    @credential.email = credentials(:john_email).email
    assert !@credential.valid?
  end
end
