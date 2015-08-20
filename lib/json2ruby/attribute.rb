require 'digest/md5'

module JSON2Ruby
  class Attribute
    attr_accessor :name, :original_name, :ruby_type

    def self.short_name
      "Attribute"
    end

    def initialize(name, ruby_type = nil)
      @name = name
      @ruby_type = ruby_type || "_unknown"
    end

    def attr_hash
      Digest::MD5.hexdigest("#{@name}:#{@ruby_type}")
    end

    def ==(other)
      return false if other.class != self.class
      attr_hash == other.attr_hash
    end
  end
end