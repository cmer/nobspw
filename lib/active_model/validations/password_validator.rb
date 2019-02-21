class ActiveModel::Validations::PasswordValidator < ActiveModel::EachValidator
  DEFAULT_ERROR_MESSAGES = {
    name_included_in_password: 'is too similar to your name',
    username_included_in_password: 'is too similar to your username',
    email_included_in_password: 'is too similar to your email',
    domain_included_in_password: 'is too similar to this domain name',
    password_too_short: 'is too short',
    password_too_long: 'is too long',
    not_enough_unique_characters: 'does not have enough unique characters',
    password_not_allowed: 'is not allowed',
    password_too_common: 'is too common',
    fallback: 'is not valid'
  }

  def validate_each(record, attribute, value)
    pc = NOBSPW::PasswordChecker.new password: record.send(attribute),
                                     email:    email_value(record),
                                     name:     name_value(record),
                                     username: username_value(record)

    pc.weak_password_reasons.each do |reason|
      record.errors[attribute] << get_message(reason)
    end
    pc.strong?
  end

  def error_messages
    @error_messages ||= DEFAULT_ERROR_MESSAGES
  end

  def error_messages=(em)
    @error_messages = em
  end

  private

  def email_value(record)
    if options.keys.include?(:email)
      return nil if options[:email].nil?
      return record.send(options[:email])
    end

    %i(email email_address).each do |f|
      return record.send(f) if record.respond_to?(f)
    end

    nil
  end

  def username_value(record)
    if options.keys.include?(:username)
      return nil if options[:username].nil?
      return record.send(options[:username])
    end

    %i(username user_name user screenname screen_name).each do |f|
      return record.send(f) if record.respond_to?(f)
    end

    nil
  end

  def name_value(record)
    if options.keys.include?(:name)
      return nil if options[:name].nil?
      return record.send(options[:name])
    end

    %i(name full_name).each do |f|
      return record.send(f) if record.respond_to?(f)
    end

    if record.respond_to?(:first_name) && record.respond_to?(:last_name)
      return "#{record.send(:first_name)} #{record.send(:last_name)}"
    end

    nil
  end

  def get_message(reason)
    I18n.t "password_validator.#{reason}", default: error_messages[reason] ||
                                                    error_messages[:fallback]
  end
end
