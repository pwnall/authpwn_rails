# :nodoc: stub FBGraphRails.config because it depends on Rails.root
module FBGraphRails
  def self.config
    { 'id' => '12345', 'secret' => 'awesome', 'scope' => []}
  end
end