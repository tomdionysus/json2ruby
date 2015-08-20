module JSON2Ruby

  class Primitive
    attr_accessor :name, :original_name, :attr_hash

    def self.short_name
      "Primitive"
    end

    def initialize(name, attr_hash)
      @name = name
      @attr_hash = attr_hash
    end

    def attr_hash
      @attr_hash
    end

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
  RUBYNUMERIC = Primitive.new("Numeric","0123456789ABCDEF0123456789ABCDE2")
end