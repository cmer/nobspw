module NOBSPW
  class PasswordChecker
    include NOBSPW::ValidationMethods

    def initialize(name: nil, username: nil, email: nil, password:)
      @name, @username, @email, @password = \
        name&.strip, username&.strip, email&.strip, password&.strip

      raise ArgumentError.new("Password was not specified.") if password.nil? || password.strip.length == 0
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
        @weak_password_reasons << method if send("#{method}?")
      end

      @strong = @weak_password_reasons.empty?
    end

    def grep_command(path)
      "#{NOBSPW.configuration.grep_path} '^#{@password}$' #{path}"
    end
  end
end
