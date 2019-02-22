require 'shellwords'

module NOBSPW
  class PasswordChecker
    include NOBSPW::ValidationMethods

    def initialize(name: nil, username: nil, email: nil, password:)
      @name, @username, @email, @password = \
        name&.strip, username&.strip, email&.strip, (password || '').strip
    end

    def strong?
      check_password if @strong.nil?
      @strong
    end

    def weak?
      !strong?
    end

    def weak_password_reasons
      check_password if @weak_password_reasons.nil?
      @weak_password_reasons
    end
    alias_method :reasons, :weak_password_reasons

    private

    def check_password
      @weak_password_reasons = []
      NOBSPW.configuration.validation_methods.each do |method|
        if send("#{method}")
          @weak_password_reasons << method.to_s.sub(/\?$/, '').to_sym
          break if NOBSPW.configuration.interrupt_validation_for.include?(method)
        end
      end

      @strong = @weak_password_reasons.empty?
    end
  end
end
