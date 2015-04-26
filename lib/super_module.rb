# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014-2015 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

# Avoiding require_relative for backwards compatibility with Ruby 1.8.7
require File.expand_path(File.join(File.dirname(__FILE__), 'super_module', 'v1'))

def super_module(name)
end

module SuperModule
  class << self
  
    attr_accessor :super_module_body

    def define(&super_module_body)
      clone.tap { |super_module| super_module.super_module_body = super_module_body }
    end

    def included(original_base)
      if super_module_body
        original_base.class_eval(&super_module_body)
      else
        original_base.send(:include, SuperModule::V1)
      end
    end

  end
  
end
