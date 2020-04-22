require 'spec_helper'

class V1::FakeActiveRecord
  include ::V1::FakeActiveModel
end

class V1::FooActiveRecord < V1::FakeActiveRecord
  include ::V1::Foo
end

class V1::BarActiveRecord < V1::FakeActiveRecord
  include ::V1::Bar
end

class V1::BazActiveRecord < V1::FakeActiveRecord
  include ::V1::Baz
end

module V1::SummarizedActiveModel
  include SuperModule

  module FakeClassMethods1
    def fake_summary
      'This is a fake summary.'
    end
  end

  class << self
    def validates(attribute, options)
      super # test that singleton class inheritance works
    end

    def validations
      super # test that singleton class inheritance works
    end

    def summary
      validations.flatten.map(&:to_s).join("/")
    end

    def only_call_in_super_module_included
      raise 'Error' unless self == ::V1::SummarizedActiveModel
    end
  end

  super_module_included do |klass|
    if klass.name.split(/::/).last.start_with?('Fake')
      klass.extend(FakeClassMethods1)
    end
    only_call_in_super_module_included # should not get recorded for submodules/subclasses
  end

end

module V1::ExtraSummarizedActiveModel
  include SuperModule

  include ::V1::SummarizedActiveModel

  super_module_included do |klass|
    if klass.name.split(/::/).last.start_with?('Fake')
      klass.extend(FakeClassMethods2)
    end
  end

  module FakeClassMethods2
    def fake_extra
      'This is fake extra.'
    end
  end

  class << self
    def extra
      "This is extra."
    end
  end
end

class V1::SummarizedActiveRecord < V1::FakeActiveRecord
  include ::V1::SummarizedActiveModel
end

class V1::FakeSummarizedActiveRecord < V1::FakeActiveRecord
  include ::V1::SummarizedActiveModel
end

class V1::ExtraSummarizedActiveRecord < V1::FakeActiveRecord
  include ::V1::ExtraSummarizedActiveModel
end

class V1::FakeExtraSummarizedActiveRecord < V1::FakeActiveRecord
  include ::V1::ExtraSummarizedActiveModel
end

describe SuperModule do
  context V1 do
    context "standalone module usage" do
      subject { V1::FakeActiveModel }

      it 'allows invoking class methods' do
        subject.validates 'foo', {:presence => true}
        expect(subject.validations).to include(['foo', {:presence => true}])
      end

      it 'raises error if super module implements self.included(base)' do
        expect do
          module SomeSuperModule
            include SuperModule
            def self.included(base)
            end
          end
        end.to raise_error('Do not implement "self.included(base)" hook for a super module! Use "super_module_included {|base| ... }" instead.')
      end
    end

    context "included by a module (Foo) that is included by a class (FooActiveRecord)" do

      subject { V1::FooActiveRecord }

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

      subject { V1::BarActiveRecord }

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

      subject { V1::BazActiveRecord }

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
        instance = subject.new(100)

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

    context 'meta-programming included' do
      it 'returns summary' do
        V1::SummarizedActiveRecord.validates 'foo', {:presence => true}
        V1::SummarizedActiveRecord.validates 'bar', {:presence => true}
        expect(V1::SummarizedActiveRecord.summary).to eq('foo/{:presence=>true}/bar/{:presence=>true}')
        expect{V1::SummarizedActiveRecord.fake_summary}.to raise_error
      end
      it 'returns fake summary' do
        V1::FakeSummarizedActiveRecord.validates 'foo', {:presence => true}
        V1::FakeSummarizedActiveRecord.validates 'bar', {:presence => true}
        expect(V1::FakeSummarizedActiveRecord.summary).to eq('foo/{:presence=>true}/bar/{:presence=>true}')
        expect(V1::FakeSummarizedActiveRecord.fake_summary).to eq('This is a fake summary.')
      end
      it 'returns extra' do
        V1::ExtraSummarizedActiveRecord.validates 'foo', {:presence => true}
        V1::ExtraSummarizedActiveRecord.validates 'bar', {:presence => true}
        expect(V1::ExtraSummarizedActiveRecord.summary).to eq('foo/{:presence=>true}/bar/{:presence=>true}')
        expect{V1::ExtraSummarizedActiveRecord.fake_summary}.to raise_error
        expect(V1::ExtraSummarizedActiveRecord.extra).to eq('This is extra.')
        expect{V1::ExtraSummarizedActiveRecord.fake_extra}.to raise_error
      end
      it 'returns fake extra' do
        V1::FakeExtraSummarizedActiveRecord.validates 'foo', {:presence => true}
        V1::FakeExtraSummarizedActiveRecord.validates 'bar', {:presence => true}
        expect(V1::FakeExtraSummarizedActiveRecord.summary).to eq('foo/{:presence=>true}/bar/{:presence=>true}')
        expect(V1::FakeExtraSummarizedActiveRecord.fake_summary).to eq('This is a fake summary.')
        expect(V1::FakeExtraSummarizedActiveRecord.extra).to eq('This is extra.')
        expect(V1::FakeExtraSummarizedActiveRecord.fake_extra).to eq('This is fake extra.')
      end
    end
  end
end
