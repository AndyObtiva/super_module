require File.expand_path(File.join(File.dirname(__FILE__), 'v1', 'module_body_method_call_recorder'))
require File.expand_path(File.join(File.dirname(__FILE__), 'v1', 'singleton_method_definition_store'))

module SuperModule
  module V1
    class << self
      def included(original_base)
        # TODO maybe avoid class_eval by extending/including instead
        original_base.class_eval do
          extend SuperModule::V1::ModuleBodyMethodCallRecorder
          extend SuperModule::V1::SingletonMethodDefinitionStore

          class << self
            def __define_super_module_singleton_methods(base)
              __super_module_singleton_methods.each do |method_name, method_body|
                # The following is needed for cases where a method is declared public/protected/private after it was added
                refreshed_access_level_method_body = method_body.sub(/class << self\n(public|protected|private)\n/, "class << self\n#{__singleton_method_access_level(method_name)}\n")
                base.class_eval(refreshed_access_level_method_body)
              end
            end

            def __invoke_module_body_method_calls(base)
              __all_module_body_method_calls_in_definition_order.each do |method_name, args, block|
                base.send(method_name, *args, &block)
              end
            end

            def included(base)
              __define_super_module_singleton_methods(base)
              __invoke_module_body_method_calls(base)
              super_module_included.each do |block|
                self.__inside_super_module_included = true
                base.__inside_super_module_included = true       
                block.binding.receiver.__inside_super_module_included = true       
                block.call(base)
                block.binding.receiver.__inside_super_module_included = false
                base.__inside_super_module_included = false
                self.__inside_super_module_included = false
              end
              if base.ancestors.include?(SuperModule) && !base.is_a?(Class)
                super_module_included.reverse.each do |block|
                  base.super_module_included.unshift(block)
                end
              end
            end

            def super_module_included(&block)
              if block_given?
                super_module_included << block
              else
                @super_module_included_blocks ||= []
              end
            end
          end
        end
      end
    end
  end
end
