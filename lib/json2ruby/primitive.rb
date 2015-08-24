module JSON2Ruby
  # Represents a JSON Primitive. You should not instantiate this class - use the static instances:
  # * JSON2Ruby::RUBYSTRING for JSON Strings
  # * JSON2Ruby::RUBYINTEGER for JSON Integers
  # * JSON2Ruby::RUBYFLOAT for JSON Floats
  # * JSON2Ruby::RUBYBOOLEAN for JSON Booleans
  # * JSON2Ruby::RUBYNUMERIC for JSON Numerics (Integers or floats)
  class Primitive
    # The +String+ name of the Primitive. 
    attr_accessor :name
    # +String+ Exists for compatibility.
    attr_accessor :original_name
    # The static +attr_hash+ of the Primitive.
    attr_accessor :attr_hash

    # The short name is 'Primitive'
    def self.short_name
      "Primitive"
    end

    # Create a new Primitive with the specified +name+ and +attr_hash+
    def initialize(name, attr_hash)
      @name = name
      @attr_hash = attr_hash
    end

    # Return the +name+ of the Primitive
    def comment
      @name
    end
  end

  # Primitive Representing a Ruby String
  RUBYSTRING = Primitive.new("String","0123456789ABCDEF0123456789ABCDEF")
  # Primitive Representing a Ruby Integer
  RUBYINTEGER = Primitive.new("Integer","0123456789ABCDEF0123456789ABCDE0")
  # Primitive Representing a Ruby Float
  RUBYFLOAT = Primitive.new("Float","0123456789ABCDEF0123456789ABCDE1")
  # Primitive Representing a Ruby Boolean
  RUBYBOOLEAN = Primitive.new("Boolean","0123456789ABCDEF0123456789ABCDE2")
  # Psuedo-Primitive Representing a Numeric
  RUBYNUMERIC = Primitive.new("Numeric","0123456789ABCDEF0123456789ABCDE3")
end