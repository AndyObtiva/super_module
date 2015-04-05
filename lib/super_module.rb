# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

require 'method_source'
require 'logger'
#TODO refactor names to be much more friendly
#TODO sanitize logging debug messages to make more consumer developer friendly
module SuperModule
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
  def self.logger=(logger_instance)
    @logger = logger_instance
  end
  def self.log(message, indent_option = nil)
    log_indent << '  ' if indent_option == :indent
    log_indent[0, log_indent.length - 2] = '' if indent_option == :outdent
    message = "#{log_indent}#{message}"
    logger.log(Logger::DEBUG, message, 'SuperModule')
  end
  def self.log_indent
    @indent ||= ''
  end
  def self.included(original_base)
    SuperModule.log "#{original_base} includes SuperModule"
    original_base.class_eval do
      class << self

        #def include(base_module, &block)
        #  method_missing('include', base_module, &block)# unless base_module == SuperModule
        #end

        # excluded list of singleton methods to define (perhaps give a better name)
        def __excluded_singleton_methods
          @__excluded_singleton_methods ||= [
            :__super_module_class_methods,
            :__invoke_super_module_class_method_calls,
            :__define_super_module_class_methods,
            :__restore_original_method_missing,
            :__super_module_having_method,
            :included_super_modules,
            :included, 
            :singleton_method_added,
            :class_eval,
            :dbg_print, #debugger library friendly exclusion
            :dbg_puts #debugger library friendly exclusion
          ]
        end

        def __super_module_class_method_calls
          @__super_module_class_method_calls ||= []
        end

        def __super_module_class_methods
          @__super_module_class_methods ||= []
        end
        
        def included_super_modules
          included_modules.select {|m| m.include?(SuperModule)}
        end

        def __super_module_having_method(method_name)
          included_super_modules.detect {|included_super_module| included_super_module.methods.map(&:to_s).include?(method_name.to_s)}
        end

        def singleton_method_added(method_name)
          SuperModule.log "#{self.inspect} requests recording def method: #{method_name}"
          unless __excluded_singleton_methods.include?(method_name)
            SuperModule.log "#{self} records def method: #{method_name} has been accepted"
            #the following line is responsible for methods having the module as self instead of the class
            method_body = nil
            super_module_having_method_added = __super_module_having_method(method_name)
            #TODO add method_recorder here and not upon invocation
            if super_module_having_method_added.nil?
              method = self.method(method_name)
              method_body = method.source
              SuperModule.log "Method source for #{self.inspect}.#{method_name}: \n#{method_body}"
              method_definition_regex = /(send)?[ \t(:"']*def(ine_method)?[ \t,:"']+(self\.)?#{method_name}\)?[ \tdo{(|]*([^\n)|;]*)?[ \t)|;]*/m
              method_arg_match = method_body.match(method_definition_regex)
              SuperModule.log "method_arg_match.inspect #{method_arg_match.inspect}"
              method_args = ("#{method_arg_match[4]}" if method_arg_match[4])
              method_recorder_args = "'#{method_name}'#{",#{method_args}" if method_args}"
              #TODO handle case of a method call being passed a block (e.g. validates do custom validator end )
              method_recorder = (("self.__record_method_call(#{method_recorder_args})") if method_name.to_s != '__record_method_call')
              new_method_body = method_body.gsub(method_definition_regex, "class << self\ndefine_method('#{method_name}') do |#{method_args}|\n#{method_recorder}\n") + "\nend\n"
              SuperModule.log "<<< new singleton method body begins"
              SuperModule.log new_method_body
              SuperModule.log ">>> new singleton method body ends"
              method_body = new_method_body
            else
              method_body = super_module_having_method_added.__super_module_class_methods.detect {|sm_method_name, sm_method_body| sm_method_name == method_name}[1]
            end

            SuperModule.log "  define_method #{method_name}"
            __super_module_class_methods << [method_name, method_body] 
            if super_module_having_method_added.nil?
              SuperModule.log "Adding method call recording ability to method body for #{self.inspect}.#{method_name}"
              __excluded_singleton_methods << method_name
              self.class_eval(method_body)
            end
            SuperModule.log "#{self} request for recording def method: #{method_name} has finished"
          end
          super
        end

        #TODO this is my next problem. It is not recording when Foo has inherited methods from FakeActiveModel and is calling validates with some properties
        # so then when a class includes FOo, it does not inherit the validates method call
        # PERHAPS add an interceptor to all methods matching one of these cases:
        # 1. super module class method calls for inherited methods (redefined here during self.included(base))
        # 2. super module class method calls for methods defined here (e.g. a module that def self.make_barrable and then call to make_barrable)

        def __record_method_call(method_name, *args, &block)
          SuperModule.log "#{self.inspect} requests recording method call: #{method_name}(#{args.to_a.map(&:to_s).join(",")})"
          return if self.is_a?(Class)
          SuperModule.log "#{self.inspect} records method call: #{method_name}(#{args.to_a.map(&:to_s).join(",")})"
          __super_module_class_method_calls << [method_name, args, block]
        end

        #TODO rename class_method_calls to singleton_method_calls
        #TODO handle case where methods being invoked are also defined in the same super module not inherited from another super module (thus not recorded, are they?)
        def __invoke_super_module_class_method_calls(base)
          SuperModule.log "#{self.inspect}.__invoke_super_module_class_method_calls(#{base})", :indent
          SuperModule.log "__super_module_class_method_calls.inspect: #{__super_module_class_method_calls.inspect}"
          SuperModule.log "included_super_modules: #{included_super_modules.inspect}"
          SuperModule.log "included_super_modules.map(&:__super_module_class_method_calls).flatten(1): #{included_super_modules.map(&:__super_module_class_method_calls).flatten(1)}"
          all_class_method_calls = __super_module_class_method_calls + included_super_modules.map(&:__super_module_class_method_calls).flatten(1)
          all_class_method_calls_in_definition_order = all_class_method_calls.reverse
          all_class_method_calls_in_definition_order.each do |method_name, args, block|
            base.class_eval do
              SuperModule.log "#{method_name}(#{args.to_a.map(&:to_s).join(",")})"
              send(method_name, *args, &block)
            end
          end
          SuperModule.log "end of '#{self.inspect}.__invoke_super_module_class_method_calls(#{base})'\n", :outdent
        end

        def __define_super_module_class_methods(base)
          SuperModule.log "#{self.inspect}.__define_super_module_class_methods(#{base})", :indent
          __super_module_class_methods.each do |method_name, method_body|
            SuperModule.log "\n * Before adding method: #{method_name}"
            SuperModule.log "base class method size: #{base.methods.size}"
            SuperModule.log "<<< method begins"
            SuperModule.log method_body
            SuperModule.log ">>> method ends"

            base.class_eval(method_body)

            SuperModule.log " ** After adding method: #{method_name}"
            SuperModule.log "new base class method size: #{base.methods.size}"
            
          end
          SuperModule.log "end of '#{self.inspect}.__define_super_module_class_methods(#{base})'\n", :outdent
        end

        def included(base)
          SuperModule.log "118: #{self.inspect}.included(#{base}) ..."
          SuperModule.log "#{base} includes #{self.inspect}"
          __define_super_module_class_methods(base)
          __invoke_super_module_class_method_calls(base)
        end
      end
    end
  end
end
