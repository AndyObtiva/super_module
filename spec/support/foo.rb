module Foo

  include SuperModule
  include FakeActiveModel
  validates 'foo', {:presence => true}

  def self.foo
    'self.foo'
  end

  def self.meh
    self
  end

  def foo
    'foo'
  end

end

