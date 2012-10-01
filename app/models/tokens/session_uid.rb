# :namespace
module Tokens

class SessionUid < Credentials::Token
  # The session UID.
  alias_attribute :suid, :name

  # The IP address and User-Agent string of the browser using this session.
  store :key, :accessors => [:browser_ip, :browser_ua]

  # Creates a new session UID token for a user.
  #
  # @param [User] user the user authenticated using this session
  # @param [String] browser_ip the IP of the session
  # @param [String] browser_ua the User-Agent of the browser used for this
  #                            session
  def self.random_for(user, browser_ip, browser_ua)
    browser_ua = browser_ua[1, 1536] if browser_ua.length > 1536
    key = { :browser_ip => browser_ip, :browser_ua => browser_ua }
    super user, key, self
  end

  # Refresh precision for the updated_at timestamp, in seconds.
  #
  # When a session UID is used to authenticate a user, its updated_at time is
  # refreshed if it differs from the current time by this much.
  cattr_accessor :update_interval, :instance_writer => false
  self.update_interval = 1.hour

  # Updates the time associated with the session.
  def spend
    self.touch if Time.now - updated_at >= update_interval
  end

  # Period of inactivity after which session UIDs become invalid.
  #
  # Note that update_interval controls the precision of the inactivity period
  # computation.
  cattr_accessor :expire_after
  self.expire_after = 1.month

  # Garbage-collects database records of expired sessions.
  #
  # This method should be called periodically to keep the size of the session
  # table under control.
  def self.remove_expired
    self.where('updated_at < ?', Time.now - expire_after).delete_all
    self
  end
end  # class Tokens::SessionUid

end  # namespace Tokens
