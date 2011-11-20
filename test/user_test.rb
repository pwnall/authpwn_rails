require File.expand_path('../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase  
  def setup
    @user = User.new
  end
  
  test 'setup' do
    assert @user.valid?
  end
  
  test 'exuid generation' do
    assert @user.valid?
    assert @user.exuid
  end
  
  test 'exuid uniqueness' do
    @user.exuid = users(:john).exuid
    assert !@user.valid?
  end
  
  test 'exuid presence' do
    @user.exuid = ''
    assert !@user.valid?
  end
    
  test 'to_param' do
    assert_equal '56789', users(:john).to_param
  end
  
  test 'find_by_param' do
    assert_equal users(:john), User.find_by_param(users(:john).to_param)
    assert_equal users(:jane), User.find_by_param(users(:jane).to_param)
    assert_equal nil, User.find_by_param('bogus id')
    assert_equal nil, User.find_by_param(nil)
  end
end
