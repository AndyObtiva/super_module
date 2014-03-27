# SuperModule
[![Gem Version](https://badge.fury.io/rb/super_module.png)](http://badge.fury.io/rb/super_module)
[![Build Status](https://api.travis-ci.org/AndyObtiva/super_module.png?branch=master)](https://travis-ci.org/AndyObtiva/super_module)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/super_module/badge.png?branch=master)](https://coveralls.io/r/AndyObtiva/super_module?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/super_module.png)](https://codeclimate.com/github/AndyObtiva/super_module)

Tired of Ruby's modules not allowing you to mix in class methods easily?
Tired of writing complex code and using complex libraries like ActiveSupport::Concern to accomplish that goal?

Well, worry no more! SuperModule comes to the rescue!

![SuperModule](https://raw.githubusercontent.com/AndyObtiva/super_module/master/SuperModule.jpg)

SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base).

This succeeds ActiveSupport::Concern by offering lighter syntax and simpler module dependency support.

## Instructions

### 1) Install and require gem

<b>Using Bundler</b>

Add the following to Gemfile: <pre>gem 'super_module', '1.0.0'</pre>
Run: <code>bundle</code>

It will automatically get required in the application when loading with bundler (e.g. in a Rails application)

<b>Using RubyGem Directly</b>

Run: <pre>gem install super_module</pre>
(add <code>--no-ri --no-rdoc</code> if you wish to skip downloading them for a faster install)

Add <code>require 'super_module'</code> at the top of your Ruby file

### 2) Include SuperModule at the top of the module

>     module UserIdentifiable
>       include SuperModule
>
>       belongs_to :user
>       validates :user_id, presence: true
>
>       def self.most_active_user
>         User.find_by_id(select('count(id) as head_count, user_id').group('user_id').order('count(id) desc').first.user_id)
>       end
>
>       def slug
>         "#{self.class.name}_#{user_id}"
>       end
>     end

### 3) Mix newly defined module into a class or another super module

>     class ClubParticipation < ActiveRecord::Base
>       include UserIdentifiable
>     end
>     class CourseEnrollment < ActiveRecord::Base
>       include UserIdentifiable
>     end
>     module Accountable
>       include SuperModule
>       include UserIdentifiable
>     end
>     class Activity < ActiveRecord::Base
>       include Accountable
>     end

### 4) Start using by invoking class methods or instance methods

>     CourseEnrollment.most_active_user
>     ClubParticipation.most_active_user
>     Activity.last.slug
>     ClubParticipation.create(club_id: club.id, user_id: user.id).slug
>     CourseEnrollment.new(course_id: course.id).valid?

## Example

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

## Design Limitations

This has been designed to be used only in the code definition of a module.

## Copyright

Copyright (c) 2014 Andy Maleh. See LICENSE.txt for
further details.

