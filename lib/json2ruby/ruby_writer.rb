require 'digest/md5'
require 'json'
require 'optparse'

module JSON2Ruby
  # The RubyWriter class contains methods to output ruby code from a given Entity.
  class RubyWriter
    # Return a String containing a Ruby class/module definition for the given Entity.
    # Optionally, supply indent to set the indent of the generated code in spaces,
    # and supply a Hash of options as follows:
    # * :modules - Boolean if true, generate Ruby +module+ files instead of classes.
    # * :require - Array of String items, each of which will generate a `require '<x>'` statement for each item
    # * :superclass_name - String, if supplied, the superclass of the class to geneerate
    # * :extend - Array of String items, each of which will generate a `extend '<x>'` statement for each item in the class
    # * :include - Array of String items, each of which will generate a `include '<x>'` statement for each item in the class
    def self.to_code(entity, indent = 0, options = {})
      x = ""
      if options.has_key?(:require)
        options[:require].each { |r| x += "require '#{r}'\r\n" }
        x += "\r\n"
      end
      idt = (' '*indent)
      x += "#{(' '*indent)}#{options[:modules] ? "module" : "class"} #{entity.name}"
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
      x += attributes_to_ruby(entity, indent+2, options)
      x += "#{(' '*indent)}end\r\n"
      x
    end

    # Return a String containing the Ruby code for each Attribute definition for in the supplied Entity.
    # Optionally, supply indent to set the indent of the generated code in spaces,
    # and supply a Hash of options as follows:
    # * :attributemethod - String, the method to call to define attributes
    # * :collectionmethod - String, the method to call to define collections
    # * :includetypes - Boolean if true, include the string of the Attribute type as a second parameter to the definition call.
    # * :namespace - String, the namespace of the type classes in the format 'Module::SubModule'...
    def self.attributes_to_ruby(entity, indent = 0, options = {})
      ident = (' '*indent)
      x = ""
      entity.attributes.each do |k,v|
        if (v.is_a?(Collection))
          x += "#{ident}#{options[:collectionmethod]} :#{k}"
        else
          x += "#{ident}#{options[:attributemethod]} :#{k}"
        end
        if options[:includetypes]
          unless v.is_a?(Primitive)
            name = !options[:namespace].nil? && options[:namespace]!="" ? (options[:namespace]+"::"+v.name) : v.name
            x += ", '#{name}'"
          end
        end
        x += " # #{v.comment}\r\n"
      end
      x
    end
  end
end