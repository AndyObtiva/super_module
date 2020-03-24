# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014-2015 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

# Avoiding require_relative for backwards compatibility with Ruby 1.8.7

require_relative 'super_module/v1'

module SuperModule
  class << self
    def included(original_base)
      original_base.send(:include, SuperModule::V1)
    end
  end
end
