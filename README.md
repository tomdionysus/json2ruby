# json2ruby

A ruby rool for generating POROs from JSON data. It is intended to generate ruby model classes from existing JSON data, e.g. responses from an API.

The tool will 'fold down' objects with identical fields - i.e. if an object has exactly the same fields as another, we assume they are identical and therefore the same type.

## Installation

```bash
git clone git@github.com:tomdionysus/json2ruby.git
```

## Usage

```bash
json2ruby.rb [options] <file.json> [<file.json>....]
```

| Option Flags            | Default         | Description                               |
|:------------------------|:----------------|:------------------------------------------|
| `-o, --outputdir`       | `./classes`     | The output directory for Ruby files       |
| `-m, --modulename`      |                 | The Ruby module for files                 |
| `-s, --superclass`      |                 | The superclass for classes                |
| `-r, --require`         |                 | Add ruby `require` to files               |
| `-i, --include`         |                 | Add ruby `include` to files               |
| `-e, --extend`          |                 | Add ruby `extend` to files                |
| `-M, --modules`         |                 | Generate Ruby modules, not classes        |
| `-a, --attributemethod` | `attr_accessor` | Use a custom attribute definition method  |
| `-v, --verbose`         | n/a             | Be verbose, List every operation/file     |

## Notes

The option `-m, --modulename` can take path module names in `FirstModule::Submodule::SubSubModule` format, which will produce classes like so:

```ruby
module FirstModule
  module Submodule
    module SubSubModule
      class JSONObject
      ...
      end
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
