# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "super_module"
  gem.homepage = "http://github.com/AndyObtiva/super_module"
  gem.license = "MIT"
  gem.summary = %Q{SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base). This also succeeds ActiveSupport::Concern by offering lighter syntax}
  gem.description = %Q{TODO: SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base). This also succeeds ActiveSupport::Concern by offering lighter syntax}
  gem.email = "andy.am@gmail.com"
  gem.authors = ["Andy Maleh"]
  gem.files.exclude 'spec/*'
  gem.files.exclude 'Gemfile'
  gem.files.exclude 'Gemfile.lock'
  gem.files.exclude 'Rakefile'
  gem.files.exclude '.ruby-gemset'
  gem.files.exclude '.ruby-version'
  gem.files.exclude '.travis.yml'
  gem.files.exclude '.coveralls.yml'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "super_module #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
