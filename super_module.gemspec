# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: super_module 1.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "super_module".freeze
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andy Maleh".freeze]
  s.date = "2019-08-06"
  s.description = "SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base). This also succeeds ActiveSupport::Concern by offering lighter syntax".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "LICENSE.txt",
    "README.md",
    "SuperModule.jpg",
    "VERSION",
    "examples/reddit-readers/banister/foo.rb",
    "examples/reddit-readers/banister/world.rb",
    "lib/super_module.rb",
    "lib/super_module/v1.rb",
    "lib/super_module/v1/module_body_method_call_recorder.rb",
    "lib/super_module/v1/singleton_method_definition_store.rb",
    "ruby187.Gemfile",
    "spec/lib/super_module_spec.rb",
    "spec/support/bar.rb",
    "spec/support/baz.rb",
    "spec/support/fake_active_model.rb",
    "spec/support/foo.rb",
    "spec/support/v1.rb",
    "spec/support/v1/bar.rb",
    "spec/support/v1/baz.rb",
    "spec/support/v1/fake_active_model.rb",
    "spec/support/v1/foo.rb",
    "spec/support/v2.rb",
    "spec/support/v2/bar.rb",
    "spec/support/v2/baz.rb",
    "spec/support/v2/fake_active_model.rb",
    "spec/support/v2/foo.rb",
    "spec/support/v2_alt.rb",
    "spec/support/v2_alt/bar.rb",
    "spec/support/v2_alt/baz.rb",
    "spec/support/v2_alt/fake_active_model.rb",
    "spec/support/v2_alt/foo.rb",
    "super_module.gemspec"
  ]
  s.homepage = "http://github.com/AndyObtiva/super_module".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.10".freeze
  s.summary = "SuperModule allows defining class methods and method invocations the same way a super class does without using def included(base). This also succeeds ActiveSupport::Concern by offering lighter syntax".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<method_source>.freeze, [">= 0.8.2"])
      s.add_development_dependency(%q<jeweler>.freeze, ["~> 2.3.0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.2.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.4.2"])
      s.add_development_dependency(%q<rack>.freeze, ["~> 1.6.5"])
      s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.6.8.1"])
      s.add_development_dependency(%q<tins>.freeze, ["~> 1.6.0"])
      s.add_development_dependency(%q<term-ansicolor>.freeze, ["~> 1.3.2"])
    else
      s.add_dependency(%q<method_source>.freeze, [">= 0.8.2"])
      s.add_dependency(%q<jeweler>.freeze, ["~> 2.3.0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.2.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.4.2"])
      s.add_dependency(%q<rack>.freeze, ["~> 1.6.5"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6.8.1"])
      s.add_dependency(%q<tins>.freeze, ["~> 1.6.0"])
      s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3.2"])
    end
  else
    s.add_dependency(%q<method_source>.freeze, [">= 0.8.2"])
    s.add_dependency(%q<jeweler>.freeze, ["~> 2.3.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.2.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.4.2"])
    s.add_dependency(%q<rack>.freeze, ["~> 1.6.5"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6.8.1"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.6.0"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3.2"])
  end
end

