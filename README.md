# SuperModule
[![Gem Version](https://badge.fury.io/rb/super_module.png)](http://badge.fury.io/rb/super_module)
[![Build Status](https://api.travis-ci.org/AndyObtiva/super_module.png?branch=master)](https://travis-ci.org/AndyObtiva/super_module)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/super_module/badge.png?branch=master)](https://coveralls.io/r/AndyObtiva/super_module?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/super_module.png)](https://codeclimate.com/github/AndyObtiva/super_module)

Tired of [Ruby](https://www.ruby-lang.org/en/)'s modules not allowing you to mix in class methods easily?
Tired of writing complex `self.included(base)` code or using over-engineered solutions like [`ActiveSupport::Concern`](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html) to accomplish that goal?

Well, worry no more! [SuperModule](https://rubygems.org/gems/super_module) comes to the rescue!

[SuperModule](https://rubygems.org/gems/super_module) allows defining class methods and method invocations the same way a super class does without using [`self.included(base)`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included).

This succeeds [`ActiveSupport::Concern`](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html) by offering lighter syntax and simpler module dependency support.

## Introductory Comparison

To introduce [SuperModule](https://rubygems.org/gems/super_module), here is a comparison of three different approaches for writing a
<code>UserIdentifiable</code> module. 

#### 1) [self.included(base)](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included)

```ruby
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
```

This is a lot to think about and process for simply wanting inclusion of class method definitions (like <code>most_active_user</code>) and class method invocations (like <code>belongs_to</code> and <code>validates</code>). The unnecessary complexity gets in the way of problem-solving; slows down productivity with repetitive boiler-plate code; and breaks expectations set in other similar object-oriented languages, discouraging companies from including [Ruby](https://www.ruby-lang.org/en/) in a polyglot stack, such as [Groupon](http://www.groupon.com)'s [Rails/JVM/Node.js](https://engineering.groupon.com/2013/misc/i-tier-dismantling-the-monoliths/) stack and [SoundCloud](http://www.soundcloud.com)'s [JRuby/Scala/Clojure stack](https://developers.soundcloud.com/blog/building-products-at-soundcloud-part-3-microservices-in-scala-and-finagle).

#### 2) [ActiveSupport::Concern](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html)

```ruby
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
```

A step forward that addresses the boiler-plate repetitive code concern, but is otherwise really just lipstick on a pig. To explain more, developer problem solving and creativity flow is still disrupted by having to think about the lower-level mechanism of running code on inclusion (using `included`) and structuring class methods in an extra sub-module (`ClassMethods`) instead of simply declaring class methods like they normally would in Ruby and staying focused on the task at hand.

#### 3) [SuperModule](https://github.com/AndyObtiva/super_module)

```ruby
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
```

With `include SuperModule` declared on top, developers can directly add class method invocations and definitions inside the module's body, and [`SuperModule`](https://github.com/AndyObtiva/super_module) takes care of automatically mixing them into classes that include the module.

As a result, [SuperModule](https://rubygems.org/gems/super_module) collapses the difference between extending a super class and including a super module, thus encouraging developers to write simpler code while making better Object-Oriented Design decisions. 

In other words, [SuperModule](https://rubygems.org/gems/super_module) furthers Ruby's goal of making programmers happy.

## Instructions

#### 1) Install and require gem

<b>Using [Bundler](http://bundler.io/)</b>

Add the following to Gemfile: <pre>gem 'super_module', '1.0.0'</pre>

And run the following command: <pre>bundle</pre>

Afterwards, [SuperModule](https://rubygems.org/gems/super_module) will automatically get required in the application (e.g. a Rails application) and be ready for use.

<b>Using [RubyGem](https://rubygems.org/gems/super_module) Directly</b>

Run the following command: <pre>gem install super_module</pre>

(add <code>--no-ri --no-rdoc</code> if you wish to skip downloading documentation for a faster install)

Add the following at the top of your [Ruby](https://www.ruby-lang.org/en/) file: <pre>require 'super_module'</pre>

#### 2) Include [`SuperModule`](https://rubygems.org/gems/super_module) at the top of the module

```ruby
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
```

#### 3) Mix newly defined module into a class or another super module

```ruby
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
```

#### 4) Start using by invoking class methods or instance methods

```ruby
CourseEnrollment.most_active_user
ClubParticipation.most_active_user
Activity.last.slug
ClubParticipation.create(club_id: club.id, user_id: user.id).slug
CourseEnrollment.new(course_id: course.id).valid?
```

## Glossary and Definitions

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

Copy and paste the following code snippets in <code>irb</code> and you should get the output denoted by double arrows (<code>=></code>).

```ruby
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
```

=> "{:credit_card_id=>[\"can't be blank\"], :user_id=>[\"can't be blank\"]}"

```ruby
MediaAuthorization.new.foo
```

=> "foo"

```ruby
MediaAuthorization.new.bar
```

=> "bar"

```ruby
MediaAuthorization.foo
```

=> "self.foo"

```ruby
MediaAuthorization.bar
```

=> "self.bar"

## How Does It Work?

Here is the general algorithm from the implementation:

```ruby
def included(base)
  __invoke_super_module_class_method_calls(base)
  __define_super_module_class_methods(base)
end
```

#### 1) Invoke super module class method calls on the including base class.

For example, suppose we have a super module called `Locatable`:

```ruby
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
```

This first step guarantees invocation of the two `Locatable` <code>validates</code> method calls on the `Vehicle` object class.

It does so by relying on `method_missing(method_name, *args, &block)` to record every class method call that happens in the super module class body, and later replaying those calls on the including base class during `self.included(base)` by using Ruby's `send(method_name, *args, &block)` method introspection.

#### 2) Defines super module class methods on the including base class

For example, suppose we have a super module called Addressable:

```ruby
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
```

The second step ensures that <code>merge_duplicates</code> is included in Contact as a class method, allowing the call <code>Contact.merge_duplicates</code>

It does so by recording every class method defined using the <code>self.singleton_method_added(method_name)</code> added hook, and then later replaying these class definitions on the including base class during invocation of <code>self.included(base)</code>.

In order to avoid interference with existing class method definitions, there is an exception list for what not to record, such as <code>:included, :method_missing, :singleton_method_added</code> and any other "__" prefixed class methods defined in [SuperModule](https://rubygems.org/gems/super_module), such as <code>__super_module_class_method_calls</code>.

## Limitations and Caveats

 * [SuperModule](https://rubygems.org/gems/super_module) has been designed to be used only in the code definition of a module, not to be mixed in at run-time.

 * Initial Ruby runtime load of a class or module mixing in [SuperModule](https://rubygems.org/gems/super_module) will incur a very marginal performance hit (in the order of nano-to-milliseconds). However, class usage (instantiation and method invocation) will not incur any performance hit, running as fast as any other Ruby class.

 * Given [SuperModule](https://rubygems.org/gems/super_module) relies on <code>self.included(base)</code> in its implementation, if an including super module (or a super module including another super module) must hook into <code>self.included(base)</code> for meta-programming cases that require it, such as conditional `include` statements or method definitions, it would have to alias <code>self.included(base)</code> and then invoke the aliased version in every super module that needs it like in this example: 
```ruby 
module AdminIdentifiable
    include SuperModule
    include UserIdentifiable
    
    class << self
        alias included_super_module included
        def included(base)
            included_super_module(base)
            # do some extra work 
            # like conditional inclusion of other modules
            # or conditional definition of methods
        end
    end
```
In the future, [SuperModule](https://rubygems.org/gems/super_module) could perhaps provide robust built-in facilities for allowing super modules to easily hook into <code>self.included(base)</code> without interfering with [SuperModule](https://rubygems.org/gems/super_module) behavior.

 * Given [SuperModule](https://rubygems.org/gems/super_module) relies on <code>method_missing(method_name, *args, &block)</code> inside <code>class << self</code>, a super module including it that needs to do some additional <code>method_missing(method_name, *args, &block)</code> meta-programming must not only alias it, but also be mindful of implications on [SuperModule](https://rubygems.org/gems/super_module) behavior.

## Feedback and Contribution

[SuperModule](https://rubygems.org/gems/super_module) is written in a very clean and maintainable test-first approach, so you are welcome to read through the code on GitHub for more in-depth details:
https://github.com/AndyObtiva/super_module 

The library is quite new and can use all the feedback and help it can get. So, please do not hesitate to add comments if you have any, and please fork [the project on GitHub](https://github.com/AndyObtiva/super_module#fork-destination-box) in order to [make contributions via Pull Requests](https://github.com/AndyObtiva/super_module/pulls).

## Articles and Blog Posts

 * 2015-03-27 - [AirPair](http://www.airpair.com) Article: [Step aside ActiveSupport::Concern. SuperModule is the new sheriff in town!](https://www.airpair.com/ruby/posts/step-aside-activesupportconcern-supermodule-is-the-new-sheriff-in-town)
 * 2014-03-27 - [Code Painter](http://andymaleh.blogspot.com) Blog Post: [Ruby SuperModule Comes To The Rescue!!](http://andymaleh.blogspot.ca/2014/03/ruby-supermodule-comes-to-rescue.html)

## Copyright

Copyright (c) 2014-2015 Andy Maleh. See LICENSE.txt for
further details.
