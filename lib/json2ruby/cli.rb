require 'digest/md5'
require 'json'
require 'optparse'

module JSON2Ruby

  class CLI
    def self.run(args)

      puts "json2ruby v#{VERSION}\n"

      # Do the cmdline options
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] <file.json> [<file.json>....]"

        opts.on("-o", "--outputdir OUTPUTDIR", "Output directory") do |v|
          options[:outputdir] = v
        end

        opts.on("-n", "--namespace MODULENAME", "Module namespace path") do |v|
          options[:namespace] = v
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

        opts.on("-a", "--attributemethod METHODNAME", "Use attribute method instead of attr_accessor") do |v|
          options[:attributemethod] = v
        end

        opts.on("-c", "--collectionmethod METHODNAME", "Use collection method instead of attr_accessor") do |v|
          options[:collectionmethod] = v
        end

        opts.on("-t", "--types", "Include type in attribute definition call") do |v|
          options[:includetypes] = true
        end

        opts.on("-b", "--baseless", "Don't generate classes/modules for the root JSON in each file") do |v|
          options[:baseless] = true
        end

        opts.on("-f", "--forceoverwrite", "Overwrite Existing files") do |v|
          options[:forceoverwrite] = v
        end

        opts.on("-N", "--forcenumeric", "Use Numeric instead of Integer/Float") do |v|
          options[:forcenumeric] = v
        end

        opts.on("-v", "--verbose", "Verbose") do |v|
          options[:verbose] = v
        end
      end.parse!

      # Defaults
      options[:outputdir] ||= File.expand_path("./classes")
      options[:namespace] ||= ""
      options[:attributemethod] ||= "attr_accessor"
      options[:collectionmethod] ||= "attr_accessor"
      options[:includetypes] ||= false
      options[:baseless] ||= false
      options[:forceoverwrite] ||= false
      options[:verbose] ||= false
      modulenames = options[:namespace].split("::")

      # Ensure Output Directory
      options[:outputdir] = File.expand_path(options[:outputdir], File.dirname(__FILE__))
      puts "Output Directory: #{options[:outputdir]}" if options[:verbose]
      unless Dir.exists?(options[:outputdir])
        puts "Creating Output Directory..." if options[:verbose]
        Dir.mkdir(options[:outputdir])
      end

      # Reset the object cache
      Entity.reset_parse

      # Load and parse each JSON file
      puts "Parsing Files..." if options[:verbose]

      rootclasses = []

      ARGV.each do |filename|
        filename = File.expand_path(filename)
        puts "Processing: #{filename}" if options[:verbose]

        file = File.read(filename)
        data_hash = JSON.parse(file)

        rootclasses << Entity.parse_from(File.basename(filename,'.*'), data_hash, options)
      end

      # Write Entities

      files = 0
      Entity.entities.each do |k,v|
        next if options[:baseless] and rootclasses.include?(v)

        unless v.is_a?(Primitive)
          if options[:verbose]
            puts "- #{v.name} (#{v.class.short_name} - #{k})"
            if v.is_a?(Entity)
              v.attributes.each { |ak,av| puts "  #{ak}: #{av.name}" }
            elsif v.is_a?(Collection)
              puts "  (Types): #{v.ruby_types.map { |h,v| v.name }.join(',')}"
            end
          end
        end
        if v.is_a?(Entity)
          indent = 0
          out = ""
          modulenames.each do |v|
            out += (' '*indent)+"module #{v}\r\n"
            indent += 2
          end
          out += v.to_ruby(indent,options)
          while indent>0
            indent -= 2
            out += (' '*indent)+"end\r\n"
          end

          filename = options[:outputdir]+"/#{v.name}.rb"
          if File.exists?(filename) && !options[:forceoverwrite]
            $stdout.puts "File #{filename} exists. Use -f to overwrite."
          else
            File.write(filename, out)
            files += 1
          end
        end
      end

      # Done
      puts "Done, Generated #{files} files"
    end
  end
end
