require_relative '../../../lib/super_module'

super_module :Foo
  def self.hello
    self
  end
end
