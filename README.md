= super_module
[![Gem Version](https://badge.fury.io/rb/super_module.png)](http://badge.fury.io/rb/super_module)
[![Build Status](https://api.travis-ci.org/AndyObtiva/super_module.png?branch=master)](https://travis-ci.org/AndyObtiva/super_module)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/super_module/badge.png?branch=master)](https://coveralls.io/r/AndyObtiva/super_module?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/super_module.png)](https://codeclimate.com/github/AndyObtiva/super_module)

SuperModule allows defining class methods and method invocations the super way a super class does without using def included(base).

This succeeds ActiveSupport::Concern by offering lighter syntax

== Example Usage

>     require 'super_module'
>
>     module Foo
>       include SuperModule
>
>       validates :credit_card_id, presence: true
>
>       def foo
>         puts 'foo'
>         'foo'
>       end
>
>       def self.foo
>         puts 'self.foo'
>         'self.foo'
>       end
>     end
>
>     module Bar
>       include SuperModule
>       include Foo
>
>       validates :user_id, presence: true
>
>       def bar
>         puts 'bar'
>         'bar'
>       end
>
>       def self.bar
>         puts 'self.bar'
>         'self.bar'
>       end
>     end
>
>     class MediaAuthorization < ActiveRecord::Base
>       include Bar
>     end
>
>     MediaAuthorization.create.errors.messages.inspect

=> "{:credit_card_id=>[\"can't be blank\"], :user_id=>[\"can't be blank\"]}"

>     MediaAuthorization.new.foo

=> "foo"

>     MediaAuthorization.new.bar

=> "bar"

>     MediaAuthorization.foo

=> "self.foo"

>     MediaAuthorization.bar

=> "self.bar"

== Copyright

Copyright (c) 2014 Andy Maleh. See LICENSE.txt for
further details.

