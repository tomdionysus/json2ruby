require 'spec_helper'

describe JSON2Ruby::CLI do

  describe '#run' do
    it 'should call in correct order' do
      options = { :one => 1, :outputdir => File.dirname(__FILE__) }

      expect(JSON2Ruby::CLI).to receive(:puts).with("json2ruby v#{JSON2Ruby::VERSION}\n")
      expect(JSON2Ruby::CLI).to receive(:get_cli_options).and_return(options)
      expect(JSON2Ruby::CLI).to receive(:ensure_output_dir).with(options)
      expect(JSON2Ruby::CLI).to receive(:parse_files).with(options).and_return("rootclasses")
      expect(JSON2Ruby::CLI).to receive(:write_files).with("rootclasses",JSON2Ruby::RubyWriter,options)

      JSON2Ruby::CLI.run
    end
  end

  describe '#ensure_output_dir' do
    it 'should check dir and create if necessary' do
      dir =  File.dirname(__FILE__)
      options = { :one => 1, :outputdir => dir }

      expect(Dir).to receive(:exists?).with(dir).and_return(false)
      expect(Dir).to receive(:mkdir).with(dir)

      expect(JSON2Ruby::CLI).not_to receive(:puts)

      JSON2Ruby::CLI.ensure_output_dir(options)
    end

    it 'should not create dir if exists' do
      dir =  File.dirname(__FILE__)
      options = { :one => 1, :outputdir => dir }

      expect(Dir).to receive(:exists?).with(dir).and_return(true)
      expect(Dir).not_to receive(:mkdir)

      JSON2Ruby::CLI.ensure_output_dir(options)
    end

    it 'should be verbose if option set' do
      dir =  File.dirname(__FILE__)
      options = { :one => 1, :outputdir => dir, :verbose =>true }

      expect(Dir).to receive(:exists?).with(dir).and_return(false)
      expect(Dir).to receive(:mkdir).with(dir)

      expect(JSON2Ruby::CLI).to receive(:puts).with("Output Directory: #{dir}")
      expect(JSON2Ruby::CLI).to receive(:puts).with("Creating Output Directory...")

      JSON2Ruby::CLI.ensure_output_dir(options)
    end
  end

  describe '#get_cli_options' do
  
    it 'should have correct defaults' do
      ARGV = []
      expect(JSON2Ruby::CLI.get_cli_options).to eq({
        :outputdir=> File.expand_path("../classes",File.dirname(__FILE__)), 
        :namespace=>"", 
        :attributemethod=>"attr_accessor", 
        :collectionmethod=>"attr_accessor", 
        :includetypes=>false, 
        :baseless=>false,
        :forceoverwrite=>false, 
        :verbose=>false, 
        :modulenames=>[]
      })
    end

    it 'should parse -o' do
      ARGV=["-o","test"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:outputdir]).to eq("test")
    end

    it 'should parse -n' do
      ARGV=["-n","TEST::TEST2"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:namespace]).to eq("TEST::TEST2")
    end

    it 'should parse -s' do
      ARGV=["-s","TEST"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:superclass_name]).to eq("TEST")
    end

    it 'should parse -r' do
      ARGV=["-r","json/test"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:require]).to eq(["json/test"])
    end

    it 'should parse multiple -r' do
      ARGV=["-r","json/test","-r","onetwo"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:require]).to eq(["json/test","onetwo"])
    end

    it 'should parse -i' do
      ARGV=["-i","json/test"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:include]).to eq(["json/test"])
    end

    it 'should parse multiple -i' do
      ARGV=["-i","json/test","-i","onetwo"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:include]).to eq(["json/test","onetwo"])
    end

    it 'should parse -e' do
      ARGV=["-e","json/test"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:extend]).to eq(["json/test"])
    end

    it 'should parse multiple -e' do
      ARGV=["-e","json/test","-e","onetwo"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:extend]).to eq(["json/test","onetwo"])
    end

    it 'should parse -M' do
      ARGV=["-M","-e","one"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:modules]).to eq(true)
    end

    it 'should parse -a' do
      ARGV=["-a","TESTA"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:attributemethod]).to eq("TESTA")
    end

     it 'should parse -c' do
      ARGV=["-c","TESTB"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:collectionmethod]).to eq("TESTB")
    end

    it 'should parse -t' do
      ARGV=["-t"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:includetypes]).to eq(true)
    end

    it 'should parse -b' do
      ARGV=["-b"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:baseless]).to eq(true)
    end

    it 'should parse -f' do
      ARGV=["-f"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:forceoverwrite]).to eq(true)
    end

    it 'should parse -N' do
      ARGV=["-N"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:forcenumeric]).to eq(true)
    end

    it 'should parse -v' do
      ARGV=["-v"]
      options = JSON2Ruby::CLI.get_cli_options
      expect(options[:verbose]).to eq(true)
    end
  end

  describe '#self.parse_files' do
    it 'should reset entity and parse from files' do
      options = {
        :verbose => false
      }

      ARGV = ['/test/to/file','/test/to/file2']

      expect(File).to receive(:read).with("/test/to/file").and_return('{"one":1}')
      expect(File).to receive(:read).with("/test/to/file2").and_return('{"two":2}')

      expect(JSON2Ruby::Entity).to receive(:parse_from).with("file", {"one"=>1}, options).and_return(3)
      expect(JSON2Ruby::Entity).to receive(:parse_from).with("file2", {"two"=>2}, options).and_return(4)

      expect(JSON2Ruby::CLI.parse_files(options)).to eq([3,4])
    end

    it 'should be verbose when option set' do
    end
  end

  describe '#self.write_files' do
    it 'should call File.exists? and File.write with correct data' do
      options = { :one => 1, :outputdir => File.dirname(__FILE__), :modulenames => [ "TestModule" ] }

      ent = JSON2Ruby::Entity.new("TestEntity", { "one" => JSON2Ruby::RUBYSTRING }) 
      ents = { ent.attr_hash => ent }

      JSON2Ruby::Entity.class_variable_set(:@@objs, ents)

      writer = {}
      expect(writer).to receive(:to_code).with(ent,2,options).and_return("CODE")

      expect(File).to receive(:exists?).with("#{options[:outputdir]}/TestEntity.rb").and_return(false)
      expect(File).to receive(:write).with("#{options[:outputdir]}/TestEntity.rb", "module TestModule\r\nCODEend\r\n")

      expect(JSON2Ruby::CLI).to receive(:puts).with("Done, Generated 1 file")

      JSON2Ruby::CLI.write_files([],writer, options)
    end

    it 'should not write collections' do
      options = { :one => 1, :outputdir => File.dirname(__FILE__), :modulenames => [ "TestModule" ] }

      ents = {}
      ent = JSON2Ruby::Collection.new("TestCollection", { }) 
      ents[ent.attr_hash] = ent

      ent = JSON2Ruby::Entity.new("TestEntity", { "one" => JSON2Ruby::RUBYSTRING }) 
      ents[ent.attr_hash] = ent

      JSON2Ruby::Entity.class_variable_set(:@@objs, ents)

      writer = {}
      expect(writer).to receive(:to_code).with(ent,2,options).and_return("CODE")

      expect(File).to receive(:exists?).with("#{options[:outputdir]}/TestEntity.rb").and_return(false)
      expect(File).to receive(:write).with("#{options[:outputdir]}/TestEntity.rb", "module TestModule\r\nCODEend\r\n")

      expect(JSON2Ruby::CLI).to receive(:puts).with("Done, Generated 1 file")

      JSON2Ruby::CLI.write_files([],writer, options)
    end

    it 'should alert and not write file if it exists and not --forceoverwrite' do
      options = { :one => 1, :outputdir => File.dirname(__FILE__), :modulenames => [ "TestModule" ] }

      ent = JSON2Ruby::Entity.new("TestEntity", { "one" => JSON2Ruby::RUBYSTRING }) 
      ents = { ent.attr_hash => ent }

      JSON2Ruby::Entity.class_variable_set(:@@objs, ents)

      writer = {}
      expect(writer).to receive(:to_code).with(ent,2,options).and_return("CODE")

      expect(File).to receive(:exists?).with("#{options[:outputdir]}/TestEntity.rb").and_return(true)
      expect(File).not_to receive(:write)

      expect($stderr).to receive(:puts).with("File #{options[:outputdir]}/TestEntity.rb exists. Use -f to overwrite.")

      expect(JSON2Ruby::CLI).to receive(:puts).with("Done, Generated 0 files")

      JSON2Ruby::CLI.write_files([],writer, options)
    end

    it 'should write file if it exists and --forceoverwrite' do
      options = { :one => 1, :outputdir => File.dirname(__FILE__), :modulenames => [ "TestModule" ], :forceoverwrite=>true }

      ent = JSON2Ruby::Entity.new("TestEntity", { "one" => JSON2Ruby::RUBYSTRING }) 
      ents = { ent.attr_hash => ent }

      JSON2Ruby::Entity.class_variable_set(:@@objs, ents)

      writer = {}
      expect(writer).to receive(:to_code).with(ent,2,options).and_return("CODE")

      expect(File).to receive(:exists?).with("#{options[:outputdir]}/TestEntity.rb").and_return(true)
      expect(File).to receive(:write).with("#{options[:outputdir]}/TestEntity.rb", "module TestModule\r\nCODEend\r\n")

      expect(JSON2Ruby::CLI).to receive(:puts).with("Done, Generated 1 file")

      JSON2Ruby::CLI.write_files([],writer, options)
    end
  end

  describe '#self.display_entity' do
    it 'should call puts correctly for entity' do
      ent = JSON2Ruby::Entity.new("TestEntity")
      ent.attributes = {
        "test1" => JSON2Ruby::Attribute.new("testAttr"),
        "testEntity" => JSON2Ruby::Entity.new("testEntity"),
        "testCollection" => JSON2Ruby::Collection.new("testCol"),
      }

      expect(JSON2Ruby::CLI).to receive(:puts).with("- TestEntity (Entity - 012345670123456789ABCDEF89ABCDEF)")
      expect(JSON2Ruby::CLI).to receive(:puts).with("  test1: testAttr")
      expect(JSON2Ruby::CLI).to receive(:puts).with("  testEntity: testEntity")
      expect(JSON2Ruby::CLI).to receive(:puts).with("  testCollection: testCol")

      JSON2Ruby::CLI.display_entity("012345670123456789ABCDEF89ABCDEF",ent)
    end

    it 'should call puts correctly for collection' do
      ent = JSON2Ruby::Collection.new("TestCollection")
      ent.ruby_types = {
       JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING
      }

      expect(JSON2Ruby::CLI).to receive(:puts).with("- TestCollection (Collection - 0123456701234567222BCDEF89ABCDEF)")
      expect(JSON2Ruby::CLI).to receive(:puts).with("  (Types): String")

      JSON2Ruby::CLI.display_entity("0123456701234567222BCDEF89ABCDEF",ent)
    end
  end
end