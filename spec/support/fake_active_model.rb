# Uses CRLF for line breaks to provide a test case for having SuperModule work with it
# This is done to test support for Windows Ruby files, which usually use CRLF for line breaks
module FakeActiveModel

  include SuperModule

  # Defines method on a single line to provide as a test case for SuperModule
  def self.validates(attribute, options); validations << [attribute, options]; end

  # Defines method on a single line to provide as a test case for SuperModule
  def self.validations; @validations ||= []; end

end

