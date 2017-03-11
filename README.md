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

TODO: Write usage instructions here

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

