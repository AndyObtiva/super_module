module FakeActiveModel

  include SuperModule

  def self.validates(attribute, options)
    puts "#{self.inspect} is calling validations(#{attribute}, #{options.inspect})"
    validations << [attribute, options]
  end

  def self.validations
    puts "#{self.inspect} is calling validations"
    @validations ||= []
  end

end

