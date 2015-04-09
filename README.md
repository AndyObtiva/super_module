# <img src="https://raw.githubusercontent.com/AndyObtiva/super_module/master/SuperModule.jpg" alt="SuperModule" align="left" height="50" /> &nbsp; SuperModule v1.1.0 [2015-04-06]
[![Gem Version](https://badge.fury.io/rb/super_module.svg)](http://badge.fury.io/rb/super_module)
[![Build Status](https://api.travis-ci.org/AndyObtiva/super_module.svg?branch=master)](https://travis-ci.org/AndyObtiva/super_module)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/super_module/badge.svg?branch=master)](https://coveralls.io/r/AndyObtiva/super_module?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/super_module.svg)](https://codeclimate.com/github/AndyObtiva/super_module)

Calling [Ruby](https://www.ruby-lang.org/en/)'s [`Module#include`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-include) to mix in a module does not bring in class methods by default. This can come as quite a surprise whenever a developer attempts to include class methods via a module. Fortunately, Ruby does offer a solution in the form of implementing the hook method [`Module.included(base)`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included) [following a certain boilerplate code idiom](http://www.railstips.org/blog/archives/2009/05/15/include-vs-extend-in-ruby/). However, this solution can hinder code maintainability and productivity flow in a big production-environment project that takes advantage of many [mixins](http://en.wikipedia.org/wiki/Mixin) to model the business domain via composable object [traits](http://en.wikipedia.org/wiki/Trait_(computer_programming)). 

[`ActiveSupport::Concern`](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html) is a popular Rails library that attempts to ease some of the boilerplate pain by offering a [DSL](http://www.infoq.com/news/2007/06/dsl-or-not) layer on top of [`Module.included(base)`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included). Unfortunately, while it improves the readability of the code needed to include class methods, it supports the same boilerplate idiom, thus feeling no more than putting a band-aid on the problem.

Fortunately, [SuperModule](https://rubygems.org/gems/super_module) comes to the rescue. Including `SuperModule` at the top of a Ruby module's body automatically ensures inclusion of class methods whenever a developer mixes it in via [`Module#include`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-include).

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
 * Singleton class: also known as the [metaclass](https://rubymonk.com/learning/books/4-ruby-primer-ascent/chapters/39-ruby-s-object-model/lessons/131-singleton-methods-and-metaclasses) or [eigenclass](http://eigenjoy.com/2008/05/29/railsconf08-meta-programming-ruby-for-fun-and-profit/), it is the object-instance-associated class copy available to every object in Ruby (e.g. every `Object.new` instance has a singleton class that is a copy of the `Object` class, which can house instance-specific behavior if needed)
 * Singleton method: an instance method defined on an object's singleton class. Often used to refer to a class or module method defined on the [Ruby class object or module object singleton class](http://ruby-doc.com/docs/ProgrammingRuby/html/classes.html) via `def self.method_name(...)` or `class << self` enclosing `def method_name(...)`
 * Class method invocation: Inherited Ruby class or module method invoked in the body of a class or module (e.g. <code>validates :username, presence: true</code>)
 * Code-time: Time of writing code in a Ruby file as opposed to Run-time
 * Run-time: Time of executing Ruby code

## Usage Details

 * SuperModule must always be included at the top of a module's body at code-time
 * SuperModule inclusion can be optionally followed by other basic or super module inclusions
 * A super module can only be included in a class or another super module
 * SuperModule adds <b>zero cost</b> to instantiation of including classes and invocation of included methods (both class and instance)

## IRB Example

Create a ruby file called super_module_irb_example.rb with the following content:

```ruby
require 'rubygems' # to be backwards compatible with Ruby 1.8.7
require 'super_module'

module RequiresAttributes
  include SuperModule

  def self.requires(*attributes)
    attributes.each {|attribute| required_attributes << attribute}
  end

  def self.required_attributes
    @required_attributes ||= []
  end
  
  def requirements_satisfied?
    !!self.class.required_attributes.reduce(true) { |result, required_attribute| result && send(required_attribute) }
  end
end

class MediaAuthorization
  include RequiresAttributes
  attr_accessor :user_id, :credit_card_id
  requires :user_id, :credit_card_id
end
```

Open `irb` ([Interactive Ruby](https://www.ruby-lang.org/en/documentation/quickstart/)) and paste the following code snippets in. You should get the output denoted by the rockets (`=>`).

```ruby
require './super_module_irb_example.rb'
```
=> true

```ruby
MediaAuthorization.required_attributes
```
=> [:user_id, :credit_card_id]

```ruby
media_authorization = MediaAuthorization.new # resulting object print-out varies
```
=> #<MediaAuthorization:0x832b36be1>

```ruby
media_authorization.requirements_satisfied?
```
=> false

```ruby
media_authorization.user_id = 387
```
=> 387

```ruby
media_authorization.requirements_satisfied?
```
=> false

```ruby
media_authorization.credit_card_id = 37
```
=> 37

```ruby
media_authorization.requirements_satisfied?
```
=> true

## How Does It Work?

Here is the general algorithm from the implementation:

```ruby
def included(base)
  __define_super_module_class_methods(base)
  __invoke_super_module_class_method_calls(base)
end
```

#### 1) Defines super module class methods on the including base class

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

This step ensures that <code>merge_duplicates</code> is included in Contact as a class method, allowing the call <code>Contact.merge_duplicates</code>

It does so by recording every class method defined using the Ruby [`self.singleton_method_added(method_name)`](http://ruby-doc.org/core-2.2.1/BasicObject.html#method-i-singleton_method_added) hook, reading class method sources using the [method_source](https://rubygems.org/gems/method_source/) gem, and finally upon invocation of `self.included(base)`, `class_eval`ing the recorded class methods on the including base class (or module).

In order to avoid interference with existing class method definitions, there is an exception list for what not to record, such as <code>:included_super_modules, :class_eval, :singleton_method_added</code> and any other "__" prefixed class methods defined in [SuperModule](https://rubygems.org/gems/super_module), such as <code>__super_module_class_method_calls</code>.

Also, the recorded class method sources are altered to handle recording of method calls as well, which is used in the second step explained next.

#### 2) Invoke super module class method calls on the including base class (or module).

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

This step guarantees invocation of the two `Locatable` <code>validates</code> method calls on the `Vehicle` object class.

It does so by relying on an interally defined method `__record_method_call(method_name, *args, &block)` to record every class method call that happens in the super module class body, and later replaying those calls on the including base class during `self.included(base)` by using Ruby's `send(method_name, *args, &block)` method introspection.

## Limitations and Caveats

 * [SuperModule](https://rubygems.org/gems/super_module) has been designed to be used only in the code definition of a module, not to be mixed in at run-time.

 * Initial Ruby runtime load of a class or module mixing in [SuperModule](https://rubygems.org/gems/super_module) will incur a very marginal performance hit (in the order of nano-to-milliseconds). However, class usage (instantiation and method invocation) will not incur any performance hit, running as fast as any other Ruby class.

 * Given [SuperModule](https://rubygems.org/gems/super_module)'s implementation relies on `self.included(base)`, if an including super module (or a super module including another super module) must hook into <code>self.included(base)</code> for meta-programming cases that require it, such as conditional `include` statements or method definitions, it would have to alias <code>self.included(base)</code> and then invoke the aliased version in every super module that needs it like in this example: 
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

## What's New?

### v1.1.0

 * Brand new `self`-friendly algorithm that ensures true mixing of super module singleton methods into the including base class or module, thus always returning the actual base class or module `self` when invoking a super module inherited singleton method (thanks to [Banister](https://github.com/banister) for [reporting previous limitation on Reddit and providing suggestions](http://www.reddit.com/r/ruby/comments/30j66y/step_aside_activesupportconcern_supermodule_is/))
 * New `included_super_modules` inherited singleton method that provides developer with a list of all included super modules similar to the Ruby `included_modules` method.
 * No more use for method_missing (Thanks to Marc-André Lafortune for bringing up as a previous limitation in [AirPair article reviews](https://www.airpair.com/ruby/posts/step-aside-activesupportconcern-supermodule-is-the-new-sheriff-in-town))
 * New dependency on [Banister](https://github.com/banister)'s [method_source](https://github.com/banister/method_source) library to have the self-friendly algorithm eval inherited class method sources into the including base class or module.
 * Refactorings, including break-up of the original SuperModule into 3 modules in separate files
 * More RSpec test coverage, including additional method definition scenarios, such as when adding dynamically via `class_eval` and `define_method`
 
## Feedback and Contribution

[SuperModule](https://rubygems.org/gems/super_module) is written in a very clean and maintainable test-first approach, so you are welcome to read through the code on GitHub for more in-depth details:
https://github.com/AndyObtiva/super_module 

The library is quite new and can use all the feedback and help it can get. So, please do not hesitate to add comments if you have any, and please fork [the project on GitHub](https://github.com/AndyObtiva/super_module#fork-destination-box) in order to [make contributions via Pull Requests](https://github.com/AndyObtiva/super_module/pulls).

## Articles, Publications, and Blog Posts
 * 2015-04-05 - [Ruby Weekly](http://rubyweekly.com): [Issue 240](http://rubyweekly.com/issues/240)
 * 2015-03-27 - [AirPair](http://www.airpair.com) Article: [Step aside ActiveSupport::Concern. SuperModule is the new sheriff in town!](https://www.airpair.com/ruby/posts/step-aside-activesupportconcern-supermodule-is-the-new-sheriff-in-town)
 * 2014-03-27 - [Code Painter](http://andymaleh.blogspot.com) Blog Post: [Ruby SuperModule Comes To The Rescue!!](http://andymaleh.blogspot.ca/2014/03/ruby-supermodule-comes-to-rescue.html)

## Copyright

Copyright (c) 2014-2015 Andy Maleh. See LICENSE.txt for
further details.
