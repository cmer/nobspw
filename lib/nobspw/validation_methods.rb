module NOBSPW
  module ValidationMethods
    DEFAULT_VALIDATION_METHODS = %i(name_included_in_password?
                                    email_included_in_password?
                                    domain_included_in_password?
                                    password_too_short?
                                    password_too_long?
                                    not_enough_unique_characters?
                                    password_not_allowed?
                                    password_too_common?)

    private

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
      domain = strip_extension_from_domain(domain)
      domain_without_separator = remove_word_separators(domain).gsub(' ', '')
      words_included_in_password?([domain, domain_without_separator])
    end

    def password_not_allowed?
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

    # Helper methods

    def email_without_extension(email)
      name, domain, whatev = email.split("@", 3)
      "#{name}@#{strip_extension_from_domain(domain)}"
    end

    def strip_extension_from_domain(domain)
      domain.split(".").first
    end

    def remove_word_separators(str)
      str.gsub(/-|_|\.|\'|\"|\@/, ' ')
    end

  end
end
