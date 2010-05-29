# Mock user model.
#
# Call mock_user to create a mock user.
class User
  # Deletes all the mock users.
  def self.reset_mocks
    @@users = []
    @@tokens = {}
  end
  reset_mocks
  
  # Creates a mock user with the given ID.
  #
  # Returns the mock user.
  def self.mock_user    
    User.new
  end

  def initialize
    @uid = @@users.length + 1
    @token = nil
    @@users.push self
  end
  
  def id
    @uid
  end
  
  def self.find_by_id(id)
    uid = id.to_i - 1
    (uid < 0) ? nil : @@users[uid]
  end
    
  attr_reader :token
  def token=(new_token)
    @token = new_token
    @@tokens[new_token] = self    
    new_token
  end
  
  def self.for_facebook_token(token)
    user = @@tokens[token]
    unless user
      user = User.new
      user.token = token
    end
    user
  end
end

# :nodoc: reset mock users when done testing
class ActiveSupport::TestCase
  teardown do
    User.reset_mocks
  end
end
