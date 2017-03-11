require "nobspw/version"

module NOBSPW
  autoload :PasswordChecker, 'nobspw/password_checker'
  autoload :Configuration, 'nobspw/configuration'

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
