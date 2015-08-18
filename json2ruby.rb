#!/usr/bin/ruby

require "json"
require "optparse"
require 'digest'
require 'pp'
## Support Classes

class RubyJSONPrimitive
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

RUBYSTRING = RubyJSONPrimitive.new("String","0123456789ABCDEF0123456789ABCDEF")
RUBYINTEGER = RubyJSONPrimitive.new("Integer","0123456789ABCDEF0123456789ABCDE0")
RUBYFLOAT = RubyJSONPrimitive.new("Float","0123456789ABCDEF0123456789ABCDE1")
RUBYBOOLEAN = RubyJSONPrimitive.new("Boolean","0123456789ABCDEF0123456789ABCDE2")

class RubyJSONEntity
  attr_accessor :name, :original_name, :attributes

  def self.short_name
    "Object"
  end

  def initialize(name)
    @name = name
    @attributes = {}
  end

  def attr_hash
    md5 = Digest::MD5.new
    @attributes.each do |k,v|
      md5.update "#{k}:#{v.attr_hash}"
    end
    md5.hexdigest
  end

  def ==(other)
    return false if other.class != self
    attr_hash == other.attr_hash
  end

  def self.reset_parse
    @@objs = {
      RUBYSTRING.attr_hash => RUBYSTRING,
      RUBYINTEGER.attr_hash => RUBYINTEGER,
      RUBYFLOAT.attr_hash => RUBYFLOAT,
      RUBYBOOLEAN.attr_hash => RUBYBOOLEAN,
    }
    @@unknowncount = 0
  end

  def self.parse_from(name, obj_hash)
    ob = self.new(name)
    obj_hash.each do |k,v|

      orig = k
      k = k.gsub(/[^A-Za-z0-9_]/, "_")

      if v.kind_of?(Array) 
        att = RubyJSONArray.parse_from(k,v)
      elsif v.kind_of?(String)
        att = RUBYSTRING
      elsif v.kind_of?(Integer)
        att = RUBYINTEGER
      elsif v.kind_of?(Float)
        att = RUBYFLOAT
      elsif !!v==v
        att = RUBYBOOLEAN
      elsif v.kind_of?(Hash)
        att = self.parse_from(k,v)
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
    x += "#{(' '*indent)}"
    if options[:modules] 
      x+="module"
    else
      x+="class"
    end
    x += " #{name}"
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
      x += "#{ident}#{options[:attributemethod]} :#{k} # #{v.comment}\r\n"
    end
    x
  end

  def comment
    x = @name
    x += " (#{@original_name})" unless @original_name.nil?
    x
  end
end

class RubyJSONArray
  attr_accessor :name, :original_name, :ruby_types

  def self.short_name
    "Array"
  end

  def initialize(name)
    @name = name
    @ruby_types = {}
  end

  def self.parse_from(name, obj_array)
    ob = self.new(name)
    obj_array.each do |v|
      if v.kind_of?(Array)
        arr = RubyJSONArray.parse_from(RubyJSONEntity.get_next_unknown, v)
        ob.ruby_types[arr.attr_hash] = arr
      elsif v.kind_of?(String)
        ob.ruby_types[RUBYSTRING.attr_hash] = RUBYSTRING
      elsif v.kind_of?(Integer)
        ob.ruby_types[RUBYINTEGER.attr_hash] = RUBYINTEGER
      elsif v.kind_of?(Float)
        ob.ruby_types[RUBYFLOAT.attr_hash] = RUBYFLOAT
      elsif !!v==v
        ob.ruby_types[RUBYBOOLEAN.attr_hash] = RUBYBOOLEAN
      elsif v.kind_of?(Hash)
        ent = RubyJSONEntity.parse_from(RubyJSONEntity.get_next_unknown,v)
        ob.ruby_types[ent.attr_hash] = ent
      end
    end

    x = ob.attr_hash
    return RubyJSONEntity.entities[x] if RubyJSONEntity.entities.has_key?(x)
    RubyJSONEntity.entities[x] = ob
    ob
  end

  def attr_hash
    md5 = Digest::MD5.new
    @ruby_types.each do |k,typ|
      md5.update typ.attr_hash
    end
    md5.hexdigest
  end

  def comment
    x = "#{@name}[]"
    x += " (#{@original_name})" unless @original_name.nil?
    x
  end
