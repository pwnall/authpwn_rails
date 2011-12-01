require 'action_pack'

# :nodoc: namespace
module Authpwn

# :nodoc: namespace
module Routes

# :nodoc: mixed into ActionPack's route mapper.
module MapperMixin
  def authpwn_session
    get '/session/token/:code' => 'session#token', :as => :token_session
    
    get '/session' => 'session#show', :as => :session
    get '/session/new' => 'session#new', :as => :new_session
    post '/session' => 'session#create'
    delete '/session' => 'session#destroy'
  end
end

ActionDispatch::Routing::Mapper.send :include, MapperMixin

end  # namespace Authpwn::Routes

end  # namespace Authpwn
