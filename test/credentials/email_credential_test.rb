require File.expand_path('../../test_helper', __FILE__)

class EmailCredentialTest < ActiveSupport::TestCase
  def setup
    @credential = Credentials::Email.new
    @credential.email = 'dvdjohn@mit.edu'
    @credential.user = users(:bill)
  end

  test 'setup' do
    assert @credential.valid?
  end

  test 'key required' do
    @credential.key = ''
    assert !@credential.valid?
  end

  test 'key cannot be some random string' do
    @credential.key = 'xoxo'
    assert !@credential.valid?
  end

  test 'verified set to true' do
    @credential.verified = true
    assert_equal '1', @credential.key, 'key'
    assert_equal true, @credential.verified?, 'verified?'
  end

  test 'verified set to false' do
    @credential.verified = false
    assert_equal '0', @credential.key, 'key'
    assert_equal false, @credential.verified?, 'verified?'
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
    assert @credential.errors[:name].any? { |m| /too long/i =~ m },
           'Validation errors include length error'
  end

  test 'email format' do
    ['cos tan@gmail.com', 'costan@x@mit.edu'].each do |email|
      @credential.email = email
      assert !@credential.valid?, "Bad email format - #{email}"
      assert @credential.errors[:name].any? { |m| /invalid/i =~ m },
             'Validation errors include format error'
    end
  end

  test 'email uniqueness' do
    @credential.email = credentials(:john_email).email
    assert !@credential.valid?
    assert @credential.errors[:name].
                       any? { |m| /already used by another/i =~ m },
           'Validation errors include custom uniqueness error'
    assert !@credential.errors[:name].
                        any? { |m| m == 'has already been taken' },
           'Validation errors do not include default uniqueness error'
  end

  test 'authenticate' do
    assert_equal users(:john), Credentials::Email.authenticate('john@gmail.com')
    assert_equal users(:jane), Credentials::Email.authenticate('jane@gmail.com')
    assert_equal :invalid, Credentials::Email.authenticate('bill@gmail.com')
  end

  test 'authenticate calls User#auth_bounce_reason' do
    with_blocked_credential credentials(:john_email), :reason do
      assert_equal :reason, Credentials::Email.authenticate('john@gmail.com')
      assert_equal users(:jane),
                   Credentials::Email.authenticate('jane@gmail.com')
      assert_equal :invalid, Credentials::Email.authenticate('bill@gmail.com')
    end
  end
end
