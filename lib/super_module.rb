# SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).
#
# Author::    Andy Maleh
# Copyright:: Copyright (c) 2014-2015 Andy Maleh
# License::   MIT License

# This module allows defining class methods and method invocations the same way a super class does without using def included(base).

# Avoiding require_relative for backwards compatibility with Ruby 1.8.7

module SuperModule
  class << self
    V1_LIBRARY = File.expand_path(File.join(File.dirname(__FILE__), 'super_module', 'v1'))
  
    attr_accessor :super_module_body

    def define(&super_module_body)
      clone.tap { |super_module| super_module.super_module_body = super_module_body }
    end

    def included(original_base)
      if super_module_body
        original_base.class_eval do
          puts 'Defining: ' + "method_added_copy_by_#{name}"
          define_singleton_method("method_added_copy_by_#{name}", method(:method_added))
          class << self
            attr_accessor :__backed_up_instance_methods
            def method_added(name)
              puts "#{name} method added..."
              backed_up_instance_method = __backed_up_instance_methods.delete(name.to_s) rescue nil
              send(:define_method, name, backed_up_instance_method) if backed_up_instance_method
            end
          end
        end
        original_base.__backed_up_instance_methods = __backup_instance_methods(original_base)
        puts "#{original_base}.__backed_up_instance_methods: #{original_base.__backed_up_instance_methods.map(&:first).sort.inspect}"
        original_base.class_eval(&super_module_body)
        original_base.class_eval do
          #puts 'before removal listing'
          #puts self.instance_methods.sort.inspect
          puts 'UnDefining: ' + "method_added_copy_by_#{name}"
          #define_singleton_method(:method_added, method("method_added_copy_by_#{name}"))
          #class << self
          #  remove_method("method_added_copy_by_#{to_s.split(/:|>/).last}")
          #end
        end
      else
        require V1_LIBRARY
        original_base.send(:include, SuperModule::V1)
      end
    end

    def __super_module_parent(name, ancestor)
      name_tokens = name.to_s.split('::')
      name_token_count = name_tokens.size
      if name_token_count == 1
        ancestor
      else
        top_ancestor = ancestor.const_get(name_tokens.first)
        sub_module_name = name_tokens[1, name_token_count].join('::')
        __super_module_parent(sub_module_name, top_ancestor)
      end
    end

    def __backup_instance_methods(base)
      %w(private protected public).map do |method_type|
        method_collection_name = "#{method_type}_instance_methods"
        base.send(method_collection_name).inject({}) do |output, method_name|
          output.merge(method_name.to_s => base.instance_method(method_name))
        end
      end.reduce(:merge).tap do |output|
        print 'Method foo already exists?'
        puts output['foo']
      end
    end

  end
  
end

def super_module(name=nil, &super_module_body)
  initial_ancestor = self.class == Object ? Object : self
  SuperModule.define(&super_module_body).tap do |new_super_module|
    if name
      parent = SuperModule.__super_module_parent(name, initial_ancestor)
      module_name = name.to_s.split('::').last
      parent.const_set(module_name, new_super_module)
    end
  end
end

