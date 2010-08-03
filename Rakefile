require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "authpwn_rails"
    gem.summary = %Q{User authentication for Rails 3 applications.}
    gem.description = %Q{Works with Facebook.}
    gem.email = "victor@costan.us"
    gem.homepage = "http://github.com/costan/mini_auth_rails"
    gem.authors = ["Victor Costan"]
    gem.add_runtime_dependency "fbgraph_rails", ">= 0.1.3"
    gem.add_development_dependency "activerecord", ">= 3.0.0.rc"
    gem.add_development_dependency "actionpack", ">= 3.0.0.rc"
    gem.add_development_dependency "activesupport", ">= 3.0.0.rc"
    gem.add_development_dependency "sqlite3-ruby", ">= 1.3.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "authpwn_rails #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
