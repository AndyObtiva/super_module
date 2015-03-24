require 'spec_helper'

describe SuperModule do

  module FakeActiveModel

    include SuperModule

    def self.validates(attribute, options)
      validations << [attribute, options]
    end

    def self.validations
      @validations ||= []
    end

  end

  module Foo

    include SuperModule
    include FakeActiveModel
    validates 'foo', {:presence => true}

    def self.foo
      'self.foo'
    end

    def foo
      'foo'
    end

  end

  module Bar

    include SuperModule
    include Foo
    validates 'bar', {:presence => true}

    class << self
      include Comparable

      def bar
        'self.bar'
      end

      def barrable
        @barrable
      end

      def barrable=(value)
        @barrable = value
      end

      def make_barrable
        self.barrable = true
      end

      def <=>(other_bar_class)
        self.name <=> other_bar_class.name
      end

    end

    def bar
      'bar'
    end

  end

  module Baz

    include SuperModule
    include Comparable
    include Bar
    make_barrable
    validates 'baz', {:presence => true}
    attr_reader :created_at
    
    def initialize
      @created_at = Time.now.to_f
    end
    
    class << self
      def baz
        'self.baz'
      end
    end
    
    def baz
      'baz'
    end
    
    def <=>(other_baz)
      created_at <=> other_baz.created_at
    end

  end

  class FakeActiveRecord
    include FakeActiveModel
  end

  class FooActiveRecord < FakeActiveRecord
    include Foo
  end

  class BarActiveRecord < FakeActiveRecord
    include Bar
  end

  class BazActiveRecord < FakeActiveRecord
    include Baz
  end

  context "included by a module (Foo) that is included by a class (FooActiveRecord)" do

    subject { FooActiveRecord }

    it 'allows invoking class methods' do
      expect(subject.validations).to include(['foo', {:presence => true}])
    end

    it 'includes class methods declared via "self.method_name"' do
      expect(subject.foo).to eq('self.foo')
    end

    it 'includes instance methods' do
      instance = subject.new

      expect(instance.foo).to eq('foo')
    end

  end

  context "included by a module (Foo) that is included by a second module (Bar) that is included by a class (BarActiveRecord)" do

    subject { BarActiveRecord }

    it 'allows invoking class methods' do
      expect(subject.validations).to include(['foo', {:presence => true}])
      expect(subject.validations).to include(['bar', {:presence => true}])
    end

    it 'includes class methods declared via "class << self"' do
      expect(subject.foo).to eq('self.foo')
      expect(subject.bar).to eq('self.bar')
    end

    it 'includes instance methods' do
      instance = subject.new

      expect(instance.foo).to eq('foo')
      expect(instance.bar).to eq('bar')
    end

  end

  context "included by a module (Foo), included by another module (Bar), included by a third module (Baz) that is included by a class (BazActiveRecord)" do

    subject { BazActiveRecord }

    it 'allows invoking class methods' do
      expect(subject.validations).to include(['foo', {:presence => true}])
      expect(subject.validations).to include(['bar', {:presence => true}])
      expect(subject.validations).to include(['baz', {:presence => true}])
    end

    it 'includes class methods declared via "class << self"' do
      expect(subject.foo).to eq('self.foo')
      expect(subject.bar).to eq('self.bar')
      expect(subject.baz).to eq('self.baz')
    end

    it 'includes instance methods' do
      instance = subject.new

      expect(instance.foo).to eq('foo')
      expect(instance.bar).to eq('bar')
      expect(instance.baz).to eq('baz')
    end

    it 'can include a basic module (Comprable)' do 
      instance = subject.new
      instance2 = subject.new

      expect(instance < instance2).to eq(true)
    end

    it 'can include a basic module (Comprable) into singleton class via "class << self"' do 
      expect(Bar < BarActiveRecord).to eq(true)
    end


  end

end
