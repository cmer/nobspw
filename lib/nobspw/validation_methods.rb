require 'shellwords'
require 'open3'

module NOBSPW
  module ValidationMethods
    DEFAULT_VALIDATION_METHODS = %i(password_empty?
                                    name_included_in_password?
                                    username_included_in_password?
                                    email_included_in_password?
                                    domain_included_in_password?
                                    password_too_short?
                                    password_too_long?
                                    not_enough_unique_characters?
                                    password_not_allowed?
                                    password_too_common?)

    INTERRUPT_VALIDATION_FOR   = %i(password_empty?)
    STDIN_GREP_COMMAND         = ['/usr/bin/grep', '-m 1', '-f', '/dev/stdin',
                                  NOBSPW.configuration.dictionary_path]

    private

    def password_empty?
      @password.nil? || @password.strip == ''
    end

    def name_included_in_password?
      return nil unless @name
      words = remove_word_separators(@name).split(' ')
      words_included_in_password?(words)
    end

    def username_included_in_password?
      return nil unless @username
      words = remove_word_separators(@username).split(' ')
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

      NOBSPW.configuration.blacklist.each do |expression|
        if expression.is_a?(Regexp)
          return true if @password.match?(expression)
        else
          return true if expression.to_s == @password
        end
      end

      false
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
      NOBSPW.configuration.use_ruby_grep ? ruby_grep : shell_grep
    end

    # Helper methods

    def shell_grep
      raise StandardError.new("Grep not found at: #{NOBSPW.configuration.grep_path}") \
        if !File.exist?(NOBSPW.configuration.grep_path)

      output = Open3.popen3(STDIN_GREP_COMMAND.join(" "), out: '/dev/null') { |stdin, stdout, stderr, wait_thr|
        stdin.puts "^#{escaped_password}$"
        stdin.close
        wait_thr.value
      }
      output.success?
    end

    def ruby_grep
      File.open(NOBSPW.configuration.dictionary_path).grep(/^#{escaped_password}$/).present?
    end

    def email_without_extension(email)
      name, domain, whatev = email&.split("@", 3)
      "#{name}@#{strip_extension_from_domain(domain)}"
    end

    def strip_extension_from_domain(domain)
      domain&.split(".")&.first
    end

    def remove_word_separators(str)
      str&.gsub(/-|_|\.|\'|\"|\@/, ' ')
    end

    def escaped_password(password = @password)
      Shellwords.escape(password)
    end
  end
end
