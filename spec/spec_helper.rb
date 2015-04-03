ENV['APP_ENV'] = 'test'
require 'rubygems'
require 'bundler'
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
  rescue LoadError, StandardError
    #no op to support Ruby 1.8.7, ree and Rubinius which do not support Coveralls
  end
end
#require 'debugger'
require File.join(File.dirname(__FILE__), '..', 'lib', 'super_module')
require File.join(File.dirname(__FILE__), 'support', 'support.rb')
