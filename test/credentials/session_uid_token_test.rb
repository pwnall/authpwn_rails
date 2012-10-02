require File.expand_path('../../test_helper', __FILE__)

class SessionUidTokenTest < ActiveSupport::TestCase
  def setup
    @credential = Tokens::SessionUid.new(
      :code => 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo',
      :browser_ip => '18.70.0.160',
      :browser_ua => 'Mozilla/5.0 (X11; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1'
    )
    @credential.user = users(:jane)
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

  test 'browser_ip required' do
    @credential.browser_ip = nil
    assert !@credential.valid?
  end

  test 'browser_ua required' do
    @credential.browser_ua = nil
    assert !@credential.valid?
  end

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end
end
