require 'spec_helper'

describe SuperModule do
  module Foo
    include SuperModule
    validates 'foo', presence: true

    def self.foo
      'self.foo'
    end

    def foo
      'foo'
    end
  end
  module Bar
    include SuperModule
    validates 'bar', presence: true

    class << self
      def bar
        'self.bar'
      end
    end

    def bar
      'bar'
    end
  end
  class FakeActiveRecord
    class << self
      def validates(attribute, options)
        validations << [attribute, options]
      end
      def validations
        @validations ||= []
      end
    end
  end

  context "a base class includes a module enhanced as a super module" do
    before do
      FakeActiveRecord.send(:include, Foo)
    end

    it 'allows invoking class methods in the including base class body' do
      FakeActiveRecord.validations.should include(['foo', {presence: true}])
    end
    it 'includes instance methods in the including base class' do
      instance = FakeActiveRecord.new

      instance.foo.should == 'foo'
    end
    it 'includes class methods in the including base class' do
      FakeActiveRecord.foo.should == 'self.foo'
    end
  end

  context "a base class includes a base module enhanced as a super module that includes another module enhanced as a super module" do
    before do
      Bar.send(:include, Foo)
      FakeActiveRecord.send(:include, Bar)
    end

    it 'allows invoking class methods in the including base class body' do
      FakeActiveRecord.validations.should include(['foo', {presence: true}])
      FakeActiveRecord.validations.should include(['bar', {presence: true}])
    end
    it 'includes instance methods in the including base class' do
      instance = FakeActiveRecord.new

      instance.foo.should == 'foo'
      instance.bar.should == 'bar'
    end
    it 'includes class methods in the including base class' do
      FakeActiveRecord.foo.should == 'self.foo'
      FakeActiveRecord.bar.should == 'self.bar'
    end
  end

end
