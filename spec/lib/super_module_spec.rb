require 'spec_helper'

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

    it 'includes class method declared via "self.method_name"' do
      expect(subject.foo).to eq('self.foo')
    end

    it 'includes class method declared via "self.method_name" taking a single parameter' do
      expect(subject.foo_single_param('param1_value')).to eq('self.foo(param1_value)')
    end

    it 'includes class method declared via "self.method_name" taking multiple parameters' do
      expect(subject.foo_multi_params('param1_value', 'param2_value', 'param3_value')).to eq('self.foo(param1_value,param2_value,param3_value)')
    end

    it 'includes class method declared via "self.method_name" taking a block' do
      formatter = Proc.new {|value| "Block formatted #{value}"}
      expect(subject.foo_block(&formatter)).to eq('Block formatted self.foo')
    end

    it 'includes class method declared via "self.method_name" taking a single paramter and a block' do
      formatter = Proc.new {|value, param1| "Block formatted #{value} with #{param1}"}
      expect(subject.foo_single_param_block('param1_value', &formatter)).to eq('Block formatted self.foo with param1_value')
    end

    it 'includes class method declared via "self.method_name" taking multiple paramters and a block' do
      formatter = Proc.new {|value, param1, param2, param3| "Block formatted #{value} with #{param1},#{param2},#{param3}"}
      expect(subject.foo_multi_params_block('param1_value', 'param2_value', 'param3_value', &formatter)).to eq('Block formatted self.foo with param1_value,param2_value,param3_value')
    end

    it 'includes class method declared via "self.method_name" on one line' do
      expect(subject.foo_one_line).to eq('self.foo_one_line')
    end

    it 'includes class method declared via "class < self"' do
      expect(subject.foo_class_self).to eq('self.foo_class_self')
    end

    it 'includes class method declared via "class < self" using define_method' do
      expect(subject.foo_class_self_define_method).to eq('self.foo_class_self_define_method')
    end

    it 'includes private class method' do
      expect{subject.foo_private}.to raise_error
      expect(subject.private_methods.map(&:to_s)).to include('foo_private')
      expect(subject.send(:foo_private)).to eq('self.foo_private')
    end

    it 'includes protected class method (declared using protected :method_name)' do
      expect{subject.foo_protected}.to raise_error
      expect(subject.protected_methods.map(&:to_s)).to include('foo_protected')
      expect(subject.send(:foo_protected)).to eq('self.foo_protected')
    end

    it 'includes empty class method' do
      expect(subject.empty).to eq(nil)
    end

    it 'includes empty class method with one empty line' do
      expect(subject.empty_one_empty_line).to eq(nil)
    end

    it 'includes empty class method with comment' do
      expect(subject.empty_with_comment).to eq(nil)
    end

    it 'includes empty class method one line definition' do
      expect(subject.empty_one_line_definition).to eq(nil)
    end

    it 'includes empty class method one line definition with spaces' do
      expect(subject.empty_one_line_definition_with_spaces).to eq(nil)
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

    it 'applies super module (Bar) class method invocation (make_barrable) on including class (BarActiveRecord), whereby the method that is defined in the same super module that declares it (Bar)' do
      expect(subject.barrable).to eq(true)
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

  context "(with SuperModule.define alternate syntax in Baz) included by a module (Foo), included by another module (Bar), included by a third module (Baz) that is included by a class (BazActiveRecord)" do

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

    it 'invokes singleton method (make_barrable) from super module' do
      expect(subject.barrable).to eq(true)
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

end
