require 'digest/md5'

module JSON2Ruby
  # Collection represents a JSON Array
  class Collection
    # The String name of the Array, i.e. the field name in which it was first encountered. 
    attr_accessor :name
    # The original String name of the Array in the JSON ([^A-Za-z0-9_] are replaced with '_')
    attr_accessor :original_name
    # The array of types (Entity, Collection or Primitive instances) encountered in the JSON Array
    attr_accessor :ruby_types

    # The short name is 'Collection'
    def self.short_name
      "Collection"
    end

    # Create a new Collection with the specified name and optional Array of ypes.
    def initialize(name, ruby_types = {})
      @name = name
      @ruby_types = ruby_types
    end

    # Create a new, or return an existing, Collection named name that supports all types in obj_array.
    # Optionally, options can be supplied:
    # * :forcenumeric => true - Use RUBYNUMERIC instead of RUBYINTEGER / RUBYFLOAT.
    #
    # Note: Contained JSON Objects and Arrays will be recursively parsed into Entity and Collection instances.
    def self.parse_from(name, obj_array, options = {})
      ob = self.new(name)
      obj_array.each do |v|
        if v.kind_of?(Array)
          arr = Collection.parse_from(Entity.get_next_unknown, v, options)
          ob.ruby_types[arr.attr_hash] = arr
        elsif v.kind_of?(String)
          ob.ruby_types[RUBYSTRING.attr_hash] = RUBYSTRING
        elsif v.kind_of?(Integer) && !options[:forcenumeric]
          ob.ruby_types[RUBYINTEGER.attr_hash] = RUBYINTEGER
        elsif v.kind_of?(Float) && !options[:forcenumeric]
          ob.ruby_types[RUBYFLOAT.attr_hash] = RUBYFLOAT
        elsif (v.kind_of?(Float) || v.kind_of?(Integer)) && options[:forcenumeric]
          ob.ruby_types[RUBYNUMERIC.attr_hash] = RUBYNUMERIC
        elsif !!v==v
          ob.ruby_types[RUBYBOOLEAN.attr_hash] = RUBYBOOLEAN
        elsif v.kind_of?(Hash)
          ent = Entity.parse_from(Entity.get_next_unknown, v, options)
          ob.ruby_types[ent.attr_hash] = ent
        end
      end

      x = ob.attr_hash
      return Entity.entities[x] if Entity.entities.has_key?(x)
      Entity.entities[x] = ob
      ob
    end

    # Return a 128-bit hash as a hex string, representative of the set of possible types in the Collection
    # Internally, this is calculated as the MD5 hash of the attr_hash values of all types.
    def attr_hash
      md5 = Digest::MD5.new
      @ruby_types.each do |k,typ|
        md5.update typ.attr_hash
      end
      md5.hexdigest
    end

    # Compare this Collection with another Collection. Two collections are equal if and only if they can contain exactly the same types.
    def ==(other)
      return false if other.class != self.class
      attr_hash == other.attr_hash
    end

    # Generate a String comment of the form '<x>[] (<y)' where <x> and <y> are the name and original name of the Collection respectively.
    def comment
      x = "#{@name}[]"
      x += " (#{@original_name})" unless @original_name.nil?
      x
    end
  end
end