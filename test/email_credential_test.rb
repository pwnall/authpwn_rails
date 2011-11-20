require File.expand_path('../test_helper', __FILE__)

class EmailCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::Email.new :name => 'dvdjohn@mit.edu',
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

  test 'email presence' do
    @credential.name = nil
    assert !@credential.valid?
  end
  
  test 'email length' do
    @credential.name = 'abcde' * 25 + '@mit.edu'
    assert !@credential.valid?, 'Overly long email'
  end
  
  test 'email format' do
    ['cos tan@gmail.com', 'costan@x@mit.edu'].each do |email|
      @credential.name = email
      assert !@credential.valid?, "Bad email format - #{email}"
    end    
  end
  
  test 'email uniqueness' do
    @credential.name = credentials(:john_email).email
    assert !@credential.valid?
  end
end
