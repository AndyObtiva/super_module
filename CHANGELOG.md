### v1.2.1 (v2 beta)

* Standalone super module usage (e.g. direct class method invocation)

### v1.2.0 (v2 beta)

* New `super_module(name)` syntax
* Much simpler implementation with guaranteed correctness and no performance hit
* Less memory footprint by not requiring method_source Ruby gem for v2 syntax
* Backwards compatibility with v1 syntax

### v1.1.1

* Added support for private and protected methods
* Added many more RSpec test cases, including testing of empty and comment containing singleton methods

### v1.1.0

 * Brand new `self`-friendly algorithm that ensures true mixing of super module singleton methods into the including base class or module, thus always returning the actual base class or module `self` when invoking a super module inherited singleton method (thanks to [Banister](https://github.com/banister) for [reporting previous limitation on Reddit and providing suggestions](http://www.reddit.com/r/ruby/comments/30j66y/step_aside_activesupportconcern_supermodule_is/))
 * New `included_super_modules` inherited singleton method that provides developer with a list of all included super modules similar to the Ruby `included_modules` method.
 * No more use for method_missing (Thanks to Marc-André Lafortune for bringing up as a previous limitation in [AirPair article reviews](https://www.airpair.com/ruby/posts/step-aside-activesupportconcern-supermodule-is-the-new-sheriff-in-town))
 * New dependency on [Banister](https://github.com/banister)'s [method_source](https://github.com/banister/method_source) library to have the self-friendly algorithm eval inherited class method sources into the including base class or module.
 * Refactorings, including break-up of the original SuperModule into 3 modules in separate files
 * More RSpec test coverage, including additional method definition scenarios, such as when adding dynamically via `class_eval` and `define_method`
