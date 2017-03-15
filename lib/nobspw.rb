require "nobspw/version"

module NOBSPW
  autoload :PasswordChecker, 'nobspw/password_checker'
  autoload :ValidationMethods, 'nobspw/validation_methods'
  autoload :Configuration, 'nobspw/configuration'

  if (defined?(::ActiveModel) && ActiveModel::VERSION::MAJOR >= 4) && defined?(I18n)
    require_relative 'active_model/validations/password_validator'
  end

  class << self
    attr_writer :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
