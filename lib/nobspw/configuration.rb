module NOBSPW
  class Configuration
    attr_accessor :min_password_length
    attr_accessor :max_password_length
    attr_accessor :min_unique_characters
    attr_accessor :dictionary_path
    attr_accessor :grep_path
    attr_accessor :domain_name
    attr_accessor :blacklist
    attr_accessor :validation_methods

    def initialize
      @min_password_length      = 10
      @max_password_length      = 256
      @min_unique_characters    = 5
      @dictionary_path          = File.join(File.dirname(__FILE__), "..", "db", "dictionary.txt")
      @grep_path                = `which grep`.strip
      @domain_name              = nil
      @blacklist                = nil
      @validation_methods       = NOBSPW::ValidationMethods::DEFAULT_VALIDATION_METHODS
    end
  end
end
