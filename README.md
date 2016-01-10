# ToonApi (WIP)

Ruby gem to interface with Eneco Toon intelligent thermostat. Port of https://github.com/rvdm/toon

## Usage

```
require 'toon_api'

toon = ToonApi.new(username, password)
toon.login

toon.get_thermostat_info

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maartenvanvliet/toon_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

