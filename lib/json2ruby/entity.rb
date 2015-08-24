require 'digest/md5'

module JSON2Ruby
  # Entity represents a JSON Object.
  class Entity
    # The String name of the Object - i.e. the field name in which it was first encountered. 
    attr_accessor :name
    # The original String name of the object in the JSON ([^A-Za-z0-9_] are replaced with '_')
    attr_accessor :original_name
    # A Hash of String names to Attribute instances for this Entity, representing its attributes.
    attr_accessor :attributes

    # The short name is 'Entity'
    def self.short_name
      "Entity"
    end

    # Create a new Entity with the specified name and optional Hash of attributes (String name to Entity, Collection or Primitive instances)
    def initialize(name, attributes = {})
      @name = name
      @attributes = attributes
    end

    # Return a 128-bit hash as a hex string, representative of the unique set of fields and their types, including all subobjects.
    # Internally, this is calculated as the MD5 of all field names and their type attr_hash calls.
    def attr_hash
      md5 = Digest::MD5.new
      @attributes.each do |k,v|
        md5.update "#{k}:#{v.attr_hash}"
      end
      md5.hexdigest
    end

    # Compare this Entity with another. An entity is equal to another entity if and only if it has:
    # * The same number of fields
    # * The fields have the same case-sensitive name
    # * The fields have the same types, as tested with `attr_hash`
    # i.e. in short, an entity is equal to another entity if and only if both +attr_hash+ calls return the same value.
    def ==(other)
      return false if other.class != self.class
      attr_hash == other.attr_hash
    end

    # Reset the internal type cache for all Entities everywhere, and reset the global Unknown number.
    def self.reset_parse
      @@objs = {
        RUBYSTRING.attr_hash => RUBYSTRING,
        RUBYINTEGER.attr_hash => RUBYINTEGER,
        RUBYFLOAT.attr_hash => RUBYFLOAT,
        RUBYBOOLEAN.attr_hash => RUBYBOOLEAN,
        RUBYNUMERIC.attr_hash => RUBYNUMERIC,
      }
      @@unknowncount = 0
    end

    # Create a new, or return an existing, Entity named name that supports all fields in obj_hash.
    # Optionally, options can be supplied:
    # * :forcenumeric => true - Use RUBYNUMERIC instead of RUBYINTEGER / RUBYFLOAT.
    #
    # Note: Contained JSON Objects and Arrays will be recursively parsed into Entity and Collection instances.
    def self.parse_from(name, obj_hash, options = {})
      ob = self.new(name)
      obj_hash.each do |k,v|

        orig = k
        k = k.gsub(/[^A-Za-z0-9_]/, "_")

        if v.kind_of?(Array)
          att = Collection.parse_from(k, v, options)
        elsif v.kind_of?(String)
          att = RUBYSTRING
        elsif v.kind_of?(Integer) && !options[:forcenumeric]
          att = RUBYINTEGER
        elsif v.kind_of?(Float) && !options[:forcenumeric]
          att = RUBYFLOAT
        elsif (v.kind_of?(Integer) || v.kind_of?(Float)) && options[:forcenumeric]
          att = RUBYNUMERIC
        elsif !!v==v
          att = RUBYBOOLEAN
        elsif v.kind_of?(Hash)
          att = self.parse_from(k, v, options)
        end
        att.original_name = orig if orig != k
        ob.attributes[k] = att
      end

      x = ob.attr_hash
      return @@objs[x] if @@objs.has_key?(x)
      @@objs[x] = ob
      ob
    end

    # Return the type cache of all Entity objects.
    # This is a Hash of +hash_attr+ values to +Entity+ instances.
    def self.entities
      @@objs
    end

    # Return a string of the form 'Unknown<x>' where <x> is a globally unique sequence.
    def self.get_next_unknown
      @@unknowncount ||= 0
      @@unknowncount += 1
      "Unknown#{@@unknowncount}"
    end

    # Return a string of the form ' (<y>)' where <y> is the original_name of the Entity
    def comment
      x = @name
      x += " (#{@original_name})" unless @original_name.nil?
      x
    end

    reset_parse
  end
end