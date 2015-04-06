# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014-2015 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

require 'method_source'
require 'logger'
module SuperModule
  LOG_LEVEL_DEFAULT = 'INFO'
  def self.logger
    @logger ||= Logger.new(STDOUT).tap {|logger_instance| logger_instance.level = Logger.const_get((ENV['SUPER_MODULE_LOG_LEVEL'] || LOG_LEVEL_DEFAULT).upcase)}
  end
  def self.logger=(logger_instance)
    @logger = logger_instance
  end
  def self.log(message, indent_option = nil, &block)
    log_indent << '  ' if indent_option == :indent
    log_indent[0, log_indent.length - 2] = '' if indent_option == :outdent
    message = "#{log_indent}#{message}"
    logger.log(Logger::DEBUG, message, 'SuperModule', &block)
  end
  def self.log_indent
    @indent ||= ''
  end
  def self.included(original_base)
    SuperModule.log "#{original_base} includes SuperModule"
    original_base.class_eval do
      class << self
        # excluded list of singleton methods to define (perhaps give a better name)
        def __super_module_singleton_methods_excluded_from_base_definition
          @__super_module_singleton_methods_excluded_from_base_definition ||= [
            :__super_module_singleton_methods,
            :__invoke_module_body_method_calls,
            :__define_super_module_singleton_methods,
            :__super_module_having_method,
            :included_super_modules,
            :included, 
            :singleton_method_added,
            :class_eval,
            :dbg_print, #debugger library friendly exclusion
            :dbg_puts #debugger library friendly exclusion
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

        def __super_module_having_method(method_name)
          included_super_modules.detect {|included_super_module| included_super_module.methods.map(&:to_s).include?(method_name.to_s)}
        end

        def __method_body(method_name)
            method_body = nil
            super_module_having_method_added = __super_module_having_method(method_name)
            if super_module_having_method_added.nil?
              method_body = self.method(method_name).source
              SuperModule.log "Method source for #{self.inspect}.#{method_name}: \n#{method_body}"
              method_definition_regex = /(send)?[ \t(:"']*def(ine_method)?[ \t,:"']+(self\.)?#{method_name}\)?[ \tdo{(|]*([^\n)|;]*)?[ \t)|;]*/m
              SuperModule.log "Method definition regex: #{method_definition_regex}"
              method_arg_match = method_body.match(method_definition_regex)
              SuperModule.log "Method argument match: #{method_arg_match.inspect}"
              if method_arg_match.nil?
                method_body = "def #{method_name}\n#{method_body}\nend" 
                SuperModule.log "Added method signature/end around signature-less method body: \n #{method_body}"
              end
              method_args = ("#{method_arg_match[4]}" if method_arg_match.to_a[4]).to_s.strip
              SuperModule.log "Method arguments: #{method_args.inspect}"
              method_call_recorder_args = "'#{method_name}'#{",#{method_args}" unless method_args.empty?}"
              SuperModule.log "Method call recorder arguments: #{method_call_recorder_args.inspect}" 
              method_call_recorder = (("self.__record_method_call(#{method_call_recorder_args})") if method_name.to_s != '__record_method_call')
              SuperModule.log "Method call recorder: #{method_call_recorder.inspect}" 
              method_body = method_body.sub(method_definition_regex, "class << self\ndefine_method('#{method_name}') do |#{method_args}|\n#{method_call_recorder}\n") + "\nend\n"
              SuperModule.log "Method body after formatting: \n #{method_body}"
            else
              method_body = super_module_having_method_added.__super_module_singleton_methods.detect {|sm_method_name, sm_method_body| sm_method_name == method_name}[1]
              SuperModule.log "Method body obtained from ancestor super module: #{method_body}"
            end
            method_body
        end

        def singleton_method_added(method_name)
          SuperModule.log "#{self.inspect} requests recording def method: #{method_name}"
          unless __super_module_singleton_methods_excluded_from_base_definition.include?(method_name)
            SuperModule.log "#{self} recording request for def method: #{method_name} has been accepted"
            method_body = __method_body(method_name)
            SuperModule.log "  define_method #{method_name}"
            __super_module_singleton_methods << [method_name, method_body] 
            if __super_module_having_method(method_name).nil?
              SuperModule.log "Adding method call recording ability to method body for #{self.inspect}.#{method_name}"
              __super_module_singleton_methods_excluded_from_base_definition << method_name
              self.class_eval(method_body)
            end
            SuperModule.log "#{self} request for recording def method: #{method_name} has finished"
          end
          super
        end

        #TODO handle case of a method call being passed a block (e.g. validates do custom validator end )
        def __record_method_call(method_name, *args, &block)
          SuperModule.log "#{self.inspect} requests recording method call: #{method_name}(#{args.to_a.map(&:to_s).join(",")})"
          return if self.is_a?(Class)
          SuperModule.log "#{self.inspect} recording request for method call: #{method_name}(#{args.to_a.map(&:to_s).join(",")}) has been accepted"
          __module_body_method_calls << [method_name, args, block]
        end

        def __all_module_body_method_calls_in_definition_order
          SuperModule.log "__module_body_method_calls.inspect: #{__module_body_method_calls.inspect}"
          SuperModule.log "included_super_modules: #{included_super_modules.inspect}"
          __module_body_method_calls + included_super_modules.map(&:__module_body_method_calls).flatten(1).reverse
        end

        def __invoke_module_body_method_calls(base)
          SuperModule.log "#{self.inspect}.__invoke_module_body_method_calls(#{base})", :indent
          SuperModule.log "all_module_body_method_calls_in_definition_order: #{ all_module_body_method_calls_in_definition_order }"
          __all_module_body_method_calls_in_definition_order.each do |method_name, args, block|
            SuperModule.log "Invoking #{base.inspect}.#{method_name}(#{args.to_a.map(&:to_s).join(",")})"
            base.send(method_name, *args, &block)
          end
          SuperModule.log "end of '#{self.inspect}.__invoke_module_body_method_calls(#{base})'\n", :outdent
        end

        def __define_super_module_singleton_methods(base)
          SuperModule.log "#{self.inspect}.__define_super_module_singleton_methods(#{base})", :indent
          __super_module_singleton_methods.each do |method_name, method_body|
            SuperModule.log "Before adding method #{method_name} the base class #{self.inspect} method count was: #{base.methods.size}"
            SuperModule.log "Adding method #{method_name} with method body: \n#{method_body}"
            base.class_eval(method_body)
            SuperModule.log "After adding method #{method_name} the new base class #{self.inspect} method count becomes: #{base.methods.size}"
          end
          SuperModule.log "end of '#{self.inspect}.__define_super_module_singleton_methods(#{base})'\n", :outdent
        end

        def included(base)
          SuperModule.log "#{base} includes #{self.inspect}"
          __define_super_module_singleton_methods(base)
          __invoke_module_body_method_calls(base)
        end
      end
    end
  end
end
