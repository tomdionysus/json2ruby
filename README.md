# json2ruby

[![Build Status](https://travis-ci.org/tomdionysus/json2ruby.svg?branch=master)](https://travis-ci.org/tomdionysus/json2ruby) 
[![Coverage Status](https://coveralls.io/repos/tomdionysus/json2ruby/badge.svg?branch=master&service=github)](https://coveralls.io/github/tomdionysus/json2ruby?branch=master) 
[![Gem Version](https://badge.fury.io/rb/json2ruby.svg)](http://badge.fury.io/rb/json2ruby)
[![Dependency Status](https://gemnasium.com/tomdionysus/json2ruby.svg)](https://gemnasium.com/tomdionysus/json2ruby)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/json2ruby?color=brightgreen)](http://ruby-gem-downloads-badge.herokuapp.com/json2ruby?color=brightgreen)

A ruby rool for generating POROs from JSON data. It is intended to generate ruby model classes/modules from existing JSON data, e.g. responses from an API.

The tool will 'fold down' objects with identical fields - i.e. if an object has exactly the same field names and types as another, it will assume they are the same type.

'Root' entities are named after the files that they are parsed from. Entities with no obvious name (items in an array, for instance) are named `Unknown<x>` where `x` increments from 1. 

## Installation

```bash
gem install json2ruby
```

## Usage

```bash
json2ruby.rb [options] <file.json> [<file.json>....]
```

| Option Flags             | Default          | Description                                     |
|:-------------------------|:-----------------|:-------------------------------------------------|
| `-o, --outputdir`        | `./classes`      | The output directory for Ruby files             |
| `-m, --modulename`       |                  | The Ruby module for files                       |
| `-s, --superclass`       |                  | The superclass for classes                      |
| `-r, --require`          |                  | Add ruby `require` to files                     |
| `-i, --include`          |                  | Add ruby `include` to files                     |
| `-e, --extend`           |                  | Add ruby `extend` to files                      |
| `-M, --modules`          |                  | Generate Ruby modules, not classes              |
| `-a, --attributemethod`  | `attr_accessor`  | Use a custom attribute definition method        |
| `-c, --collectionmethod` | `attr_accessor`  | Use a custom collection definition method       |
| `-t, --types`            |                  | Include type name in attribute definition call  |
| `-b, --baseless`         |                  | Don't generate for the root object in each file |
| `-f, --forceoverwrite`   |                  | Overwrite Existing files                        |
| `-N, --forcenumeric`     |                  | Use Numeric instead of Integer/Float            |
| `-v, --verbose`          |                  | Be verbose, List every operation/file           |

## Example

Generate a simple set of POROs from an API response JSON file, be verbose:

```bash
./json2ruby.rb -v data.json
```

Generate a (very) basic set of [apotonick/representable](https://github.com/apotonick/representable) compatible representer modules:

```bash
./json2ruby.rb -r representable/json-i Representable::JSON -M -a property -c collection data.json 
```

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

The option `-N, --forcenumeric` can be useful to fold down identical types where an attribute which is a float happens to have an integer value, to avoid generating two identical types.

## Documentation

Regenerate the documentation with 'rdoc':

```bash
rdoc
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
