# This script migrates the authpwn 0.20 token codes and user IDs to the new
# 0.21 format.
# It should be run in a rails console.

User.all.each do |user|
  user.exuid = nil
  user.set_default_exuid
  user.save!
end

Credential.all.each do |token|
  next unless token.kind_of? Tokens::Base
  token.code = Tokens::Base.random_code
  token.save!
end
