module SuperModule
  module V1
    module ModuleBodyMethodCallRecorder
      def __super_module_singleton_methods_excluded_from_call_recording
        @__super_module_singleton_methods_excluded_from_call_recording ||= [
          :__record_method_call,
          :__method_signature
        ]
      end

      def __module_body_method_calls
        @__module_body_method_calls ||= []
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

      def __singleton_method_call_recorder(method_name, method_args)
        unless __super_module_singleton_methods_excluded_from_call_recording.include?(method_name)
          method_call_recorder_args = "'#{method_name}'"
          method_call_recorder_args << ", #{method_args}" unless method_args.to_s.strip == '' 
          "self.__record_method_call(#{method_call_recorder_args})" 
        end
      end
    end
  end
end
   

