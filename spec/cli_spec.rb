require 'spec_helper'

describe JSON2Ruby::CLI do

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
end