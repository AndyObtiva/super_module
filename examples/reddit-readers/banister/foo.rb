require_relative '../../../lib/super_module'

module Foo
  include SuperModule
  def self.hello
    self
  end
end
