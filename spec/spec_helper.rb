ENV['APP_ENV'] = 'test'
ENV['CODECLIMATE_REPO_TOKEN'] = '0e64c46d3240d588d5bf60ac103b36c03ce382a879612b914404fa973f309d97'
require 'rubygems'
require 'bundler'
puts '* * * SuperModule debug logging can be enabled by setting the environment variable SUPER_MODULE_LOG_LEVEL to DEBUG. For example: SUPER_MODULE_LOG_LEVEL=DEBUG rake'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
if RUBY_VERSION >= '1.9' && !defined?(Rubinius)
  begin
    require 'coveralls'
    Coveralls.wear!
    require "codeclimate-test-reporter"
    CodeClimate::TestReporter.start
  rescue LoadError, StandardError
    #no op to support Ruby 1.8.7, ree and Rubinius which do not support Coveralls
  end
end
require File.join(File.dirname(__FILE__), '..', 'lib', 'super_module')
require File.join(File.dirname(__FILE__), 'support', 'support.rb')
