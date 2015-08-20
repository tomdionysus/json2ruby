require 'digest/md5'

module JSON2Ruby
  class Collection
    attr_accessor :name, :original_name, :ruby_types

    def self.short_name
      "Collection"
    end

    def initialize(name, ruby_types = {})
      @name = name
      @ruby_types = ruby_types
    end

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

    def attr_hash
      md5 = Digest::MD5.new
      @ruby_types.each do |k,typ|
        md5.update typ.attr_hash
      end
      md5.hexdigest
    end

    def ==(other)
      return false if other.class != self.class
      attr_hash == other.attr_hash
    end

    def comment
      x = "#{@name}[]"
      x += " (#{@original_name})" unless @original_name.nil?
      x
    end
  end
end