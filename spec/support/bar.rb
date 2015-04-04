module Bar

  include SuperModule
  include Foo
  include Comparable
  validates 'bar', {:presence => true}
  attr_reader :created_at

  # Defines singleton methods via class << self to provide as a test case for SuperModule
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
      puts "make_barrable: Making #{self.inspect} barrable"
      self.barrable = true
    end
  end

  make_barrable
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

