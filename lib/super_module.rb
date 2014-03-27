# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

module SuperModule
  def self.included(base)
    base.class_eval do
      class << self

        def include(base, &block)
          method_missing('include', base, &block)
        end

        def __super_module_class_method_invocations
          @__super_module_class_method_invocations ||= []
        end

        def __super_module_class_methods
          @__super_module_class_methods ||= []
        end

        def singleton_method_added(method_name)
          __super_module_class_methods << [method_name, method(method_name)] unless [:__super_module_class_methods, :included, :method_missing, :singleton_method_added].include?(method_name)
          super
        end

        def method_missing(method_name, *args, &block)
          __super_module_class_method_invocations << [method_name, args, block]
        end

        def included(base)
          __super_module_class_method_invocations.each do |method_name, args, block|
            base.class_eval do
              send(method_name, *args, &block)
            end
          end
          __super_module_class_methods.each do |method_name, method|
            base.class_eval do
              self.class.send(:define_method, method_name, &method)
            end
          end
          base.class_eval do
            class << self
              def method_missing(method_name, *args, &block)
                super
              end
            end
          end
        end
      end
    end
  end
end