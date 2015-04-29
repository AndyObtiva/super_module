require 'forwardable'

module Support::V2Alt
  Bar = super_module do
    include Foo
    include Comparable
    validates 'bar', {:presence => true}
    attr_reader :created_at

    # Defines singleton methods via class << self to provide as a test case for SuperModule
    class << self
      include Forwardable

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

    make_barrable
    def_delegators :@bar, :length

    def initialize
      @bar = bar
      @created_at = Time.now.to_f
    end

    def bar
      'bar'
    end

    # Defines singleton method via a form of eval (class_eval) to provide as a test case for SuperModule
    class_eval do
      def self.bar
        'self.bar'
      end
    end
    
    def <=>(other)
      created_at <=> other.created_at
    end

  end

end
