class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.integer :user_id, :null => false
      t.string :type, :limit => 32, :null => false
      t.string :name, :limit => 256, :null => false
      
      t.boolean :verified, :null => false, :default => false
      
      t.binary :key, :limit => 2.kilobytes, :null => false
    end
    
    # Pull all the credentials belonging to a user.
    add_index :user_credentials, :user_id, :unique => true, :null => false
    # Pull a specific credential and find out what user it belongs to.
    add_index :user_credentials, [:type, :name], :unique => true, :null => true
  end
end
