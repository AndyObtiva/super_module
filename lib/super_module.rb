# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014-2015 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

require 'method_source'
module SuperModule
  def self.included(original_base)
    original_base.class_eval do
      class << self
        # excluded list of singleton methods to define (perhaps give a better name)
        def __super_module_singleton_methods_excluded_from_base_definition
          @__super_module_singleton_methods_excluded_from_base_definition ||= [
            :__all_module_body_method_calls_in_definition_order,
            :__build_singleton_method_body_source,
            :__define_super_module_singleton_methods,
            :__invoke_module_body_method_calls,
            :__overwrite_singleton_method_from_current_super_module,
            :__singleton_method_args,
            :__singleton_method_body,
            :__singleton_method_body_for,
            :__singleton_method_call_recorder,
            :__singleton_method_definition_regex,
            :__super_module_having_method,
            :__super_module_singleton_methods,
            :__super_module_singleton_methods_excluded_from_base_definition,
            :__super_module_singleton_methods_excluded_from_call_recording,
            :class_eval,
            :dbg_print, #debugger library friendly exclusion
            :dbg_puts, #debugger library friendly exclusion
            :included, 
            :included_super_modules,
            :singleton_method_added
          ]
        end

        def __super_module_singleton_methods_excluded_from_call_recording
          @__super_module_singleton_methods_excluded_from_call_recording ||= [
            :__record_method_call,
            :__method_signature
          ]
        end

        def __module_body_method_calls
          @__module_body_method_calls ||= []
        end

        def __super_module_singleton_methods
          @__super_module_singleton_methods ||= []
        end
        
        def included_super_modules
          included_modules.select {|m| m.include?(SuperModule)}
        end

        def __singleton_method_body_for(super_module, method_name)
          super_module.__super_module_singleton_methods.detect {|sm_method_name, sm_method_body| sm_method_name == method_name}[1]
        end

        def __super_module_having_method(method_name)
          included_super_modules.detect {|included_super_module| included_super_module.methods.map(&:to_s).include?(method_name.to_s)}
        end

        def __singleton_method_definition_regex(method_name)
          /(send)?[ \t(:"']*def(ine_method)?[ \t,:"']+(self\.)?#{method_name}\)?[ \tdo{(|]*([^\n)|;]*)?[ \t)|;]*/m
        end

        def __singleton_method_call_recorder(method_args, method_name)
          method_call_recorder_args = "'#{method_name}'#{",#{method_args}" unless method_args.to_a.empty?}"
          (("self.__record_method_call(#{method_call_recorder_args})") unless __super_module_singleton_methods_excluded_from_call_recording.include?(method_name))
        end
  
        def __singleton_method_args(method_name, method_body)
          method_arg_match = method_body.match(__singleton_method_definition_regex(method_name))
          method_arg_match[4].strip if method_arg_match
        end

        def __build_singleton_method_body_source(method_name)
          method_body = self.method(method_name).source
          method_args = __singleton_method_args(method_name, method_body)
          method_body = "def #{method_name}\n#{method_body}\nend" if method_args.nil?
          class_self_method_def_enclosure = "class << self\ndefine_method('#{method_name}') do |#{method_args}|\n#{__singleton_method_call_recorder(method_args, method_name)}\n"
          method_body.sub(__singleton_method_definition_regex(method_name), class_self_method_def_enclosure) + "\nend\n"
        end

        def __singleton_method_body(method_name)
            super_module_having_method = __super_module_having_method(method_name)
            super_module_having_method ? __singleton_method_body_for(super_module_having_method, method_name) : __build_singleton_method_body_source(method_name) 
        end

        def __overwrite_singleton_method_from_current_super_module(method_name, method_body)
          if __super_module_having_method(method_name).nil?
            __super_module_singleton_methods_excluded_from_base_definition << method_name
            class_eval(method_body)
          end
        end

        def singleton_method_added(method_name)
          unless __super_module_singleton_methods_excluded_from_base_definition.include?(method_name)
            method_body = __singleton_method_body(method_name)
            __super_module_singleton_methods << [method_name, method_body] 
            __overwrite_singleton_method_from_current_super_module(method_name, method_body)
          end
        end

        def __method_signature(method_name, args)
          "#{method_name}(#{args.to_a.map(&:to_s).join(",")})"
        end

        #TODO handle case of a method call being passed a block (e.g. validates do custom validator end )
        def __record_method_call(method_name, *args, &block)
          return if self.is_a?(Class)
          __module_body_method_calls << [method_name, args, block]
        end

        def __all_module_body_method_calls_in_definition_order
          ancestor_module_body_method_calls = included_super_modules.map(&:__module_body_method_calls).flatten(1)
          all_module_body_method_calls = __module_body_method_calls + ancestor_module_body_method_calls
          all_module_body_method_calls.reverse
        end

        def __invoke_module_body_method_calls(base)
          __all_module_body_method_calls_in_definition_order.each do |method_name, args, block|
            base.send(method_name, *args, &block)
          end
        end

        def __define_super_module_singleton_methods(base)
          __super_module_singleton_methods.each do |method_name, method_body|
            base.class_eval(method_body)
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
