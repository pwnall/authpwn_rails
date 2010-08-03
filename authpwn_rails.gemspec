# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authpwn_rails}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Victor Costan"]
  s.date = %q{2010-08-02}
  s.description = %q{Works with Facebook.}
  s.email = %q{victor@costan.us}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     ".project",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "app/controllers/session_controller.rb",
     "app/helpers/session_helper.rb",
     "app/models/facebook_token.rb",
     "app/models/user.rb",
     "authpwn_rails.gemspec",
     "config/routes.rb",
     "lib/authpwn_rails.rb",
     "lib/authpwn_rails/engine.rb",
     "lib/authpwn_rails/facebook_token.rb",
     "lib/authpwn_rails/generators/facebook_migration_generator.rb",
     "lib/authpwn_rails/generators/templates/001_create_users.rb",
     "lib/authpwn_rails/generators/templates/002_create_facebook_tokens.rb",
     "lib/authpwn_rails/generators/templates/facebook_token.rb",
     "lib/authpwn_rails/generators/templates/facebook_tokens.yml",
     "lib/authpwn_rails/generators/templates/user.rb",
     "lib/authpwn_rails/generators/templates/users.yml",
     "lib/authpwn_rails/generators/user_migration_generator.rb",
     "lib/authpwn_rails/session.rb",
     "test/cookie_controller_test.rb",
     "test/facebook_controller_test.rb",
     "test/facebook_token_test.rb",
     "test/helpers/application_controller.rb",
     "test/helpers/db_setup.rb",
     "test/helpers/fbgraph.rb",
     "test/helpers/routes.rb",
     "test/session_controller_test.rb",
     "test/test_helper.rb",
     "test/user_test.rb"
  ]
  s.homepage = %q{http://github.com/costan/mini_auth_rails}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{User authentication for Rails 3 applications.}
  s.test_files = [
    "test/facebook_token_test.rb",
     "test/user_test.rb",
     "test/cookie_controller_test.rb",
     "test/test_helper.rb",
     "test/facebook_controller_test.rb",
     "test/session_controller_test.rb",
     "test/helpers/application_controller.rb",
     "test/helpers/routes.rb",
     "test/helpers/fbgraph.rb",
     "test/helpers/db_setup.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fbgraph_rails>, [">= 0.1.3"])
      s.add_development_dependency(%q<activerecord>, [">= 3.0.0.beta4"])
      s.add_development_dependency(%q<actionpack>, [">= 3.0.0.beta4"])
      s.add_development_dependency(%q<activesupport>, [">= 3.0.0.beta4"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.0"])
    else
      s.add_dependency(%q<fbgraph_rails>, [">= 0.1.3"])
      s.add_dependency(%q<activerecord>, [">= 3.0.0.beta4"])
      s.add_dependency(%q<actionpack>, [">= 3.0.0.beta4"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta4"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.0"])
    end
  else
    s.add_dependency(%q<fbgraph_rails>, [">= 0.1.3"])
    s.add_dependency(%q<activerecord>, [">= 3.0.0.beta4"])
    s.add_dependency(%q<actionpack>, [">= 3.0.0.beta4"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta4"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.0"])
  end
end

