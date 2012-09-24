# This script migrates an authpwn 0.10-0.11 database to the new 0.12 layout.
# It should be run in a rails console.


# Add updated_at to credentials.
class UpgradeCredentials < ActiveRecord::Migration
  def change
    change_table :credentials do |t|
      t.timestamp :updated_at
    end
  end
end
UpgradeCredentials.migrate :up

# Populate updated_at for all credentials.
reload!
Credential.all.each do |c|
  c.touch
end

# Tighten the updated_at definition, add indexing.
class FinishUpgradingCredentials < ActiveRecord::Migration
  def up
    change_column :credentials, :updated_at, :timestamp, :null => false

    add_index :credentials, [:type, :updated_at], :unique => false,
                                                  :null => false
  end
end
FinishUpgradingCredentials.migrate :up

# Re-generate scaffolds.
Kernel.system 'rails g authpwn:all'

