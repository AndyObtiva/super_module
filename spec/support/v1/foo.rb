module Support::V1::Foo
  include SuperModule
  include Support::V1::FakeActiveModel
  validates 'foo', {:presence => true}

  class << self
    def foo_class_self
      'self.foo_class_self'
    end

    def foo_class_self_define_method; 'self.foo_class_self_define_method'; end

    def foo_private_declaration_follow_up
      'self.foo_private_declaration_follow_up'
    end
    private :foo_private_declaration_follow_up

    def foo_protected_declaration_follow_up
      'self.foo_protected_declaration_follow_up'
    end
    protected :foo_protected_declaration_follow_up

    private 
    def foo_private
      'self.foo_private'
    end
  
    protected
    def foo_protected
      'self.foo_protected'
    end

  end

  def self.meh
    self
  end

  def self.foo
    'self.foo'
  end

  def self.foo_one_line; 'self.foo_one_line'; end

  def self.foo_single_param(param1)
    "self.foo(#{param1})"
  end

  def self.foo_multi_params(param1, param2, param3)
    "self.foo(#{param1},#{param2},#{param3})"
  end

  def self.foo_block(&formatter)
    formatter.call('self.foo')
  end

  def self.foo_single_param_block(param1, &formatter)
    formatter.call('self.foo', param1)
  end

  def self.foo_multi_params_block(param1, param2, param3, &formatter)
    formatter.call('self.foo', param1, param2, param3)
  end

  public

  def self.empty
  end

  def self.empty_one_empty_line

  end

  def self.empty_with_comment
    # no op
  end

  def self.empty_one_line_definition; end

  def self.empty_one_line_definition_with_spaces;          end

  def foo
    'foo'
  end

end

