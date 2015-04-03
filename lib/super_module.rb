# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

if RUBY_VERSION == '1.8.7'
  require 'ruby18_source_location'
end
require 'ruby_parser'
$indent = ''
alias puts2 puts
def puts(text)
  print($indent)
  puts2(text)
end
module SuperModule
  EXCLUDED_SINGLETON_METHODS = [
    :__super_module_class_methods,
    :__invoke_super_module_class_method_calls,
    :__define_super_module_class_methods,
    :__restore_original_method_missing,
    :__super_module_having_method,
    :__record_method_call,
    :included_super_modules,
    :included, 
    :singleton_method_added,
    :class_eval
  ]
  def self.included(original_base)
    puts "#{original_base} includes SuperModule"
    #TODO call super afterward?
    original_base.class_eval do
      class << self

        #def include(base_module, &block)
        #  method_missing('include', base_module, &block)# unless base_module == SuperModule
        #end

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
          puts "#{self} requests recording def method: #{method_name}"
          unless EXCLUDED_SINGLETON_METHODS.include?(method_name)
            #the following line is responsible for methods having the module as self instead of the class
            method_body = nil
            super_module_having_method_added = __super_module_having_method(method_name)
            if super_module_having_method_added.nil?
              method = self.method(method_name)
              method_file = method.source_location[0]
              puts "method_file: #{method_file}"
              method_file_content = File.open(method_file, 'r') {|f| f.read}
              #puts "method_file_content: #{method_file_content}"
              parsed_method_file_content = RubyParser.new.parse(method_file_content)
              method_source_location = method.source_location[1]
              puts "method_source_location: #{method_source_location}"
              parsed_method_sexp = nil; 
              parsed_method_file_content.deep_each {|sexp| parsed_method_sexp = sexp if parsed_method_sexp.nil? && sexp.line == method_source_location}
              puts parsed_method_sexp.inspect
              method_source_location_end = (parsed_method_sexp && parsed_method_sexp.last.line) || method_source_location
              puts "method_source_location_end: #{method_source_location_end}"
              method_body = method_file_content.to_s.split("\n")[(method_source_location-1)..(method_source_location_end)].join("\n")
            else
              method_body = super_module_having_method_added.__super_module_class_methods.detect {|sm_method_name, sm_method_body| sm_method_name == method_name}[1]
            end

            #TODO handle case of \r\n lines as well
            #TODO handle case of methods wrapped by class << self
            puts "  define_method #{method_name}"
            __super_module_class_methods << [method_name, method_body] 
            puts "#{self} request for recording def method: #{method_name} has been accepted"
          end
          super
        end

        #TODO this is my next problem. It is not recording when Foo has inherited methods from FakeActiveModel and is calling validates with some properties
        # so then when a class includes FOo, it does not inherit the validates method call
        # PERHAPS add an interceptor to all methods matching one of these cases:
        # 1. super module class method calls for inherited methods (redefined here during self.included(base))
        # 2. super module class method calls for methods defined here (e.g. a module that def self.make_barrable and then call to make_barrable)

        def __record_method_call(method_name, *args, &block)
          puts "#{self.inspect} is recording method call: #{method_name}(#{args.to_a.map(&:to_s).join(",")})"
          __super_module_class_method_calls << [method_name, args, block]
        end

        #TODO rename class_method_calls to singleton_method_calls
        #TODO handle case where methods being invoked are also defined in the same super module not inherited from another super module (thus not recorded, are they?)
        def __invoke_super_module_class_method_calls(base)
          puts "#{self.inspect}.__invoke_super_module_class_method_calls(#{base})"
          $indent += '  '
          puts "__super_module_class_method_calls.inspect: #{__super_module_class_method_calls.inspect}"
          puts "included_super_modules: #{included_super_modules.inspect}"
          puts "included_super_modules.map(&:__super_module_class_method_calls).flatten(1): #{included_super_modules.map(&:__super_module_class_method_calls).flatten(1)}"
          all_class_method_calls = __super_module_class_method_calls + included_super_modules.map(&:__super_module_class_method_calls).flatten(1)
          all_class_method_calls_in_definition_order = all_class_method_calls.reverse
          all_class_method_calls_in_definition_order.each do |method_name, args, block|
            base.class_eval do
              puts "#{method_name}(#{args.to_a.map(&:to_s).join(",")})"
              send(method_name, *args, &block)
            end
          end
          $indent = $indent[0, $indent.length - 2]
          puts "end of '#{self.inspect}.__invoke_super_module_class_method_calls(#{base})'\n"
        end

        def __define_super_module_class_methods(base)
          puts "#{self.inspect}.__define_super_module_class_methods(#{base})"
          $indent += '  '
          __super_module_class_methods.each do |method_name, method_body|
            #puts "\n * Before adding method: #{method_name}"
            #puts "base class method size: #{base.methods.size}"
            #puts "<<< method begins"
            #puts method_body
            #puts ">>> method ends"
            method_arg_match = method_body.match(/def (self\.)?#{method_name}(\(([^)]+)\))?/m)
            #puts "method_arg_match.inspect #{method_arg_match.inspect}"
            method_args = ("#{method_arg_match[3]}" if method_arg_match[3])
            method_recorder_args = "'#{method_name}'#{",#{method_args}" if method_args}"
            #TODO handle case of a method call being passed a block (e.g. validates do custom validator end )
            method_recorder = ("self.__record_method_call(#{method_recorder_args})" if !base.is_a?(Class) && base.include?(SuperModule))
            new_method_body = method_body.gsub(/def (self\.)?#{method_name}(\(([^)]+)\))?/m, "class << self\ndefine_method('#{method_name}') do |#{method_args}|\n#{method_recorder}\n") + "\nend\n"
            puts "<<< new method begins"
            puts new_method_body
            puts ">>> new method ends"
            base.class_eval(new_method_body)
            #debugger
            #puts " ** After adding method: #{method_name}"
            #puts "new base class method size: #{base.methods.size}"
            
          end
          $indent = $indent[0, $indent.length - 2]
          puts "end of '#{self.inspect}.__define_super_module_class_methods(#{base})'\n"
        end

        def included(base)
          puts "118: #{self.inspect}.included(#{base}) ..."
          puts "#{base} includes #{self.inspect}"
          __define_super_module_class_methods(base)

          #TODO why is the following not getting called on FooActiveRecord???
          __invoke_super_module_class_method_calls(base)
          #TODO call super?
        end
      end
    end
  end
end
