# SuperModule
[![Gem Version](https://badge.fury.io/rb/super_module.png)](http://badge.fury.io/rb/super_module)
[![Build Status](https://api.travis-ci.org/AndyObtiva/super_module.png?branch=master)](https://travis-ci.org/AndyObtiva/super_module)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/super_module/badge.png?branch=master)](https://coveralls.io/r/AndyObtiva/super_module?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/super_module.png)](https://codeclimate.com/github/AndyObtiva/super_module)

Tired of Ruby's modules not allowing you to mix in class methods easily?
Tired of writing complex code and using complex libraries like ActiveSupport::Concern to accomplish that goal?

Well, worry no more! SuperModule comes to the rescue!

![SuperModule](https://raw.githubusercontent.com/AndyObtiva/super_module/master/SuperModule.jpg)

In addition to basic Ruby module functionality, SuperModule allows definition and invocation of class (and module) methods the same way a super class does without the need for using <code>def included(base)</code>.

This succeeds ActiveSupport::Concern by offering lighter syntax and simpler module dependency support.

## Introductory Comparison

To introduce SuperModule, here is a comparison of three different approaches for writing a
UserIdentifiable module. 

#### 1) self.included(base)

module UserIdentifiable
  include ActiveModel::Model

  def self.included(base_klass)
    base_klass.extend(ClassMethods)
    base.class_eval do
      belongs_to :user
      validates :user_id, presence: true
    end
  end
  
  module ClassMethods
    def most_active_user
      User.find_by_id(select('count(id) as head_count, user_id').group('user_id').order('count(id) desc').first.user_id)
    end
  end
  
  def slug
    "#{self.class.name}_#{user_id}"
  end
end

This is a lot to think about and process for simply wanting inclusion of class method definitions (like <code>most_active_user</code>) and class method invocations (like <code>belongs_to</code> and <code>validates</code>). The unnecessary complexity gets in the way of problem-solving; slows down productivity with repetitive boiler-plate code; and breaks expectations set in other similar object-oriented languages, discouraging companies from including Ruby in a polyglot stack, such as Groupon's Ruby/Java/Node.js stack and SoundCloud's JRuby/Scala/Clojure stack.

#### 2) ActiveSupport::Concern

module UserIdentifiable
  extend ActiveSupport::Concern
  include ActiveModel::Model

  included do
    belongs_to :user
    validates :user_id, presence: true
  end
  
  module ClassMethods
    def most_active_user
      User.find_by_id(select('count(id) as head_count, user_id').group('user_id').order('count(id) desc').first.user_id)
    end
  end
  
  def slug
    "#{self.class.name}_#{user_id}"
  end
end

A step forward that addresses the boiler-plate DRY concern, but is otherwise really just lipstick on a pig.

#### 3) SuperModule

module UserIdentifiable
  include SuperModule
  include ActiveModel::Model
  
  belongs_to :user
  validates :user_id, presence: true

  def self.most_active_user
    User.find_by_id(select('count(id) as head_count, user_id').group('user_id').order('count(id) desc').first.user_id)
  end

  def slug
    "#{self.class.name}_#{user_id}"
  end
end

SuperModule provides a simple conventional object-oriented approach that works just as expected. Given that it collapses difference between having a base class extend a super class or include a super module, it encourages as a side benefit writing better Object-Oriented code and helps Ruby be more polyglot and beginner friendly.

## Instructions

#### 1) Install and require gem

<b>Using [Bundler](http://bundler.io/)</b>

Add the following to Gemfile: <pre>gem 'super_module', '1.0.0'</pre>

And run the following command: <pre>bundle</pre>

Afterwards, SuperModule will automatically get required in the application (e.g. a Rails application) and be ready for use.

<b>Using [RubyGem](https://rubygems.org/gems/super_module) Directly</b>

Run the following command: <pre>gem install super_module</pre>

(add <code>--no-ri --no-rdoc</code> if you wish to skip downloading documentation for a faster install)

Add the following at the top of your Ruby file: <pre>require 'super_module'</pre>

#### 2) Include SuperModule at the top of the module

module UserIdentifiable
  include SuperModule
  include ActiveModel::Model

  belongs_to :user
  validates :user_id, presence: true

  def self.most_active_user
    User.find_by_id(select('count(id) as head_count, user_id').group('user_id').order('count(id) desc').first.user_id)
  end

  def slug
    "#{self.class.name}_#{user_id}"
  end
end

#### 3) Mix newly defined module into a class or another super module

class ClubParticipation < ActiveRecord::Base
  include UserIdentifiable
end
class CourseEnrollment < ActiveRecord::Base
  include UserIdentifiable
end
module Accountable
  include SuperModule
  include UserIdentifiable
end
class Activity < ActiveRecord::Base
  include Accountable
end

#### 4) Start using by invoking class methods or instance methods

CourseEnrollment.most_active_user
ClubParticipation.most_active_user
Activity.last.slug
ClubParticipation.create(club_id: club.id, user_id: user.id).slug
CourseEnrollment.new(course_id: course.id).valid?

## Glossary

 * SuperModule: name of the library and Ruby module that provides functionality via mixin
 * Super module: any Ruby module that mixes in SuperModule
 * Class method definition: Ruby class or module method declared with <code>self.method_name</code> or <code>class << self</code>
 * Class method invocation: Inherited Ruby class or module method invoked in the body of a class or module (e.g. <code>validates :username, presence: true</code>)
 * Code-time: Time of writing code in a Ruby file as opposed to Run-time
 * Run-time: Time of executing Ruby code

## Usage Details

 * SuperModule must always be included at the top of a module's body at code-time
 * SuperModule inclusion can be optionally followed by other basic or super module inclusions
 * A super module can only be included in a class or another super module
 * SuperModule adds <b>zero cost</b> to instantiation of including classes and invocation of included methods (both class and instance)

## Another Example

require 'super_module'

module Foo
  include SuperModule

  validates :credit_card_id, presence: true

  def foo
    puts 'foo'
    'foo'
  end

  def self.foo
    puts 'self.foo'
    'self.foo'
  end
end

module Bar
  include SuperModule
  include Foo

  validates :user_id, presence: true

  def bar
    puts 'bar'
    'bar'
  end

  def self.bar
    puts 'self.bar'
    'self.bar'
  end
end

class MediaAuthorization < ActiveRecord::Base
  include Bar
end

MediaAuthorization.create.errors.messages.inspect

=> "{:credit_card_id=>[\"can't be blank\"], :user_id=>[\"can't be blank\"]}"

MediaAuthorization.new.foo

=> "foo"

MediaAuthorization.new.bar

=> "bar"

MediaAuthorization.foo

=> "self.foo"

MediaAuthorization.bar

=> "self.bar"

## How Does It Work?

Although the library code is written in a very simple and modular fashion, making it easy to read through the algorithm, here is a basic rundown of how the implementation works.

def included(base)
  __invoke_super_module_class_method_calls(base)
  __define_super_module_class_methods(base)
end

##### 1) The first step ensures invoking super module class method calls from the base object that includes it.

For example, suppose we have a super module called Locatable:

module Locatable
  include SuperModule
  
  validates :x_coordinate, numericality: true
  validates :y_coordinate, numericality: true
  
  def move(x, y)
    self.x_coordinate += x
    self.y_coordinate += y
  end
end

class Vehicle < ActiveRecord::Base
  include Locatable
# … more code follows
end

This first step guarantees invocation of the two Locatable <code>validates</code> method calls on the Vehicle object class.

##### 2) The second step redefines super module class methods on the base class to simulate the effect of base.extend(super_module)

For example, suppose we have a super module called Addressable:

module Addressable
  include SuperModule
  
  include Locatable
  validates :city, presence: true, length: { maximum: 255 }
  validates :state, presence: true, length: { is: 2 }

  def self.merge_duplicates
    # 1. Look through all Addressable instances in the database
    # 2. Identify duplicates
    # 3. Merge duplicate addressables
  end
end

class Contact < ActiveRecord::Base
  include Addressable
# … more code follows
end

The second step ensures that <code>merge_duplicates</code> is included in Contact as a class method, allowing the call <code>Contact.merge_duplicates</code>

You are welcome to read through the code for more in-depth details.

## Limitations and Caveats

 * SuperModule has been designed to be used only in the code definition of a module, not to be mixed in at run-time.
 * Initial Ruby runtime load of a class or module mixing in SuperModule will incur a very marginal performance hit (in the order of nano-to-milliseconds). However, class usage (instantiation and method invocation) will not incur any performance hit, running as fast as any other Ruby class.

## Copyright

Copyright (c) 2014 Andy Maleh. See LICENSE.txt for
further details.
