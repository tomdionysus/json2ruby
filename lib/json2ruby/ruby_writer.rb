require 'digest/md5'
require 'json'
require 'optparse'

module JSON2Ruby
  class RubyWriter
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

    def self.attributes_to_ruby(entity, indent, options = {})
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