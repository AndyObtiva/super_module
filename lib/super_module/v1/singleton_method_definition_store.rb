require 'method_source'
require File.expand_path(File.join(File.dirname(__FILE__), 'module_body_method_call_recorder')) # backwards compatible with Ruby 1.8.7

module SuperModule
  module V1
    module SingletonMethodDefinitionStore
      # excluded list of singleton methods to define (perhaps give a better name)
      def __super_module_singleton_methods_excluded_from_base_definition
        @__super_module_singleton_methods_excluded_from_base_definition ||= [
          :__all_module_body_method_calls_in_definition_order,
          :__build_singleton_method_body_source,
          :__define_super_module_singleton_methods,
          :__invoke_module_body_method_calls,
          :__module_body_method_calls,
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
          :define,
          :included,
          :super_module_included,
          :included_super_modules,
          :singleton_method_added,
        ]
      end

      def __super_module_singleton_methods
        @__super_module_singleton_methods ||= []
      end

      def __singleton_method_body_for(super_module, method_name)
        super_module.__super_module_singleton_methods.detect {|sm_method_name, sm_method_body| sm_method_name == method_name}[1]
      end

      def included_super_modules
        included_modules.select {|m| m.include?(SuperModule)}
      end

      def __all_methods(object)
        object.public_methods + object.protected_methods + object.private_methods
      end

      def __super_module_having_method(method_name)
        included_super_modules.detect {|included_super_module| __all_methods(included_super_module).map(&:to_s).include?(method_name.to_s)}
      end

      def __singleton_method_definition_regex(method_name)
        /(public|protected|private)?(send)?[ \t(:"']*def(ine_method)?[ \t,:"']+(self\.)?#{method_name}\)?[ \tdo{(|]*([^\n)|;]*)?[ \t)|;]*/m
      end

      def __singleton_method_args(method_name, method_body)
        method_arg_match = method_body.match(__singleton_method_definition_regex(method_name)).to_a[5]
      end

      def __singleton_method_access_level(method_name)
        %w(private protected public).detect do |method_access|
          method_group = "#{method_access}_methods"
          send(method_group).map(&:to_s).include?(method_name.to_s)
        end
      end

      def __build_singleton_method_body_source(method_name)
        the_method = self.method(method_name)
        method_body = the_method.source
        method_original_name = the_method.original_name
        aliased = method_original_name != method_name
        method_args = __singleton_method_args(method_original_name, method_body)
        method_body = "def #{method_name}\n#{method_body}\nend" if method_args.nil?
        class_self_method_def_enclosure = "class << self\n#{__singleton_method_access_level(method_name)}\ndef #{method_name}(#{method_args})\n#{__singleton_method_call_recorder(method_name, method_args)}\n"
        method_body.sub(__singleton_method_definition_regex(method_original_name), class_self_method_def_enclosure) + "\nend\n"
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
        if method_name.to_s == 'included' && !method(method_name).source_location.first.include?('super_module/v1')
          raise 'Do not implement "self.included(base)" hook for a super module! Use "super_module_included {|base| ... }" instead.'
        end
        unless __super_module_singleton_methods_excluded_from_base_definition.include?(method_name)
          method_body = __singleton_method_body(method_name)
          __super_module_singleton_methods << [method_name, method_body]
          __overwrite_singleton_method_from_current_super_module(method_name, method_body)
        end
      end

      def self.extended(base)
        base.extend(SuperModule::V1::ModuleBodyMethodCallRecorder) unless base.is_a?(SuperModule::V1::ModuleBodyMethodCallRecorder)
        base.singleton_method_added(:__method_signature)
        base.singleton_method_added(:__record_method_call)
      end
    end
  end
end
