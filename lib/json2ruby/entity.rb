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

    def self.parse_from(name, obj_hash, options)
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

    def to_ruby(indent = 0, options = {})
      x = ""
      if options.has_key?(:require)
        options[:require].each { |r| x += "require '#{r}'\r\n" }
        x += "\r\n"
      end
      idt = (' '*indent)
      x += "#{(' '*indent)}#{options[:modules] ? "module" : "class"} #{name}"
      x += " < #{options[:superclass_name]}" if options.has_key?(:superclass_name)
      x += "\r\n"
      if options.has_key?(:extend)
        options[:extend].each { |r| x += "#{(' '*(indent+2))}extend #{r}\r\n" }
        x += "\r\n"
      end
      if options.has_key?(:include)
        options[:include].each { |r| x += "#{(' '*(indent+2))}include #{r}\r\n" }
        x += "\r\n"
      end
      x += attributes_to_ruby(indent+2, options)
      x += "#{(' '*indent)}end\r\n"
      x
    end

    def attributes_to_ruby(indent, options = {})
      ident = (' '*indent)
      x = ""
      @attributes.each do |k,v|
        if (v.is_a?(Collection))
          x += "#{ident}#{options[:collectionmethod]} :#{k}"
        else
          x += "#{ident}#{options[:attributemethod]} :#{k}"
        end
        if options[:includetypes]
          x += ", '#{options[:namespace]+"::"+v.name}'" unless v.is_a?(Primitive)
        end
        x += " # #{v.comment}\r\n"
      end
      x
    end

    def comment
      x = @name
      x += " (#{@original_name})" unless @original_name.nil?
      x
    end
  end
end