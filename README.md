# NOBSPW - No Bullshit Password strength checker

NOBSPW is simple, no non-sense password strength checker written in Ruby. It does NOT validate against [bullshit password rules](https://twitter.com/codinghorror/status/631238409269309440?ref_src=twsrc%5Etfw) such as:

- must contain uppercase _(bullshit!)_
- must contain lowercase _(bullshit!)_
- must contain a number _(bullshit!)_
- must contain a special character _(bullshit!)_

Instead, it validates your user's password against a few important criteria. This ensures strong passwords without the hassle generally associated with complex (and useless) password rules.

The criteria currently are:

- minimum (and maximum) length. 10 characters is the recommended minimum and is the default value
- common passwords from a dictionary of the 100,000 most common passwords (or your own dictionary)
- basic entropy (not too many of the same character)
- reject special case passwords such as the user's name, email, domain of the site/app

This software was inspired by [Password Rules are Bullshit](https://blog.codinghorror.com/password-rules-are-bullshit/) by Jeff Atwood.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nobspw'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nobspw

## Usage

### Vanilla Ruby

```ruby
  pwc = NOBSPW::PasswordChecker.new password: 'mystrongpassword',
                                    name: 'John Smith',           # optional but recommended
                                    username: 'bigjohn43',        # optional but recommended
                                    email: 'john@example.org'     # optional but recommended
  pwc.strong?
  pwc.weak?
  pwd.weak_password_reasons  # returns an array of Symbols with reasons why password is weak
  pwd.reasons                # short alias of weak_password_reasons
```

Optionally, you can configure some options:

```ruby
  NOBSPW.configure do |config|
    config.min_password_length = 10
    config.max_password_length = 256
    config.min_unique_characters = 5
    config.dictionary_path = 'path/to/dictionary.txt'
    config.grep_path = '/usr/bin/grep'
    config.domain_name = 'mywebsitedomain.com' # it is recommended you configure this
    config.blacklist = ['this_password_is_not_allowed']
  end
```

### Ruby on Rails

I included `PasswordValidator` for Rails. Validating passwords in your model couldn't be easier:

```ruby
validates :password, presence: true, password: true, if: -> { new_record? || changes[:password] }
```

PasswordValidator will try to guess the correct field name for each `PasswordChecker` argument as follow:

- `username`: `username user_name user screenname screen_name`
- `name`: `name full_name first_name+last_name`
- `email`: `email email_address`

If you have field names different than above, you can tell `PasswordValidator` which fields to use for specific attributes:

```ruby
validates :password, presence: true,
                     password: { :name => :customer_name,
                                 :email => :electronic_address },
          if: -> { new_record? || changes[:password] }
```

# Checks

NOBSPW currently checks for the following, in this order:

```ruby
:name_included_in_password
:email_included_in_password
:domain_included_in_password
:password_too_short
:password_too_long
:not_enough_unique_characters
:password_blacklisted
:password_too_common
```

If any of these tests fail, they'll be returned by `#reasons`, or with Rails, they'll be added to `errors[:password]`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

