if ActiveSupport.respond_to? :test_order
  ActiveSupport.test_order = :sorted
end
