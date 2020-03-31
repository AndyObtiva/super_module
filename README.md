# <img src="https://raw.githubusercontent.com/AndyObtiva/super_module/master/SuperModule.jpg" alt="SuperModule" align="left" height="50" /> &nbsp; SuperModule 1.3
[![Gem Version](https://badge.fury.io/rb/super_module.svg)](http://badge.fury.io/rb/super_module)
[![Build Status](https://api.travis-ci.org/AndyObtiva/super_module.svg?branch=master)](https://travis-ci.org/AndyObtiva/super_module)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/super_module/badge.svg?branch=master)](https://coveralls.io/r/AndyObtiva/super_module?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/super_module.svg)](https://codeclimate.com/github/AndyObtiva/super_module)

Calling [Ruby](https://www.ruby-lang.org/en/)'s [`Module#include`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-include) to mix in a module does not bring in class methods by default. This can come as quite the surprise when attempting to include class methods via a module.

Ruby offers one workaround in the form of implementing the hook method [`Module.included(base)`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included) [following a certain boilerplate code idiom](http://www.railstips.org/blog/archives/2009/05/15/include-vs-extend-in-ruby/). Unfortunately, it hinders code maintainability and productivity with extra unnecessary complexity, especially in production-environment projects employing many [mixins](http://en.wikipedia.org/wiki/Mixin) (e.g. modeling business domain models with composable object [traits](http://en.wikipedia.org/wiki/Trait_(computer_programming))).

Another workaround is [`ActiveSupport::Concern`](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html), a Rails library that attempts to ease some of the boilerplate pain by offering a [DSL](http://www.infoq.com/news/2007/06/dsl-or-not) layer on top of [`Module.included(base)`](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included). Unfortunately, while it helps improve readability a bit, it adds even more boilerplate idiom cruft, thus feeling no more than putting a band-aid on the problem.

But do not fear, [SuperModule](https://rubygems.org/gems/super_module) comes to the rescue! By declaring your module as a SuperModule, it will simply behave as one would expect and automatically include class methods along with instance methods, without any further work needed.

Used in my other project: [Glimmer](https://github.com/AndyObtiva/Glimmer) (Ruby Desktop GUI Library)

## Introductory Comparison

To introduce [SuperModule](https://rubygems.org/gems/super_module), here is a comparison of three different approaches for writing a
<code>UserIdentifiable</code> module, which includes ActiveModel::Model module as an in-memory alternative to ActiveRecord::Base superclass (Side-note: ActiveModel::Model is not needed when extending ActiveRecord::Base to connect to database.)

#### 1) [self.included(base)](http://ruby-doc.org/core-2.2.1/Module.html#method-i-included)

```ruby
module UserIdentifiable
  include ActiveModel::Model

  def self.included(base)
    base.extend(ClassMethods)
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
By including `SuperModule` (following Ruby's basic convention of relying on a module), developers can directly add class method invocations and definitions inside the module's body, and [`SuperModule`](https://github.com/AndyObtiva/super_module) takes care of automatically mixing them into classes that include the module.

As a result, [SuperModule](https://rubygems.org/gems/super_module) collapses the difference between extending a super class and including a super module, thus encouraging developers to write simpler code while making better Object-Oriented Design decisions.

In other words, [SuperModule](https://rubygems.org/gems/super_module) furthers Ruby's goal of making programmers happy.

## Instructions

#### 1) Install and require gem

<b>Using [Bundler](http://bundler.io/)</b>

Add the following to Gemfile: <pre>gem 'super_module', '1.3.1'</pre>

And run the following command: <pre>bundle</pre>

Afterwards, [SuperModule](https://rubygems.org/gems/super_module) will automatically get required in the application (e.g. a Rails application) and be ready for use.

<b>Using [RubyGem](https://rubygems.org/gems/super_module) Directly</b>

Run the following command: <pre>gem install super_module</pre>

(add <code>--no-ri --no-rdoc</code> if you wish to skip downloading documentation for a faster install)

Add the following at the top of your [Ruby](https://www.ruby-lang.org/en/) file: <pre>require 'super_module'</pre>

#### 2) Simply include SuperModule in your module (just like you would do any other Ruby module)

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

V2 has a much simpler algorithm than V1 that goes as follows:

1. Handle invocation of `super_module(name, &super_module_body)` method anywhere in the Ruby code where the block it receives represents the super module body, including instance methods, and class methods, and class body invocations.
2. Clone `SuperModule` and store in it the passed in `super_module_body` block
3. Assign the cloned `SuperModule` to a new constant as defined by name (e.g. 'Utilities::Printer') under a class, module, or the top-level Ruby scope
4. When calling `include` on the module later on, its stored super_module_body attribute is retrieved and run in the including class or module body via `class_eval`

## Warnings

1) [SuperModule](https://rubygems.org/gems/super_module) by definition has been designed to be used only in the initial code declaration of a module, not later mixing or re-opening of a module.

2) Given [SuperModule](https://rubygems.org/gems/super_module)'s implementation relies on `self.included(base)`, sub-modules must not hook into it.

In very rare occasions when an including module needs to redefine <code>self.included(base)</code> for meta-programming purposes, you may do so at your own peril by first invoking <code>self.included_super_module(base)</code> like in this example:
```ruby
module AdminIdentifiable
    include SuperModule
    include UserIdentifiable

    class << self
        def included(base)
            included_super_module(base)
            # do some extra rare meta-programming work
            # like conditional inclusion of other modules
            # or conditional definition of methods
        end
    end
end
```
This does not work for all cases (like multiple levels of super module nesting), and is not recommended, likely causing problems.

Avoid hooking into `self.included(base)` at all costs.

## Change Log

[CHANGELOG.md](https://github.com/AndyObtiva/super_module/blob/master/CHANGELOG.md)

## Feedback and Contribution

[SuperModule](https://rubygems.org/gems/super_module) is written in a very clean and maintainable test-first approach, so you are welcome to read through the code on GitHub for more in-depth details:
https://github.com/AndyObtiva/super_module

The library is quite new and can use all the feedback and help it can get. So, please do not hesitate to add comments if you have any, and please fork [the project on GitHub](https://github.com/AndyObtiva/super_module#fork-destination-box) in order to [make contributions via Pull Requests](https://github.com/AndyObtiva/super_module/pulls).

## Articles, Publications, and Blog Posts
 * 2015-04-05 - [Ruby Weekly](http://rubyweekly.com): [Issue 240](http://rubyweekly.com/issues/240)
 * 2015-03-27 - [AirPair](http://www.airpair.com) Article: [Step aside ActiveSupport::Concern. SuperModule is the new sheriff in town!](https://www.airpair.com/ruby/posts/step-aside-activesupportconcern-supermodule-is-the-new-sheriff-in-town)
 * 2014-03-27 - [Code Painter](http://andymaleh.blogspot.com) Blog Post: [Ruby SuperModule Comes To The Rescue!!](http://andymaleh.blogspot.ca/2014/03/ruby-supermodule-comes-to-rescue.html)

## TODO

- Fix issue where class methods cannot get called from super_module directly (when used with "CONSTANT = super_module do" approach)
- Fix issue where a super module (declared with super_module) can get included in one class only where class methods work, but the next class that includes the super module does not have class methods work

## Copyright

Copyright (c) 2014-2020 Andy Maleh. See LICENSE.txt for
further details.
