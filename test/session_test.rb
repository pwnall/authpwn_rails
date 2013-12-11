require File.expand_path('../test_helper', __FILE__)

class SessionTest < ActiveSupport::TestCase
  def setup
    @session = Session.new email: 'costan@gmail.com', password: 'secret'
  end

  test 'setup' do
    assert @session.valid?
  end

  test 'from_params with raw values' do
    session = Session.from_params email: 'costan@gmail.com', password: 'secret'

    assert_equal 'costan@gmail.com', session.email
    assert_equal 'secret', session.password
  end

  test 'from_params with object' do
    session = Session.from_params session: { email: 'costan@gmail.com',
                                             password: 'secret' }

    assert_equal 'costan@gmail.com', session.email
    assert_equal 'secret', session.password
  end
end
