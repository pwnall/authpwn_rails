# This script migrates an authpwn <= 0.9 database to the new 0.10 layout.
# It should be run in a rails console.


# Remove obsolete Facebook token files.
[
  'app/models/facebook_token.rb',
  'db/migrate/20100725000002_create_facebook_tokens.rb',
  'test/fixtures/facebook_tokens.yml'
].each do |f| 
  File.unlink f if File.exist?(f)
end

# Re-generate scaffolds.
Kernel.system 'rails g authpwn:all'

# Get the credentials table.
Kernel.system "rake db:migrate:up VERSION=20100725000003 RAILS_ENV=#{Rails.env}"

# Build up credentials.
reload!
User.all.each do |user|
  Credentials::Email.create! :user => user, :email => user.attributes['email']

  pwd = Credentials::Password.new :user => user
  pwd.password = pwd.password_confirmation = '_'
  pwd.key = user.password_salt + '|' + user.password_hash
  pwd.save!
end

# Update the columns in the User model.
class UpgradeUserModel < ActiveRecord::Migration
  def change
    remove_column :users, :email
    remove_column :users, :email_hash
    remove_column :users, :password_salt
    remove_column :users, :password_hash
    
    add_column :users, :exuid, :string, :length => 32, :null => true
  end
end
UpgradeUserModel.migrate :up
reload!

# Assign unique IDs to all users.
User.all.each do |user|
  user.set_default_exuid
  sleep 0.01
  user.save!
end

# Finish the upgrade of the User model.
class FinishUpgradingUserModel < ActiveRecord::Migration
  def change
    change_column :users, :exuid, :string, :length => 32, :null => false
    add_index :users, :exuid, :unique => true, :null => false
  end
end
FinishUpgradingUserModel.migrate :up
reload!

