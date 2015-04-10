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
  class << self
  
    attr_accessor :super_module_body

    def define(&super_module_body)
      clone.tap { |super_module| super_module.super_module_body = super_module_body }
    end

    def included(original_base)
      if super_module_body
        original_base.class_eval(&super_module_body)
      else
        original_base.class_eval do
          extend SuperModule::ModuleBodyMethodCallRecorder
          extend SuperModule::SingletonMethodDefinitionStore

          class << self
            def __define_super_module_singleton_methods(base)
              __super_module_singleton_methods.each do |method_name, method_body|
                # The following is needed for cases where a method is declared public/protected/private after it was added
                refreshed_access_level_method_body = method_body.sub(/class << self\n(public|protected|private)\n/, "class << self\n#{__singleton_method_access_level(method_name)}\n")
                base.class_eval(refreshed_access_level_method_body)
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

  end
  
end
