module Rails
  class <<self
    remove_method :application
    alias_method :application, :_real_application
    remove_method :_real_application
  end
end
