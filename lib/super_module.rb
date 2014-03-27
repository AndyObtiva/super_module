# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

module SuperModule
  EXCLUDED_SINGLETON_METHODS = [
    :__super_module_class_methods,
    :__invoke_super_module_class_method_calls,
    :__define_super_module_class_methods,
    :__restore_original_method_missing,
    :included, :method_missing,
    :singleton_method_added
  ]
  def self.included(base)
    base.class_eval do
      class << self

        def include(base, &block)
          method_missing('include', base, &block)
        end

        def __super_module_class_method_calls
          @__super_module_class_method_calls ||= []
        end

        def __super_module_class_methods
          @__super_module_class_methods ||= []
        end

        def singleton_method_added(method_name)
          __super_module_class_methods << [method_name, method(method_name)] unless EXCLUDED_SINGLETON_METHODS.include?(method_name)
          super
        end

        def method_missing(method_name, *args, &block)
          __super_module_class_method_calls << [method_name, args, block]
        end

        def __invoke_super_module_class_method_calls(base)
          __super_module_class_method_calls.each do |method_name, args, block|
            base.class_eval do
              send(method_name, *args, &block)
            end
          end
        end

        def __define_super_module_class_methods(base)
          __super_module_class_methods.each do |method_name, method|
            base.class_eval do
              self.class.send(:define_method, method_name, &method)
            end
          end
        end

        def included(base)
          __invoke_super_module_class_method_calls(base)
          __define_super_module_class_methods(base)
        end
      end
    end
  end
end