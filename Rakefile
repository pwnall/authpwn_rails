# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'authpwn_rails'
  gem.homepage = 'https://github.com/pwnall/authpwn_rails'
  gem.license = 'MIT'
  gem.summary = %Q{User authentication for Rails 5 applications.}
  gem.description = %Q{This gem is a quick way to add authentication to a Rails application. The speed of the integration process comes at the cost of some flexibility. The gem supports email/password logins with e-mail confirmation, as well as OAuth2-based logins. }
  gem.email = 'victor@costan.us'
  gem.authors = ['Victor Costan']
  # Dependencies in Gemfile.
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false

  # TODO(pwnall): Remove when the following PR gets into a release:
  #               https://github.com/stesla/base32/pull/10
  test.warning = false
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "authpwn_rails #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
