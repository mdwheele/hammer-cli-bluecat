# HammerCliBluecat

Adds a set of commands to synchronize data from Bluecat Address Manager to a Foreman instance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hammer_cli_bluecat'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hammer_cli_bluecat

## Usage

This Hammer CLI plugin relies on `hammer_cli_foreman` being installed and correctly configured. Additionally, you will need to configure this plugin (`~/.hammer/cli.modules.d/bluecat.yml`):

```
:bluecat:
  :enable_module: true
  :wsdl: https://hostname/Services/API?wsdl
  :username: api-user
  :password: api-password
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mdwheele/hammer-cli-bluecat.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

