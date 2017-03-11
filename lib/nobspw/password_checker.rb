module NOBSPW
  class PasswordChecker
    CHECKS = %i(name_included_in_password
                email_included_in_password
                domain_included_in_password
                password_too_short
                password_too_long
                not_enough_unique_characters
                password_blacklisted
                password_too_common)

    def initialize(name: nil, username: nil, email: nil, password:)
      @name, @username, @email, @password = \
        name&.strip, username&.strip, email&.strip, password&.strip
    end

    def strong?
      check_password if @strong.nil?
      @strong
    end

    def weak_password_reasons
      check_password if @weak_password_reasons.nil?
      @weak_password_reasons
    end

    private

    def check_password
      @weak_password_reasons = []

      CHECKS.each do |check|
        @weak_password_reasons << check if send("#{check}?")
      end

      @strong = @weak_password_reasons.empty?
    end

    def name_included_in_password?
      return nil unless @name
      words = remove_word_separators(@name).split(' ')
      words_included_in_password?(words)
    end

    def email_included_in_password?
      return nil unless @email
      words = remove_word_separators(email_without_extension(@email)).split(' ')
      words_included_in_password?(words)
    end

    def domain_included_in_password?
      domain = NOBSPW.configuration.domain_name
      return nil unless domain

      words_included_in_password?(domain) ||
      remove_word_separators(words_included_in_password?(domain)).gsub(' ', '')
    end

    def password_blacklisted?
      return nil unless NOBSPW.configuration.blacklist
      NOBSPW.configuration.blacklist.include?(@password)
    end

    def password_too_short?
      @password.length < NOBSPW.configuration.min_password_length
    end

    def password_too_long?
      @password.length > NOBSPW.configuration.max_password_length
    end

    def not_enough_unique_characters?
      unique  = @password.split(//).uniq.size
      minimum = NOBSPW.configuration.min_unique_characters
      !(unique >= minimum)
    end

    def words_included_in_password?(words)
      downcased_pw = @password.downcase
      words.each do |word|
        return true if word.length > 2 && downcased_pw.index(word.downcase)
      end; false
    end

    def password_too_common?
      `#{grep_command(NOBSPW.configuration.dictionary_path)}`

      case $?.exitstatus
      when 0
        true
      when 1
        false
      when 127
        raise StandardError.new("Grep not found at: #{NOBSPW.configuration.grep_path}")
      else
        false
      end
    end

    def grep_command(path)
      "#{NOBSPW.configuration.grep_path} '^#{@password}$' #{path}"
    end

    def email_without_extension(email)
      name, domain, whatev = email.split("@", 3)
      "#{name}@#{domain}"
    end

    def remove_word_separators(str)
      str.gsub(/-|_|\.|\'|\"|\@/, ' ')
    end
  end

end
