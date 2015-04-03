module Bar

  include SuperModule
  include Foo
  include Comparable
  validates 'bar', {:presence => true}
  attr_reader :created_at

  class << self
    include Forwardable

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
  end

  def_delegators :@bar, :length

  def initialize
    @bar = bar
    @created_at = Time.now.to_f
  end

  def bar
    'bar'
  end
  
  def <=>(other)
    created_at <=> other.created_at
  end

end

