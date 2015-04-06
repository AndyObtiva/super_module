# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014-2015 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

# Avoiding require_relative for backwards compatibility with Ruby 1.8.7
require File.expand_path(File.join(File.dirname(__FILE__), 'super_module', 'module_body_method_call_recorder'))
require File.expand_path(File.join(File.dirname(__FILE__), 'super_module', 'singleton_method_definition_store'))

module SuperModule
  def self.included(original_base)
    original_base.class_eval do
      extend SuperModule::ModuleBodyMethodCallRecorder
      extend SuperModule::SingletonMethodDefinitionStore

      class << self
        def __define_super_module_singleton_methods(base)
          __super_module_singleton_methods.each do |method_name, method_body|
            base.class_eval(method_body)
          end
        end

        def __invoke_module_body_method_calls(base)
          __all_module_body_method_calls_in_definition_order.each do |method_name, args, block|
            base.send(method_name, *args, &block)
          end
        end

        def included(base)
          __define_super_module_singleton_methods(base)
          __invoke_module_body_method_calls(base)
        end
      end
    end
  end
end
