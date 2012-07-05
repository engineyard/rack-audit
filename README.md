# Rack::Audit

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'rack-audit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-audit

## Releasing

    gem bump -trv patch --key engineyard --host http://rubygems.engineyard.com

## Usage

Add into your `config.ru`:

    if ENV['FORENSICD_URL']
      require 'forensicology'
      STDERR.puts "Using forensic"
      use Rack::Forensicology, "Server (#{ENV['RAILS_ENV']})", ENV['FORENSICD_URL']
    else
      STDERR.puts "Not logging requests, set ENV['FORENSICD_URL'] to do so."
    end
    run Application

Insert via your Rails `config/application.rb`

    if ENV['FORENSICD_URL']
      config.middle.insert_after Airbrake::Rack, Rack::Audit, "Rails", ENV['FORENSICD_URL']
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
