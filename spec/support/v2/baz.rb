super_module 'V2::Baz' do
  include V2::Bar
  make_barrable
  validates 'baz', {:presence => true}
  attr_reader :baz_factor
  
  class << self
    def baz
      'self.baz'
    end
  end
  
  def initialize(baz_factor)
    super()
    @baz_factor = baz_factor
  end

  def baz
    'baz'
  end

  def <=>(other)
    baz_factor <=> other.baz_factor
  end

end

