class ActiveModel::Validations::PasswordValidator < ActiveModel::EachValidator
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
    case reason
    when :name_included_in_password
      I18n.t 'password_validator.is_too_similar_to_your_name', default: 'is too similar to your name'
    when :email_included_in_password
      I18n.t 'password_validator.is_too_similar_to_your_email', default: 'is too similar to your email'
    when :domain_included_in_password
      I18n.t 'password_validator.is_too_similar_to_this_domain_name', default: 'is too similar to this domain name'
    when :password_too_short
      I18n.t 'password_validator.is_too_short', default: 'is too short'
    when :password_too_long
      I18n.t 'password_validator.is_too_long', default: 'is too long'
    when :password_blacklisted
      I18n.t 'password_validator.is_not_allowed', default: 'is not allowed'
    when :password_too_common
      I18n.t 'password_validator.is_too_common', default: 'is too common'
    when :not_enough_unique_characters
      I18n.t 'password_validator.does_not_have_enough_unique_chars', default: 'does not have enough unique characters'
    else
      I18n.t 'password_validator.is_not_valid', default: 'is not valid'
    end
  end

end
