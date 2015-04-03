require 'spec_helper'

puts " >>>>>>>PRETESTS<<<<<<< "
puts Foo.include?(SuperModule)
puts FakeActiveModel.include?(SuperModule)
puts Foo.foo
puts Foo.meh.inspect
puts Foo.validations.inspect
puts " ****** TESTS BEGIN ****** "

describe SuperModule do

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

    it 'provides class method self as the including base class as in the class method (meh)' do
      expect(subject.meh).to eq(subject)
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

    it 'can include a basic module (Forwardable) into singleton class by placing in class << self' do 
      instance = subject.new
      expect(instance.length).to eq(3)
    end

    it 'can include a basic module (Comparable)' do 
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      instance = subject.new
      allow(Time).to receive(:now).and_return(now + 100)
      instance2 = subject.new

      expect(instance2 > instance).to eq(true)
    end

    it 'provides class method self as the including base class as in the class method (meh)' do
      expect(subject.meh).to eq(subject)
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
      instance = BazActiveRecord.new(100)

      expect(instance.foo).to eq('foo')
      expect(instance.bar).to eq('bar')
      expect(instance.baz).to eq('baz')
    end

    it 'can override super module behavior (<=>)' do 
      instance = subject.new(50)
      instance2 = subject.new(7)

      expect(instance2 > instance).to eq(false)
    end

    it 'provides class method self as the including base class as in the class method (meh)' do
      expect(subject.meh).to eq(subject)
    end
  end

# TODO test different cases for copying method from a file
# like \r\n vs \n
# and one line definition vs 2 lines vs multi line
# also test special cases using eval, def_method, and self. vs wrapped with class << self
end
