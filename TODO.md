# TODO

- Replay class level attributes on classes
- Fix issue with class methods including a method matching name with instance methods
- Fix issue with class method alias as per details below

```ruby
require 'glimmer/error'

module Glimmer
  module UI
    module CustomShell
      include SuperModule
      include Glimmer::UI::CustomWidget
      
      class << self
        attr_reader :launched_custom_shell
        alias launched_custom_window launched_custom_shell
```

```
[DEVELOPMENT MODE] (detected /Users/andymaleh/code/glimmer-dsl-swt/lib/glimmer-dsl-swt.rb)
MethodSource::SourceNotFoundError: Could not locate source for launched_custom_window!
                         source_helper at /Users/andymaleh/.rvm/gems/jruby-9.2.14.0@glimmer-dsl-swt/gems/method_source-1.0.0/lib/method_source.rb:24
                                source at /Users/andymaleh/.rvm/gems/jruby-9.2.14.0@glimmer-dsl-swt/gems/method_source-1.0.0/lib/method_source.rb:110
  __build_singleton_method_body_source at /Users/andymaleh/.rvm/gems/jruby-9.2.14.0@glimmer-dsl-swt/gems/super_module-1.4.1/lib/super_module/v1/singleton_method_definition_store.rb:74
               __singleton_method_body at /Users/andymaleh/.rvm/gems/jruby-9.2.14.0@glimmer-dsl-swt/gems/super_module-1.4.1/lib/super_module/v1/singleton_method_definition_store.rb:85
                singleton_method_added at /Users/andymaleh/.rvm/gems/jruby-9.2.14.0@glimmer-dsl-swt/gems/super_module-1.4.1/lib/super_module/v1/singleton_method_definition_store.rb:100
                          alias_method at org/jruby/RubyModule.java:3228
                       singleton class at /Users/andymaleh/code/glimmer-dsl-swt/lib/glimmer/ui/custom_shell.rb:32
```
