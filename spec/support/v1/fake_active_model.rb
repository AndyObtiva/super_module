# Uses CRLF for line breaks to provide a test case for having SuperModule work with it
# This is done to test support for Windows Ruby files, which usually use CRLF for line breaks
module V1::FakeActiveModel

  include SuperModule

  def self.validates(attribute, options)
    validations << [attribute, options]
  end

  def self.validations
    @validations ||= []
  end

end

