require 'digest/md5'

module JSON2Ruby

  class Entity
    attr_accessor :name, :original_name, :attributes

    def self.short_name
      "Entity"
    end

    def initialize(name, attributes = {})
      @name = name
      @attributes = attributes
    end

    def attr_hash
      md5 = Digest::MD5.new
      @attributes.each do |k,v|
        md5.update "#{k}:#{v.attr_hash}"
      end
      md5.hexdigest
    end

    def ==(other)
      return false if other.class != self.class
      attr_hash == other.attr_hash
    end

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

    def self.entities
      @@objs
    end

    def self.get_next_unknown
      @@unknowncount ||= 0
      @@unknowncount += 1
      "Unknown#{@@unknowncount}"
    end

    def comment
      x = @name
      x += " (#{@original_name})" unless @original_name.nil?
      x
    end

    reset_parse
  end
end