require 'digest/md5'

module JSON2Ruby
  # The Attribute class represents a field on an Entity - i.e. A field name and associated type. 
  class Attribute
    # The String name of the Attribute
    attr_accessor :name
    # The original String name of the Array in the JSON ([^A-Za-z0-9_] are replaced with '_')
    attr_accessor :original_name
    # The type of the attribute, i.e. a Entity, Collection or Primitive instance
    attr_accessor :ruby_type

    # The short name is 'Attribute'
    def self.short_name
      "Attribute"
    end

    # Create a new attribute with the supplied String name and optional String type name. 
    # If the type is not supplied or nil, if will be assigned '_unknown'
    def initialize(name, ruby_type = nil)
      @name = name
      @ruby_type = ruby_type || "_unknown"
    end

    # Return the MD5 hash of the name and the type.
    def attr_hash
      Digest::MD5.hexdigest("#{@name}:#{@ruby_type}")
    end

    # An Attribute is equal to another if and only if its attr_hash value is the same.
    def ==(other)
      return false if other.class != self.class
      attr_hash == other.attr_hash
    end
  end
end