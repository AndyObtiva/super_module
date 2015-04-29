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
        original_base.class_eval(&super_module_body)
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

