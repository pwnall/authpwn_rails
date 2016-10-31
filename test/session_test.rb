require_relative 'test_helper'

class SessionTest < ActiveSupport::TestCase
  setup do
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