end

class RubyJSONAttribute
  attr_accessor :name, :original_name, :ruby_type

  def self.short_name
    "Attribute"
  end

  def initialize(name, ruby_type)
    @name = name
    @ruby_type = type || "_unknown"
  end

  def attr_hash
    Digest::MD5.hexdigest("#{@name}:#{@ruby_type}")
  end 

  def ==(other)
    return false if other.class != self
    attr_hash == other.attr_hash
  end
end

## CODE

VERSION = 1.0

puts "json2ruby v#{VERSION}\n"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] <file.json> [<file.json>....]"

  opts.on("-o", "--outputdir OUTPUTDIR", "Output directory") do |v|
    options[:outputdir] = v
  end

  opts.on("-n", "--namespace MODULENAME", "Module namespace path") do |v|
    options[:modulename] = v
  end

  opts.on("-s", "--superclass SUPERCLASS", "Class ancestor") do |v|
    options[:superclass_name] = v
  end

  opts.on("-r", "--require REQUIRE", "Require module in file") do |v|
    options[:require] ||= []
    options[:require] << v
  end

  opts.on("-i", "--include INCLUDE", "Include Class/Module in file") do |v|
    options[:include] ||= []
    options[:include] << v
  end

  opts.on("-e", "--extend INCLUDE", "Extend from Class/Module in file") do |v|
    options[:extend] ||= []
    options[:extend] << v
  end

  opts.on("-M", "--modules", "Create Modules, not classes") do |v|
    options[:modules] = true
    options.delete(:extend)
  end

  opts.on("-a", "--attributemethod METHODNAME", "Use method instead of attr_accessor") do |v|
    options[:attributemethod] = v
  end

  opts.on("-v", "--verbose", "Verbose") do |v|
    options[:verbose] = v
  end
end.parse!

# Defaults
options[:outputdir] ||= "./classes"
options[:modulename] ||= ""
options[:attributemethod] ||= "attr_accessor"
modulenames = options[:modulename].split("::")

# Ensure Output Directory
options[:outputdir] = File.expand_path(options[:outputdir], File.dirname(__FILE__))
puts "Output Directory: #{options[:outputdir]}" if options[:verbose]
unless Dir.exists?(options[:outputdir])
  puts "Creating Output Directory..." if options[:verbose]
  Dir.mkdir(options[:outputdir])
end

# Reset the object cache
RubyJSONEntity.reset_parse

# Load and parse each JSON file
puts "Parsing Files..." if options[:verbose]
ARGV.each do |filename|
  filename = File.expand_path(filename, File.dirname(__FILE__))
  puts "Processing: #{filename}" if options[:verbose]

  file = File.read(filename)
  data_hash = JSON.parse(file)

  rootclass = RubyJSONEntity.parse_from(File.basename(filename,'.*'), data_hash)
end

# Write Entities
opt = {}
[:superclass_name,:include,:require,:extend, :modules, :attributemethod].each { |k| opt[k] = options[k] if options.has_key?(k) }

files = 0
RubyJSONEntity.entities.each do |k,v|
  unless v.is_a?(RubyJSONPrimitive)
    if options[:verbose]
      puts "- #{v.name} (#{v.class.short_name} - #{k})"
      if v.is_a?(RubyJSONEntity)
        v.attributes.each { |ak,av| puts "  #{ak}: #{av.name}" }
      elsif v.is_a?(RubyJSONArray)
        puts "  (Types): #{v.ruby_types.map { |h,v| v.name }.join(',')}"
      end
    end
  end
  if v.is_a?(RubyJSONEntity)
    indent = 0
    out = ""
    modulenames.each do |v| 
      out += (' '*indent)+"module #{v}\r\n"
      indent += 2
    end
    out += v.to_ruby(indent,opt)
    while indent>0
      indent -= 2
      out += (' '*indent)+"end\r\n"
    end

    File.write(options[:outputdir]+"/#{v.name}.rb", out) 
    files += 1
  end
end

# Write out entities


puts "Done, Generated #{files} files"
